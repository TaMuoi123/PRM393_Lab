# Lab 10.5 - Local Notifications (LO7)

## 1. Overview
This project implements **Lab 10.5 - Local Notifications** for PRM393. It demonstrates:
- Setting up and initializing `flutter_local_notifications`.
- Handling the runtime `POST_NOTIFICATIONS` permission requirement for modern Android 13+ (API 33+).
- Configuring notification channels (`prm393_lab10_notifications`) with `Importance.max` and `Priority.high`.
- Triggering instant local notifications with titles, bodies, and custom payloads.
- Triggering mandatory user action notifications, such as a **Login Success Notification** (`LO7`).
- Receiving and processing notification tap events (`onDidReceiveNotificationResponse`).
- Live notification history log displaying all triggered events during the session.

---

## 2. Notification Actions Demo
1. **Request Permission**: Prompts the system permission dialog on Android 13+.
2. **Instant Alert**: Fires an immediate alert with high priority.
3. **Login Success (LO7)**: Demonstrates the exact notification method required after authenticating a user.
4. **Custom Notification Form**: Allows specifying custom title, body, and payload.

---

## 3. How to Run
```bash
cd Lab10_5_Notification
flutter pub get
flutter run
```
To run automated tests:
```bash
flutter test
```
