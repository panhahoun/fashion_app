import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/localization/locale_controller.dart';
import 'package:fashion_app/core/routes/app_routes.dart';
import 'package:fashion_app/core/stores/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  static const String orderUpdatesKey = 'notifyOrderUpdates';
  static const String promotionsKey = 'notifyPromotions';

  final RxBool orderUpdatesEnabled = true.obs;
  final RxBool promotionsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadPreferences();
  }

  LocaleController get locale => Get.find<LocaleController>();

  /// Per-device notification preferences, stored locally.
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    orderUpdatesEnabled.value = prefs.getBool(orderUpdatesKey) ?? true;
    promotionsEnabled.value = prefs.getBool(promotionsKey) ?? true;
  }

  Future<void> setOrderUpdates(bool value) async {
    orderUpdatesEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(orderUpdatesKey, value);
  }

  Future<void> setPromotions(bool value) async {
    promotionsEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(promotionsKey, value);
  }

  Future<void> changeLanguage(String code) async {
    await locale.changeLanguage(code);
    _toast('saved'.tr);
  }

  Future<void> openEditProfile() async {
    await Get.toNamed(AppRoutes.editProfile);
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

  void _toast(String message) {
    Get.snackbar(
      'settings'.tr,
      message,
      backgroundColor: AppTheme.primary,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }
}
