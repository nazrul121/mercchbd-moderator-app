import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';

  static Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // It's safer to check both the boolean AND if a token exists
    bool status = prefs.getBool(_isLoggedInKey) ?? false;
    String? token = prefs.getString('auth_token');
    return status && token != null;
  }

  static Future<void> setLoginStatus(bool status) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, status);
  }

  static Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Best practice: wipe everything on logout
  }
}