import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? token;
  final String authProvider; // 'DummyJSON REST API', 'Firebase Google Sign-In', 'Mock Auth'
  final DateTime loginTime;

  AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.token,
    required this.authProvider,
    required this.loginTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'token': token,
      'authProvider': authProvider,
      'loginTime': loginTime.toIso8601String(),
    };
  }

  factory AuthUser.fromMap(Map<String, dynamic> map) {
    return AuthUser(
      id: map['id']?.toString() ?? '',
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      token: map['token'] as String?,
      authProvider: map['authProvider'] as String? ?? 'Mock Auth',
      loginTime: map['loginTime'] != null
          ? DateTime.parse(map['loginTime'] as String)
          : DateTime.now(),
    );
  }

  factory AuthUser.fromDummyJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();

    return AuthUser(
      id: json['id']?.toString() ?? '0',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: fullName.isNotEmpty ? fullName : (json['username'] ?? 'User'),
      photoUrl: json['image'] as String?,
      token: (json['accessToken'] ?? json['token'] ?? '') as String,
      authProvider: 'DummyJSON REST API',
      loginTime: DateTime.now(),
    );
  }

  factory AuthUser.fromFirebase(User user) {
    return AuthUser(
      id: user.uid,
      username: user.email?.split('@').first ?? 'google_user',
      email: user.email ?? 'No email',
      displayName: user.displayName ?? 'Google User',
      photoUrl: user.photoURL,
      token: 'firebase-token-${user.uid}',
      authProvider: 'Firebase Google Sign-In',
      loginTime: DateTime.now(),
    );
  }

  factory AuthUser.demoGoogleUser() {
    return AuthUser(
      id: 'firebase-uid-demo-999',
      username: 'student.google',
      email: 'student.fpt@gmail.com',
      displayName: 'Nguyen Van A (Google)',
      photoUrl: 'https://lh3.googleusercontent.com/a/default-user=s128',
      token: 'demo-google-oauth2-token-active',
      authProvider: 'Firebase Google Sign-In',
      loginTime: DateTime.now(),
    );
  }

  factory AuthUser.fromMock({
    required String email,
    required String name,
    required String role,
  }) {
    return AuthUser(
      id: email.hashCode.abs().toString(),
      username: email.split('@').first,
      email: email,
      displayName: name,
      photoUrl: null,
      token: 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}',
      authProvider: 'Mock Auth ($role)',
      loginTime: DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());
  static AuthUser? fromJson(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return AuthUser.fromMap(map);
    } catch (_) {
      return null;
    }
  }
}
