import 'package:fashion_app/features/cart/cart_controller.dart';
import 'package:get/get.dart';

class MainNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
    if (index == 2) {
      Get.find<CartController>().refreshCart();
    }
  }
}