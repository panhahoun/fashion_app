import 'package:fashion_app/features/splash/splash_controller.dart';
import 'package:get/get.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Regular put (not lazy) so the controller starts the navigation timer
    // immediately when the splash route is pushed.
    Get.put<SplashController>(SplashController());
  }
}