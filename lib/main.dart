import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/bindings/app_binding.dart';
import 'package:fashion_app/core/routes/app_pages.dart';
import 'package:fashion_app/core/routes/app_routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// ============================================================================
// MAIN APP - FASHION STORE (GetX + Dio)
// ============================================================================

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
  runApp(const FashionStoreApp());
}

class FashionStoreApp extends StatelessWidget {
  const FashionStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ហាងម៉ូត - Fashion Store',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: AppBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}