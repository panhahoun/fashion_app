import 'package:fashion_app/core/network/dio_client.dart';
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

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    userId.value = 0;
    userName.value = '';
    userEmail.value = '';
    userPhone.value = '';
    authToken.value = null;
    isLoggedIn.value = false;
    AuthTokenHolder.token = null;
  }
}