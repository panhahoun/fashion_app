import 'package:fashion_app/features/cart/cart_controller.dart';
import 'package:fashion_app/features/orders/orders_controller.dart';
import 'package:get/get.dart';

class MainNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
    switch (index) {
      case 2:
        if (Get.isRegistered<CartController>()) {
          Get.find<CartController>().refreshCart();
        }
      case 3:
        if (Get.isRegistered<OrdersController>()) {
          Get.find<OrdersController>().loadOrders();
        }
    }
  }
}