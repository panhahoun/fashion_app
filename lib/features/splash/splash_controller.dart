import 'package:fashion_app/core/routes/app_routes.dart';
import 'package:fashion_app/core/stores/favorites_store_controller.dart';
import 'package:fashion_app/core/stores/session_controller.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    await Get.find<SessionController>().loadSession();
    await Get.find<FavoritesStoreController>().load();

    Get.offAllNamed(
      Get.find<SessionController>().isLoggedIn.value
          ? AppRoutes.main
          : AppRoutes.login,
    );
  }
}