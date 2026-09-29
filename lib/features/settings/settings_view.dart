import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/localization/locale_controller.dart';
import 'package:fashion_app/features/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F1),
      appBar: AppBar(
        title: Text('settings'.tr),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F5F1),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        children: [
          _sectionLabel('preferences'.tr),
          _card([
            _tile(
              icon: Icons.language,
              title: 'language'.tr,
              subtitle: Get.find<LocaleController>()
                  .labelFor(Get.find<LocaleController>().languageCode),
              onTap: () => _showLanguageSheet(context),
            ),
          ]),
          const SizedBox(height: 20),
          _sectionLabel('notifications'.tr),
          _card([
            Obx(
              () => _switchTile(
                icon: Icons.local_shipping_outlined,
                title: 'notify_order_updates'.tr,
                subtitle: 'notify_order_updates_subtitle'.tr,
                value: controller.orderUpdatesEnabled.value,
                onChanged: controller.setOrderUpdates,
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),
            Obx(
              () => _switchTile(
                icon: Icons.local_offer_outlined,
                title: 'notify_promotions'.tr,
                subtitle: 'notify_promotions_subtitle'.tr,
                value: controller.promotionsEnabled.value,
                onChanged: controller.setPromotions,
              ),
            ),
          ]),
          const SizedBox(height: 20),
          _sectionLabel('account'.tr),
          _card([
            _tile(
              icon: Icons.person_outline,
              title: 'edit_account'.tr,
              onTap: controller.openEditProfile,
            ),
            const Divider(height: 1, color: AppTheme.border),
            _tile(
              icon: Icons.lock_outline,
              title: 'change_password'.tr,
              subtitle: 'change_password_subtitle'.tr,
              onTap: controller.openEditProfile,
            ),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.logout,
              icon: const Icon(Icons.logout),
              label: Text('sign_out_all'.tr),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                side: const BorderSide(color: AppTheme.errorRed, width: 2),
                foregroundColor: AppTheme.errorRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageSheet(BuildContext context) async {
    final locale = Get.find<LocaleController>();

    await Get.bottomSheet<void>(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'choose_language'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              for (final code in LocaleController.supportedCodes)
                Obx(() {
                  final selected = locale.languageCode == code;
                  return ListTile(
                    onTap: () {
                      controller.changeLanguage(code);
                      Get.back<void>();
                    },
                    title: Text(locale.labelFor(code)),
                    trailing: selected
                        ? const Icon(Icons.check, color: AppTheme.primary)
                        : null,
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Material(
      color: AppTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFEDE9E3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 21),
      ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppTheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.accent,
    );
  }
}
