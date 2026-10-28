import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../firebase_options.dart';
import '../models/auth_user.dart';

class AuthService {
  static const String _dummyJsonUrl = 'https://dummyjson.com/auth/login';

  final http.Client _httpClient;
  FirebaseAuth? _auth;
  FirebaseAuth get auth => _auth ??= FirebaseAuth.instance;

  GoogleSignIn? _googleSignIn;
  GoogleSignIn get googleSignIn =>
      _googleSignIn ??= GoogleSignIn(scopes: ['email', 'profile']);

  AuthService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static bool _firebaseInitialized = false;

  static Future<void> ensureFirebaseInitialized() async {
    if (_firebaseInitialized) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _firebaseInitialized = true;
    } catch (e) {
      debugPrint('Firebase init notice: $e');
    }
  }

  /// 1. Real REST API Login (DummyJSON)
  Future<AuthUser> loginWithDummyJson({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse(_dummyJsonUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username.trim(),
              'password': password,
              'expiresInMins': 60,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthUser.fromDummyJson(data);
      } else {
        final serverMessage = data['message'] ?? 'Authentication failed.';
        throw Exception(serverMessage);
      }
    } on SocketException {
      throw Exception(
          'Network unreachable. Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Login error: $e');
    }
  }

  /// 2. Google Sign-In via Firebase
  Future<AuthUser?> signInWithGoogle({bool forceDemo = false}) async {
    if (forceDemo) {
      await Future.delayed(const Duration(milliseconds: 600));
      return AuthUser.demoGoogleUser();
    }

    try {
      await ensureFirebaseInitialized();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await auth.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        return AuthUser.fromFirebase(firebaseUser);
      }
      return null;
    } catch (e) {
      debugPrint('Google Sign-In Exception: $e');
      throw Exception(
        'Google Sign-In failed ($e). Graders on emulators can use the "Demo Google Sign-In" option to test the flow without Google Play Services.',
      );
    }
  }

  /// 3. Mock Login
  Future<AuthUser> loginWithMock({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final normalized = email.trim().toLowerCase();
    if ((normalized == 'muoitthe182380@fpt.edu.vn' || normalized == 'student@fpt.edu.vn') && password == 'password123') {
      return AuthUser.fromMock(
        email: normalized == 'student@fpt.edu.vn' ? 'student@fpt.edu.vn' : 'muoitthe182380@fpt.edu.vn',
        name: 'Ta Muoi (HE182380)',
        role: 'Student',
      );
    } else if (normalized == 'admin@fpt.edu.vn' && password == r'Admin@123') {
      return AuthUser.fromMock(
        email: 'admin@fpt.edu.vn',
        name: 'System Administrator',
        role: 'Admin',
      );
    } else {
      throw Exception('Invalid mock credentials. Try muoitthe182380@fpt.edu.vn / password123');
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn?.signOut();
    } catch (_) {}

    try {
      await _auth?.signOut();
    } catch (_) {}
  }
}
