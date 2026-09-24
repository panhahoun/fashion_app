import 'package:fashion_app/features/cart/cart_controller.dart';
import 'package:fashion_app/features/categories/categories_controller.dart';
import 'package:fashion_app/features/home/home_controller.dart';
import 'package:fashion_app/features/main_navigation/main_navigation_controller.dart';
import 'package:fashion_app/features/orders/orders_controller.dart';
import 'package:fashion_app/features/profile/profile_controller.dart';
import 'package:get/get.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavigationController>(() => MainNavigationController());
    // Tab controllers are created when their views build inside the IndexedStack.
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<CategoriesController>(() => CategoriesController());
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<OrdersController>(() => OrdersController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}