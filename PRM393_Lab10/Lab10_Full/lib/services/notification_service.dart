import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();
  factory NotificationService() => instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  static const String channelId = 'prm393_lab10_full_channel';
  static const String channelName = 'PRM393 Lab 10 Full Notifications';
  static const String channelDescription =
      'Notifications for PRM393 Lab 10 Integrated Application';

  Future<void> initialize({
    void Function(NotificationResponse)? onNotificationResponse,
  }) async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: onNotificationResponse,
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService initialize warning: $e');
    }
  }

  Future<bool?> requestPermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        return await androidPlugin?.requestNotificationsPermission();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        return await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
    return false;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Notification show error: $e');
    }
  }

  /// Mandatory LO7 integration: Trigger notification after successful login
  Future<void> showLoginSuccessNotification({
    required String displayName,
    required String provider,
  }) async {
    await showNotification(
      id: 201,
      title: 'Login Successful! 🎉',
      body: 'Welcome back, $displayName! Signed in via $provider.',
      payload: 'login_success_$provider',
    );
  }

  /// Trigger notification after user logs out
  Future<void> showLogoutNotification({required String displayName}) async {
    await showNotification(
      id: 202,
      title: 'Logged Out 👋',
      body: 'Session for $displayName has been safely closed.',
      payload: 'logout_success',
    );
  }
}
