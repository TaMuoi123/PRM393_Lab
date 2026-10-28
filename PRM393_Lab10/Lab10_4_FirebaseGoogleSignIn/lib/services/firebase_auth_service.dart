import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart';
import '../models/google_user_model.dart';

class FirebaseAuthService {
  FirebaseAuth? _auth;
  FirebaseAuth get auth => _auth ??= FirebaseAuth.instance;

  GoogleSignIn? _googleSignIn;
  GoogleSignIn get googleSignIn =>
      _googleSignIn ??= GoogleSignIn(scopes: ['email', 'profile']);

  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _initialized = true;
    } catch (e) {
      debugPrint('Firebase.initializeApp warning (Offline/Mock mode active): $e');
    }
  }

  /// Initiates Google Sign-In with Firebase Authentication
  Future<GoogleUserModel?> signInWithGoogle({bool forceDemo = false}) async {
    if (forceDemo) {
      await Future.delayed(const Duration(milliseconds: 600));
      return GoogleUserModel.demoAccount();
    }

    try {
      await ensureInitialized();

      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in prompt
        return null;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google user credential
      final UserCredential userCredential =
          await auth.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        return GoogleUserModel.fromFirebaseUser(firebaseUser);
      }

      return null;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      throw Exception(
        'Google Sign-In failed ($e). Note: Ensure SHA-1 fingerprint and google-services are configured in Firebase Console, or use "Demo Google Sign-In" to test without Play Services.',
      );
    }
  }

  /// Sign out from both Firebase and Google
  Future<void> signOut() async {
    try {
      await _googleSignIn?.signOut();
    } catch (e) {
      debugPrint('GoogleSignIn signOut error: $e');
    }

    try {
      await _auth?.signOut();
    } catch (e) {
      debugPrint('FirebaseAuth signOut error: $e');
    }
  }

  /// Check if user is currently signed in
  GoogleUserModel? getCurrentUser() {
    try {
      final user = _auth?.currentUser;
      if (user != null) {
        return GoogleUserModel.fromFirebaseUser(user);
      }
    } catch (_) {}
    return null;
  }
}
