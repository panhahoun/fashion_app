import 'package:fashion_app/core/localization/locale_controller.dart';
import 'package:fashion_app/core/network/dio_client.dart';
import 'package:fashion_app/core/routes/app_routes.dart';
import 'package:fashion_app/core/stores/favorites_store_controller.dart';
import 'package:fashion_app/core/stores/session_controller.dart';
import 'package:get/get.dart';

/// App-wide dependencies. Runs before the first route is rendered.
class AppBinding implements Bindings {
  @override
  void dependencies() {
    // main() pre-loads the saved language so the first frame is already
    // correct; this registration keeps the dependency available to every view
    // (and to widget tests that build the app without running main()).
    if (!Get.isRegistered<LocaleController>()) {
      Get.put<LocaleController>(LocaleController(), permanent: true);
    }

    Get.put<SessionController>(SessionController(), permanent: true);
    Get.put<FavoritesStoreController>(
      FavoritesStoreController(),
      permanent: true,
    );

    // A stale/expired token gives a 401 on any authenticated request. Clear
    // the session and bounce to login instead of showing empty screens.
    AuthTokenHolder.onUnauthorized = () async {
      final session = Get.find<SessionController>();
      if (!session.isLoggedIn.value) return;
      await session.clearSession();
      Get.offAllNamed(AppRoutes.login);
    };
  }
}