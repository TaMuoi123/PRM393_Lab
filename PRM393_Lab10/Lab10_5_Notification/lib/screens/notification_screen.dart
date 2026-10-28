import 'package:flutter/material.dart';
import '../models/notification_log_item.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _notificationService = NotificationService();
  final _titleController = TextEditingController(text: 'Lab 10 Special Notice');
  final _bodyController =
      TextEditingController(text: 'Local notification delivered successfully!');
  final _payloadController =
      TextEditingController(text: 'custom_payload_data_123');

  final List<NotificationLogItem> _logs = [];
  bool? _permissionGranted;

  @override
  void initState() {
    super.initState();
    _notificationService.initialize(
      onNotificationResponse: (response) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notification Clicked! Payload: ${response.payload ?? "none"}',
            ),
            backgroundColor: Colors.teal,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _payloadController.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    final granted = await _notificationService.requestPermission();
    setState(() {
      _permissionGranted = granted;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          granted == true
              ? 'Notification permission GRANTED!'
              : 'Permission was not granted or not required.',
        ),
        backgroundColor: granted == true ? Colors.green : Colors.orange,
      ),
    );
  }

  Future<void> _fireNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notificationService.showNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
    );

    setState(() {
      _logs.insert(
        0,
        NotificationLogItem(
          id: id,
          title: title,
          body: body,
          payload: payload,
          timestamp: DateTime.now(),
        ),
      );
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification triggered: "$title"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 10.5 - Local Notifications'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Permission Card
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
                        Icon(
                          _permissionGranted == true
                              ? Icons.notifications_active
                              : Icons.notifications_none,
                          color: _permissionGranted == true
                              ? Colors.green
                              : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Notification Permission (LO7)',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Android 13+ (API 33+) requires the POST_NOTIFICATIONS runtime permission before notifications can be shown.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _requestPermission,
                      icon: const Icon(Icons.security),
                      label: Text(
                        _permissionGranted == true
                            ? 'Permission Granted'
                            : 'Request POST_NOTIFICATIONS Permission',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: _permissionGranted == true
                            ? Colors.green
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Demonstration Triggers Card
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
                    Text(
                      'Demonstration Triggers',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () => _fireNotification(
                            id: 1,
                            title: 'Instant Alert 🔔',
                            body: 'This is an instant local notification for Lab 10.5.',
                            payload: 'instant_alert',
                          ),
                          icon: const Icon(Icons.bolt),
                          label: const Text('Instant Alert'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _fireNotification(
                            id: 2,
                            title: 'Login Successful! 🎉',
                            body: 'Welcome back, Student! Your session is active.',
                            payload: 'action_login_success',
                          ),
                          icon: const Icon(Icons.login),
                          label: const Text('Login Success (LO7)'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _fireNotification(
                            id: 3,
                            title: 'Session Warning ⚠️',
                            body: 'Your authentication token will expire in 5 minutes.',
                            payload: 'warning_expiry',
                          ),
                          icon: const Icon(Icons.timer),
                          label: const Text('Session Warning'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Custom Notification Form Card
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
                    Text(
                      'Send Custom Notification',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                        labelText: 'Body / Message',
                        prefixIcon: Icon(Icons.message_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _payloadController,
                      decoration: const InputDecoration(
                        labelText: 'Payload Data',
                        prefixIcon: Icon(Icons.data_object),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () {
                        if (_titleController.text.isNotEmpty &&
                            _bodyController.text.isNotEmpty) {
                          _fireNotification(
                            id: DateTime.now().millisecondsSinceEpoch % 100000,
                            title: _titleController.text.trim(),
                            body: _bodyController.text.trim(),
                            payload: _payloadController.text.trim(),
                          );
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Send Custom Notification'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notification Trigger History
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notification History (${_logs.length})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_logs.isNotEmpty)
                          TextButton(
                            onPressed: () => setState(() => _logs.clear()),
                            child: const Text('Clear'),
                          ),
                      ],
                    ),
                    const Divider(),
                    if (_logs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No notifications triggered yet.\nTap one of the buttons above to test!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _logs.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _logs[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Text('${item.id}'),
                            ),
                            title: Text(
                              item.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${item.body}\nPayload: ${item.payload ?? "none"} • ${item.timestamp.toLocal().toString().split('.')[0]}',
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
