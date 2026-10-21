import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/localization/localized_content.dart';
import 'package:fashion_app/core/routes/app_routes.dart';
import 'package:fashion_app/core/stores/session_controller.dart';
import 'package:fashion_app/services/api/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isLoading = false.obs;

  // Left to GC: disposing here races the route transition and throws
  // "used after being disposed".

  void toggleObscurePassword() => obscurePassword.toggle();
  void toggleObscureConfirmPassword() => obscureConfirmPassword.toggle();

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final result = await AuthService.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        phone: phoneController.text.trim(),
      );
      final user = result['user'] as Map<String, dynamic>;

      await Get.find<SessionController>().saveSession(
        id: user['id'] as int,
        name: user['name'] as String,
        email: user['email'] as String,
        phone: (user['phone'] ?? '') as String,
        token: result['access_token'] as String,
      );

      // Do not touch state after navigating away.
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'error'.tr,
        localizedErrorMessage(e),
        backgroundColor: AppTheme.errorRed,
        colorText: Colors.white,
      );
    }
  }
}