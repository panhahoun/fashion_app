import 'package:fashion_app/core/network/dio_client.dart';
import 'package:fashion_app/services/api/api_service.dart';
import 'package:fashion_app/services/api/auth_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reactive replacement for the old static [UserSession] store.
class SessionController extends GetxController {
  final RxInt userId = 1.obs;
  final RxString userName = 'សុខ ធីតា'.obs;
  final RxString userEmail = 'sokthyda@gmail.com'.obs;
  final RxString userPhone = '012345678'.obs;
  final RxnString authToken = RxnString();
  final RxBool isLoggedIn = false.obs;

  Future<void> saveSession({
    required int id,
    required String name,
    required String email,
    required String phone,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    userId.value = id;
    userName.value = name;
    userEmail.value = email;
    userPhone.value = phone;
    authToken.value = token;
    isLoggedIn.value = true;
    AuthTokenHolder.token = token;

    await prefs.setInt('userId', id);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    await prefs.setString('userPhone', phone);
    if (token != null) await prefs.setString('authToken', token);
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    userId.value = prefs.getInt('userId') ?? 1;
    userName.value = prefs.getString('userName') ?? '';
    userEmail.value = prefs.getString('userEmail') ?? '';
    userPhone.value = prefs.getString('userPhone') ?? '';
    authToken.value = prefs.getString('authToken');
    isLoggedIn.value = prefs.getBool('isLoggedIn') ?? false;
    AuthTokenHolder.token = authToken.value;
  }

  /// Applies server-confirmed profile changes to local state and storage.
  Future<void> applyProfile({
    required String name,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = name;
    userPhone.value = phone;
    await prefs.setString('userName', name);
    await prefs.setString('userPhone', phone);
  }

  /// Pulls the authoritative profile from the server, falling back to the
  /// cached values when the request fails (e.g. offline).
  Future<void> refreshProfile() async {
    try {
      final user = await AuthService.me();
      final name = user['name'] as String? ?? userName.value;
      final phone = user['phone'] as String? ?? userPhone.value;
      final email = user['email'] as String? ?? userEmail.value;
      final id = user['id'] as int? ?? userId.value;
      await applyProfile(name: name, phone: phone);
      final prefs = await SharedPreferences.getInstance();
      userEmail.value = email;
      await prefs.setString('userEmail', email);
      await prefs.setInt('userId', id);
    } on ApiException {
      // Keep the cached profile when the network call fails.
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    // Remove only session keys; favorites and other prefs must survive logout.
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userPhone');
    await prefs.remove('authToken');
    await prefs.remove('isLoggedIn');
    userId.value = 0;
    userName.value = '';
    userEmail.value = '';
    userPhone.value = '';
    authToken.value = null;
    isLoggedIn.value = false;
    AuthTokenHolder.token = null;
  }
}