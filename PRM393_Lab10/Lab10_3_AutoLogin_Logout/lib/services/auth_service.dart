import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_session.dart';

class AuthService {
  static const String _loginUrl = 'https://dummyjson.com/auth/login';
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<UserSession> login({
    required String username,
    required String password,
  }) async {
    // Also support quick offline testing if needed
    if (username == 'offline' && password == 'password123') {
      await Future.delayed(const Duration(milliseconds: 600));
      return UserSession(
        id: 999,
        username: 'offline_user',
        email: 'offline@prm393.edu',
        firstName: 'Offline',
        lastName: 'Tester',
        gender: 'other',
        image: 'https://dummyjson.com/icon/emilys/128',
        token: 'offline-jwt-token-session-persisted',
        loginTime: DateTime.now(),
      );
    }

    try {
      final response = await _client
          .post(
            Uri.parse(_loginUrl),
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
        return UserSession.fromDummyJson(data);
      } else {
        final serverMessage = data['message'] ?? 'Authentication failed.';
        throw Exception(serverMessage);
      }
    } on SocketException {
      throw Exception('Network error: Unable to connect to server.');
    } on TimeoutException {
      throw Exception('Request timed out. Please check your connection.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
