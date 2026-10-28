# Lab 10.1 - Mock Login (Backend Simulation)

## 1. Overview
This project implements **Lab 10.1 - Mock Login** for PRM393. It demonstrates:
- Flutter `Form` and `TextFormField` input validation (email format, password minimum length).
- Password visibility toggle (obscure/reveal).
- Simulating asynchronous backend authentication with `Future.delayed` and returning a mock JWT token.
- Handling loading state with a spinner (`CircularProgressIndicator`).
- Navigation to a `HomeScreen` displaying user session info, mock token, and a logout dialog.
- SnackBar feedback for failed authentication attempts.

---

## 2. Test Accounts
You can tap the quick-fill chips on screen or type manually:
| Role | Email | Password | Result |
| :--- | :--- | :--- | :--- |
| **Student** | `muoitthe182380@fpt.edu.vn` | `password123` | Login Success -> Home Screen (Ta Muoi) |
| **Admin** | `admin@fpt.edu.vn` | `Admin@123` | Login Success -> Home Screen |
| **Failed** | `muoitthe182380@fpt.edu.vn` | `wrongpass` | Error SnackBar |

---

## 3. How to Run
```bash
cd Lab10_1_MockLogin
flutter pub get
flutter run
```
To run automated tests:
```bash
flutter test
```
