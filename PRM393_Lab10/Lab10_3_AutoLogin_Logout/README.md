# Lab 10.3 - Auto Login & Logout

## 1. Overview
This project implements **Lab 10.3 - Auto Login & Logout** for PRM393. It demonstrates:
- Session persistence in local device storage using `shared_preferences`.
- Storing authentication tokens and serialized user session JSON across app lifecycles.
- A smart `SplashScreen` that checks local storage on startup:
  - If a valid token exists -> routes directly to `HomeScreen` (skipping login).
  - If no session exists -> routes to `LoginScreen`.
- Complete logout flow: clearing session tokens from `SharedPreferences` and navigating back to `LoginScreen` via `Navigator.pushAndRemoveUntil`.

---

## 2. Test Accounts & Scenarios
| Scenario | Action | Expected Result |
| :--- | :--- | :--- |
| **New Login** | Enter `emilys` / `emilyspass` (or click Emily quick-fill) | Authenticates, saves token to SharedPreferences, opens Home |
| **Offline Test** | Enter `offline` / `password123` | Saves offline session without network dependencies |
| **Auto-Login Test** | Restart / Reload the app | `SplashScreen` reads saved token and skips Login directly to Home |
| **Logout Test** | Click "Log Out & Clear Session" | Wipes stored session; subsequent restart returns to Login |

---

## 3. How to Run
```bash
cd Lab10_3_AutoLogin_Logout
flutter pub get
flutter run
```
To run automated tests:
```bash
flutter test
```
