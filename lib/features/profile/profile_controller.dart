import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/routes/app_routes.dart';
import 'package:fashion_app/core/stores/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  Future<void> openFavorites() async {
    await Get.toNamed(AppRoutes.favorites);
  }

  void showComingSoon() {
    Get.snackbar(
      'ការជូនដំណឹង',
      'មុខងារនេះនឹងមកដល់ឆាប់ៗនេះ',
      backgroundColor: AppTheme.primary,
      colorText: Colors.white,
    );
  }

  Future<void> logout() async {
    final shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('ចាកចេញ'),
        content: const Text('តើអ្នកប្រាកដថាចង់ចាកចេញពីគណនីទេ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('បោះបង់'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('ចាកចេញ'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await Get.find<SessionController>().clearSession();
      Get.offAllNamed(AppRoutes.login);
    }
  }
}