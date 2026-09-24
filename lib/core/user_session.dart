import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static int userId = 1;
  static String userName = 'សុខ ធីតា';
  static String userEmail = 'sokthyda@gmail.com';
  static String userPhone = '012345678';
  static String? authToken;
  static bool isLoggedIn = false;

  static Future<void> saveSession({
    required int id,
    required String name,
    required String email,
    required String phone,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    userId = id;
    userName = name;
    userEmail = email;
    userPhone = phone;
    authToken = token;
    isLoggedIn = true;

    await prefs.setInt('userId', id);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    await prefs.setString('userPhone', phone);
    if (token != null) await prefs.setString('authToken', token);
    await prefs.setBool('isLoggedIn', true);
  }

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId') ?? 1;
    userName = prefs.getString('userName') ?? '';
    userEmail = prefs.getString('userEmail') ?? '';
    userPhone = prefs.getString('userPhone') ?? '';
    authToken = prefs.getString('authToken');
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    userId = 0;
    userName = '';
    userEmail = '';
    userPhone = '';
    authToken = null;
    isLoggedIn = false;
  }
}
