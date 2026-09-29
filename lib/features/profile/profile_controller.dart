import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/routes/app_routes.dart';
import 'package:fashion_app/core/stores/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    refreshProfile();
  }

  Future<void> openFavorites() async {
    await Get.toNamed(AppRoutes.favorites);
  }

  Future<void> openEditProfile() async {
    await Get.toNamed(AppRoutes.editProfile);
  }

  Future<void> openAddresses() async {
    await Get.toNamed(AppRoutes.addresses);
  }

  /// Pulls the latest profile from the server when the tab is opened.
  Future<void> refreshProfile() async {
    await Get.find<SessionController>().refreshProfile();
  }

  Future<void> openSettings() async {
    await Get.toNamed(AppRoutes.settings);
  }

  Future<void> logout() async {
    final shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('log_out'.tr),
        content: Text('log_out_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text('log_out'.tr),
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