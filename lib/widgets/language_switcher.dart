import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/localization/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Compact Khmer/English toggle used on the auth screens and in Settings.
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key, this.showLabel = false});

  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final locale = Get.find<LocaleController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'language'.tr,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOption(context, locale, 'km'),
              _buildOption(context, locale, 'en'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context,
    LocaleController locale,
    String code,
  ) {
    return Obx(() {
      final isSelected = locale.languageCode == code;
      return InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => locale.changeLanguage(code),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            locale.labelFor(code),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.white70,
            ),
          ),
        ),
      );
    });
  }
}
