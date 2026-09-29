import 'dart:ui';

import 'package:fashion_app/core/localization/app_translations.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the active UI language and persists the user's choice.
class LocaleController extends GetxController {
  static const String prefsKey = 'appLocale';

  /// The two languages offered in the switcher.
  static const List<String> supportedCodes = ['km', 'en'];

  final Rx<Locale> currentLocale;

  LocaleController({String? initialCode})
      : currentLocale = (initialCode == 'en'
                ? AppTranslations.en
                : AppTranslations.kh)
            .obs;

  String get languageCode => currentLocale.value.languageCode;

  bool get isKhmer => languageCode == 'km';

  /// Localized display name for a language code, e.g. "ភាសាខ្មែរ" / "English".
  String labelFor(String code) => (code == 'en' ? 'english' : 'khmer').tr;

  Future<void> changeLanguage(String code) async {
    if (code == languageCode) return;
    final locale = code == 'en' ? AppTranslations.en : AppTranslations.kh;
    currentLocale.value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKey, code);
    Get.updateLocale(locale);
  }

  void toggleLanguage() => changeLanguage(isKhmer ? 'en' : 'km');
}
