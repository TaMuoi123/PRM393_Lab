import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_user_model.dart';

class DummyJsonAuthService {
  static const String _baseUrl = 'https://dummyjson.com/auth/login';

  final http.Client _client;

  DummyJsonAuthService({http.Client? client}) : _client = client ?? http.Client();

  /// Authenticates user against DummyJSON REST API
  Future<ApiUserModel> login({
    required String username,
    required String password,
    int expiresInMins = 30,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(_baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username.trim(),
              'password': password,
              'expiresInMins': expiresInMins,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiUserModel.fromJson(data);
      } else {
        final serverMessage = data['message'] ?? 'Authentication failed.';
        throw Exception(serverMessage);
      }
    } on SocketException {
      throw Exception('Network error: Cannot reach DummyJSON server. Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again later.');
    } on FormatException {
      throw Exception('Bad response format received from server.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
