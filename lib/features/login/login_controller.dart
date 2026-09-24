import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/routes/app_routes.dart';
import 'package:fashion_app/core/stores/session_controller.dart';
import 'package:fashion_app/services/api/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleObscurePassword() => obscurePassword.toggle();

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final result = await AuthService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      final user = result['user'] as Map<String, dynamic>;

      await Get.find<SessionController>().saveSession(
        id: user['id'] as int,
        name: user['name'] as String,
        email: user['email'] as String,
        phone: (user['phone'] ?? '') as String,
        token: result['access_token'] as String,
      );

      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      Get.snackbar(
        'មានបញ្ហា',
        e.toString(),
        backgroundColor: AppTheme.errorRed,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}