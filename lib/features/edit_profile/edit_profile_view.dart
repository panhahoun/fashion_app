import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/features/edit_profile/edit_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F1),
      appBar: AppBar(
        title: Text('edit_account'.tr),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F5F1),
        elevation: 0,
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _sectionTitle('personal_info'.tr),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller.nameController,
              textInputAction: TextInputAction.next,
              decoration: _decoration(
                label: 'full_name'.tr,
                icon: Icons.person_outline,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'enter_name'.tr;
                }
                if (value.trim().length < 2) {
                  return 'name_min_2'.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              decoration: _decoration(
                label: 'phone_number'.tr,
                icon: Icons.phone_outlined,
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isNotEmpty && text.length < 6) {
                  return 'invalid_phone'.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      controller.isSaving.value ? null : controller.save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'save'.tr,
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline,
                        color: AppTheme.primary),
                    title: Text('change_password'.tr),
                    subtitle: Text('change_password_subtitle'.tr),
                    trailing: Obx(
                      () => Icon(
                        controller.showPasswordSection.value
                            ? Icons.expand_less
                            : Icons.chevron_right,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    onTap: controller.togglePasswordSection,
                  ),
                  Obx(
                    () => AnimatedCrossFade(
                      duration: const Duration(milliseconds: 220),
                      crossFadeState: controller.showPasswordSection.value
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: const SizedBox(width: double.infinity),
                      secondChild: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Form(
                          key: controller.passwordFormKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller:
                                    controller.currentPasswordController,
                                obscureText: controller.obscureCurrent.value,
                                decoration: _decoration(
                                  label: 'enter_current_password'.tr,
                                  icon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscureCurrent.value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      size: 20,
                                    ),
                                    onPressed: controller.toggleCurrent,
                                  ),
                                ),
                                validator: (value) => (value?.isEmpty ?? true)
                                    ? 'enter_current_password'.tr
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: controller.newPasswordController,
                                obscureText: controller.obscureNew.value,
                                decoration: _decoration(
                                  label: 'enter_new_password'.tr,
                                  icon: Icons.lock_reset,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscureNew.value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      size: 20,
                                    ),
                                    onPressed: controller.toggleNew,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'enter_new_password'.tr;
                                  }
                                  if (value.length < 6) {
                                    return 'password_min_6'.tr;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller:
                                    controller.confirmPasswordController,
                                obscureText: controller.obscureConfirm.value,
                                decoration: _decoration(
                                  label: 'confirm_new_password'.tr,
                                  icon: Icons.check_circle_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscureConfirm.value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      size: 20,
                                    ),
                                    onPressed: controller.toggleConfirm,
                                  ),
                                ),
                                validator: (value) {
                                  if (value !=
                                      controller.newPasswordController.text) {
                                    return 'passwords_do_not_match'.tr;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Obx(
                                () => SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        controller.isChangingPassword.value
                                            ? null
                                            : controller.changePassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                    ),
                                    child:
                                        controller.isChangingPassword.value
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Text('change_password'.tr),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 21),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF7F5F2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFF0EEEA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.4),
      ),
    );
  }
}
