import 'package:fashion_app/core/stores/favorites_store_controller.dart';
import 'package:fashion_app/core/stores/session_controller.dart';
import 'package:get/get.dart';

/// App-wide dependencies. Runs before the first route is rendered.
class AppBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<SessionController>(SessionController(), permanent: true);
    Get.put<FavoritesStoreController>(
      FavoritesStoreController(),
      permanent: true,
    );
  }
}