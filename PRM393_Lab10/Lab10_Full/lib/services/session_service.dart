import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_user.dart';

class SessionService {
  static const String _sessionKey = 'lab10_full_user_session';
  static const String _tokenKey = 'lab10_full_auth_token';

  Future<void> saveUser(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, user.toJson());
    if (user.token != null) {
      await prefs.setString(_tokenKey, user.token!);
    }
  }

  Future<AuthUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_sessionKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return null;
    }
    return AuthUser.fromJson(jsonStr);
  }

  Future<bool> hasActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_tokenKey);
  }
}
