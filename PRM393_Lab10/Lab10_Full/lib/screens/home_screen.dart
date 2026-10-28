import 'package:flutter/material.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/session_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final AuthUser user;
  final bool wasAutoLoggedIn;

  const HomeScreen({
    super.key,
    required this.user,
    this.wasAutoLoggedIn = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _sessionService = SessionService();
  final _authService = AuthService();
  final _notificationService = NotificationService();

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text(
          'Are you sure you want to log out? Your saved session in SharedPreferences will be cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // 1. Clear session from local device storage
      await _sessionService.clearUser();

      // 2. Sign out from Firebase/Google if applicable
      await _authService.signOut();

      // 3. Trigger Logout Notification
      await _notificationService.showLogoutNotification(
        displayName: widget.user.displayName,
      );

      if (!mounted) return;

      // 4. Return to LoginScreen and clear route stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out and cleared local session.'),
          backgroundColor: Colors.blueGrey,
        ),
      );
    }
  }

  Future<void> _sendTestNotification() async {
    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'Lab 10 Verified! ✅',
      body: 'Active session for ${widget.user.displayName} is healthy and working.',
      payload: 'lab10_verified',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification dispatched to system tray.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 10 Dashboard'),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Send Test Notification',
            onPressed: _sendTestNotification,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Auto-login Banner
            if (widget.wasAutoLoggedIn)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Auto-Login: Session automatically restored from SharedPreferences without re-authenticating!',
                        style: TextStyle(
                          color: Colors.green.shade900,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // User Profile Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: ClipOval(
                        child: (user.photoUrl != null &&
                                user.photoUrl!.startsWith('http'))
                            ? Image.network(
                                user.photoUrl!,
                                width: 92,
                                height: 92,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  Icons.person,
                                  size: 54,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 54,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user.displayName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user.username}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Chip(
                      avatar: const Icon(Icons.verified, size: 16),
                      label: Text(
                        'Provider: ${user.authProvider}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Persistent Session Details Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storage,
                            color: theme.colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Session & Storage Persistence',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      icon: Icons.email_outlined,
                      label: 'User Email',
                      value: user.email,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.access_time_filled,
                      label: 'Login Timestamp',
                      value: user.loginTime.toLocal().toString().split('.')[0],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.vpn_key_outlined,
                      label: 'Session Token (Stored in SharedPreferences)',
                      value: user.token ?? 'N/A',
                      isMonospace: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notification Demonstration Card (LO7)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications_active,
                            color: Colors.amber[800], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Local Notifications Action Center (LO7)',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A local notification was automatically triggered when you logged in. You can also manually trigger notifications below:',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: _sendTestNotification,
                          icon: const Icon(Icons.send),
                          label: const Text('Send Instant Alert'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            _notificationService.showLoginSuccessNotification(
                              displayName: user.displayName,
                              provider: user.authProvider,
                            );
                          },
                          icon: const Icon(Icons.login),
                          label: const Text('Re-trigger Login Alert'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Logout Button
            FilledButton.icon(
              onPressed: _handleLogout,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text(
                'Log Out & Clear Session',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMonospace = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: isMonospace ? 2 : null,
                overflow: isMonospace ? TextOverflow.ellipsis : null,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: isMonospace ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
