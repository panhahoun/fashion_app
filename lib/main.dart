import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/bindings/app_binding.dart';
import 'package:fashion_app/core/localization/app_translations.dart';
import 'package:fashion_app/core/localization/locale_controller.dart';
import 'package:fashion_app/core/routes/app_pages.dart';
import 'package:fashion_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env so API/Base URL can be changed without touching source code.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Keep app running with fallback config if .env is missing.
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Restore the saved language before the first frame so the app never
  // flashes the wrong locale on start.
  final prefs = await SharedPreferences.getInstance();
  final savedCode = prefs.getString(LocaleController.prefsKey);
  Get.put(LocaleController(initialCode: savedCode), permanent: true);

  runApp(const FashionStoreApp());
}

class FashionStoreApp extends StatelessWidget {
  const FashionStoreApp({super.key, this.initialLocale});

  /// Overrides the stored language; defaults to the persisted one.
  final Locale? initialLocale;

  @override
  Widget build(BuildContext context) {
    final locale =
        initialLocale ??
        (Get.isRegistered<LocaleController>()
            ? Get.find<LocaleController>().currentLocale.value
            : AppTranslations.kh);

    return GetMaterialApp(
      title: 'app_name'.tr,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      translations: AppTranslations(),
      locale: locale,
      fallbackLocale: AppTranslations.kh,
      supportedLocales: AppTranslations.supported,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialBinding: AppBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
