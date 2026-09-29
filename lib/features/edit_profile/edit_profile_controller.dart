import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/localization/localized_content.dart';
import 'package:fashion_app/core/stores/session_controller.dart';
import 'package:fashion_app/services/api/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxBool isSaving = false.obs;
  final RxBool isChangingPassword = false.obs;
  final RxBool showPasswordSection = false.obs;
  final RxBool obscureCurrent = true.obs;
  final RxBool obscureNew = true.obs;
  final RxBool obscureConfirm = true.obs;

  @override
  void onInit() {
    super.onInit();
    final session = Get.find<SessionController>();
    nameController.text = session.userName.value;
    phoneController.text = session.userPhone.value;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordSection() => showPasswordSection.toggle();
  void toggleCurrent() => obscureCurrent.toggle();
  void toggleNew() => obscureNew.toggle();
  void toggleConfirm() => obscureConfirm.toggle();

  Future<void> save() async {
    if (isSaving.value) return;
    if (!formKey.currentState!.validate()) return;

    isSaving.value = true;
    try {
      final updated = await AuthService.updateProfile(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );
      await Get.find<SessionController>().applyProfile(
        name: updated['name'] as String? ?? nameController.text.trim(),
        phone: updated['phone'] as String? ?? phoneController.text.trim(),
      );
      _toast('profile_saved'.tr, isError: false);
      Get.back();
    } catch (e) {
      _toast(localizedErrorMessage(e), isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> changePassword() async {
    if (isChangingPassword.value) return;
    if (!passwordFormKey.currentState!.validate()) return;

    isChangingPassword.value = true;
    try {
      await AuthService.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      showPasswordSection.value = false;
      _toast('change_password_success'.tr, isError: false);
    } catch (e) {
      _toast(localizedErrorMessage(e), isError: true);
    } finally {
      isChangingPassword.value = false;
    }
  }

  void _toast(String message, {required bool isError}) {
    Get.snackbar(
      isError ? 'error'.tr : 'success'.tr,
      message,
      backgroundColor: isError ? AppTheme.errorRed : AppTheme.successGreen,
      colorText: Colors.white,
    );
  }
}
