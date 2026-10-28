import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_session.dart';

class SessionService {
  Future<void> saveSession(UserSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await session.saveToPreferences(prefs);
  }

  Future<UserSession?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return UserSession.fromPreferences(prefs);
  }

  Future<bool> hasValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await UserSession.clearFromPreferences(prefs);
  }
}
