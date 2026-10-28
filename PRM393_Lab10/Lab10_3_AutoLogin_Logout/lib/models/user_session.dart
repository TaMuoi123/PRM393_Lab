import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String token;
  final DateTime loginTime;

  UserSession({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    required this.token,
    required this.loginTime,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
      'token': token,
      'loginTime': loginTime.toIso8601String(),
    };
  }

  factory UserSession.fromMap(Map<String, dynamic> map) {
    return UserSession(
      id: map['id'] as int? ?? 0,
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
      image: map['image'] as String? ?? '',
      token: (map['token'] ?? map['accessToken'] ?? '') as String,
      loginTime: map['loginTime'] != null
          ? DateTime.parse(map['loginTime'] as String)
          : DateTime.now(),
    );
  }

  factory UserSession.fromDummyJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      image: json['image'] as String? ?? '',
      token: (json['accessToken'] ?? json['token'] ?? '') as String,
      loginTime: DateTime.now(),
    );
  }

  static const String _keySession = 'user_session_data';
  static const String _keyToken = 'auth_token';

  Future<void> saveToPreferences(SharedPreferences prefs) async {
    await prefs.setString(_keySession, jsonEncode(toMap()));
    await prefs.setString(_keyToken, token);
  }

  static UserSession? fromPreferences(SharedPreferences prefs) {
    final sessionData = prefs.getString(_keySession);
    final token = prefs.getString(_keyToken);

    if (sessionData == null || token == null || token.isEmpty) {
      return null;
    }

    try {
      final map = jsonDecode(sessionData) as Map<String, dynamic>;
      return UserSession.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearFromPreferences(SharedPreferences prefs) async {
    await prefs.remove(_keySession);
    await prefs.remove(_keyToken);
  }
}
