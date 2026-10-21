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
    // main() preloads the saved language; registered here too so widget tests
    // work without running main().
    if (!Get.isRegistered<LocaleController>()) {
      Get.put<LocaleController>(LocaleController(), permanent: true);
    }

    Get.put<SessionController>(SessionController(), permanent: true);
    Get.put<FavoritesStoreController>(
      FavoritesStoreController(),
      permanent: true,
    );

    // A 401 on an authenticated request means the saved token is stale.
    AuthTokenHolder.onUnauthorized = () async {
      final session = Get.find<SessionController>();
      if (!session.isLoggedIn.value) return;
      await session.clearSession();
      Get.offAllNamed(AppRoutes.login);
    };
  }
}