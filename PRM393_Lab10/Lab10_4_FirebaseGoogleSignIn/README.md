# Lab 10.4 - Firebase Authentication (Google Sign-In)

## 1. Overview
This project implements **Lab 10.4 - Firebase Google Sign-In** for PRM393. It demonstrates:
- Integrating `firebase_core`, `firebase_auth`, and `google_sign_in`.
- Creating `GoogleAuthProvider` credentials using tokens obtained from `GoogleSignInAccount`.
- Signing in to Firebase via `FirebaseAuth.instance.signInWithCredential()`.
- Displaying authenticated user profile data (Google display name, email, avatar image URL, and Firebase UID).
- Implementing complete sign out logic calling both `FirebaseAuth.instance.signOut()` and `GoogleSignIn().signOut()`.
- Providing a fallback test mode to facilitate grading on emulators without Google Play Services or SHA-1 fingerprints configured.

---

## 2. Firebase Configuration Details
- **Project ID**: `prm393-lab10-firebase`
- **Options File**: `lib/firebase_options.dart` (DefaultFirebaseOptions)
- **SHA-1 Fingerprint Configuration Guide**:
  To add your machine's debug SHA-1 to Firebase Console:
  1. In terminal: `cd android && ./gradlew signingReport`
  2. Copy the SHA-1 from `debug` keystore.
  3. Paste into **Firebase Console > Project Settings > Your Android Apps > Add Fingerprint**.
  4. Download updated `google-services.json` to `android/app/`.

---

## 3. How to Run
```bash
cd Lab10_4_FirebaseGoogleSignIn
flutter pub get
flutter run
```
To run automated tests:
```bash
flutter test
```
