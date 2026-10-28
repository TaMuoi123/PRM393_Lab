# Lab 10 Full - Integrated Authentication, Session & Notification App

## 1. Overview
This project represents the complete **Lab10_Full** integrated application for PRM393, unifying all requirements from Lab 10.1 to Lab 10.5 into a cohesive architecture:
1. **SplashScreen Routing**: Smart session inspection in `SharedPreferences` that immediately bypasses login if a valid session exists.
2. **Real REST API Login (Lab 10.2)**: Authenticates against DummyJSON (`POST https://dummyjson.com/auth/login`) with robust error handling and loading indicators.
3. **Mock Login (Lab 10.1)**: Alternative simulated authentication flow for offline test environments.
4. **Firebase Google Sign-In (Lab 10.4)**: Real Google Sign-In flow with fallback Demo mode for emulators without Play Services.
5. **Session Persistence & Auto-Login (Lab 10.3)**: Saves tokens, user profile info, and login timestamp across application lifecycles.
6. **Local Notifications Integration (LO7 - Lab 10.5)**: Automatically dispatches a system tray notification on successful login, and provides an interactive Notification Action Center on the Home Dashboard.
7. **Complete Logout Workflow**: Clears session data from `SharedPreferences`, signs out from Firebase/Google, triggers a logout notification, and safely routes back to `LoginScreen`.

---

## 2. Test Accounts & Scenarios

### Option A: Real REST API (DummyJSON)
| Username | Password | Full Name |
| :--- | :--- | :--- |
| `emilys` | `emilyspass` | Emily Johnson |
| `michaelw` | `michaelwpass` | Michael Williams |

### Option B: Firebase Google Sign-In
- Click **"Sign in with Google (Firebase)"** to authenticate using your Google account (requires Google Play Services).
- Click **"Demo Google Sign-In (Simulator Mode)"** to test on standard emulators without Google Play Services or SHA-1 fingerprints.

### Option C: Mock Authentication
| Email | Password | Role |
| :--- | :--- | :--- |
| `muoitthe182380@fpt.edu.vn` | `password123` | Student (Ta Muoi HE182380) |
| `admin@fpt.edu.vn` | `Admin@123` | Admin |

---

## 3. How to Run
```bash
cd Lab10_Full
flutter pub get
flutter run
```
To run automated tests:
```bash
flutter test
```
