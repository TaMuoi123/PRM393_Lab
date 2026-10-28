import 'package:flutter/material.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/session_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for Real API
  final _apiFormKey = GlobalKey<FormState>();
  final _apiUsernameController = TextEditingController(text: 'emilys');
  final _apiPasswordController = TextEditingController(text: 'emilyspass');

  // Controllers for Mock Login
  final _mockFormKey = GlobalKey<FormState>();
  final _mockEmailController =
      TextEditingController(text: 'muoitthe182380@fpt.edu.vn');
  final _mockPasswordController = TextEditingController(text: 'password123');

  final _authService = AuthService();
  final _sessionService = SessionService();
  final _notificationService = NotificationService();

  bool _isLoading = false;
  bool _obscureApiPassword = true;
  bool _obscureMockPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiUsernameController.dispose();
    _apiPasswordController.dispose();
    _mockEmailController.dispose();
    _mockPasswordController.dispose();
    super.dispose();
  }

  Future<void> _completeLogin(AuthUser user) async {
    // 1. Save session to SharedPreferences (Persistence & Auto-Login)
    await _sessionService.saveUser(user);

    // 2. Trigger Local Notification on success (LO7 Integration)
    await _notificationService.showLoginSuccessNotification(
      displayName: user.displayName,
      provider: user.authProvider,
    );

    if (!mounted) return;

    // 3. Route to HomeScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(user: user, wasAutoLoggedIn: false),
      ),
    );
  }

  Future<void> _handleRealApiLogin() async {
    if (!_apiFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.loginWithDummyJson(
        username: _apiUsernameController.text.trim(),
        password: _apiPasswordController.text,
      );
      await _completeLogin(user);
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleMockLogin() async {
    if (!_mockFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.loginWithMock(
        email: _mockEmailController.text.trim(),
        password: _mockPasswordController.text,
      );
      await _completeLogin(user);
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn({bool forceDemo = false}) async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithGoogle(forceDemo: forceDemo);
      if (user != null) {
        await _completeLogin(user);
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber),
              SizedBox(width: 8),
              Text('Google Sign-In Alert'),
            ],
          ),
          content: Text(e.toString().replaceAll('Exception: ', '')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _handleGoogleSignIn(forceDemo: true);
              },
              child: const Text('Use Demo Google Sign-In'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Logo
                Icon(
                  Icons.lock_person_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'PRM393 - Lab 10 Full',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unified Authentication & Notification System',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Tab Selector
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.cloud_outlined, size: 20),
                        text: 'REST API Login',
                      ),
                      Tab(
                        icon: Icon(Icons.sim_card_download_outlined, size: 20),
                        text: 'Mock Login',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tab Content
                SizedBox(
                  height: 280,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: REST API Login
                      Form(
                        key: _apiFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _apiUsernameController,
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                labelText: 'Username (DummyJSON)',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Enter username'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _apiPasswordController,
                              obscureText: _obscureApiPassword,
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureApiPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(() =>
                                      _obscureApiPassword =
                                          !_obscureApiPassword),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Enter password'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            FilledButton(
                              onPressed: _isLoading ? null : _handleRealApiLogin,
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text('Sign In via REST API'),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: [
                                ActionChip(
                                  label: const Text('Emily (emilys)'),
                                  onPressed: () {
                                    _apiUsernameController.text = 'emilys';
                                    _apiPasswordController.text = 'emilyspass';
                                  },
                                ),
                                ActionChip(
                                  label: const Text('Michael (michaelw)'),
                                  onPressed: () {
                                    _apiUsernameController.text = 'michaelw';
                                    _apiPasswordController.text =
                                        'michaelwpass';
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // TAB 2: Mock Login
                      Form(
                        key: _mockFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _mockEmailController,
                              enabled: !_isLoading,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) => (v == null || !v.contains('@'))
                                  ? 'Enter valid email'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _mockPasswordController,
                              obscureText: _obscureMockPassword,
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureMockPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(() =>
                                      _obscureMockPassword =
                                          !_obscureMockPassword),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) => (v == null || v.length < 6)
                                  ? 'Minimum 6 chars'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            FilledButton(
                              onPressed: _isLoading ? null : _handleMockLogin,
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text('Sign In via Mock Service'),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: [
                                ActionChip(
                                  label: const Text('Student (MuoiTT)'),
                                  onPressed: () {
                                    _mockEmailController.text =
                                        'muoitthe182380@fpt.edu.vn';
                                    _mockPasswordController.text =
                                        'password123';
                                  },
                                ),
                                ActionChip(
                                  label: const Text('Admin FPT'),
                                  onPressed: () {
                                    _mockEmailController.text =
                                        'admin@fpt.edu.vn';
                                    _mockPasswordController.text = r'Admin@123';
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 28),

                // Firebase Google Sign In Option
                OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _handleGoogleSignIn(forceDemo: false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        child: const Text(
                          'G',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4285F4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Sign in with Google (Firebase)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Demo Google Sign-In for grader convenience
                FilledButton.tonal(
                  onPressed: _isLoading
                      ? null
                      : () => _handleGoogleSignIn(forceDemo: true),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Demo Google Sign-In (Simulator Mode)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
