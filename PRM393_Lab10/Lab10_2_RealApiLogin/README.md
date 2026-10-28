# Lab 10.2 - Real REST API Login

## 1. Overview
This project implements **Lab 10.2 - Real REST API Login** for PRM393. It demonstrates:
- Sending HTTP `POST` requests to a real production REST API: `https://dummyjson.com/auth/login`.
- Transmitting JSON request payload containing `username`, `password`, and `expiresInMins`.
- Parsing responses: decoding user identity, avatar URL, full name, email, and JWT `accessToken` / `refreshToken`.
- Displaying real-time loading state with animated progress indicators and disabled inputs.
- Gracefully handling HTTP error responses (e.g. 400 Bad Request / Invalid Credentials) and displaying user-friendly SnackBar messages.
- Complete profile dashboard screen showcasing the parsed JSON data and logout capability.

---

## 2. Test Accounts (DummyJSON)
You can tap the quick-fill chips directly on screen:
| Display Name | Username | Password | Notes |
| :--- | :--- | :--- | :--- |
| **Emily Johnson** | `emilys` | `emilyspass` | Active DummyJSON account (ID: 1) |
| **Michael Williams** | `michaelw` | `michaelwpass` | Active DummyJSON account (ID: 2) |
| **Invalid Test** | `emilys` | `wrongpassword` | Triggers HTTP 400 "Invalid credentials" error |

---

## 3. How to Run
```bash
cd Lab10_2_RealApiLogin
flutter pub get
flutter run
```
To run automated tests:
```bash
flutter test
```
