import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/features/cart/cart_view.dart';
import 'package:fashion_app/features/categories/categories_view.dart';
import 'package:fashion_app/features/home/home_view.dart';
import 'package:fashion_app/features/main_navigation/main_navigation_controller.dart';
import 'package:fashion_app/features/orders/orders_view.dart';
import 'package:fashion_app/features/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainNavigationView extends GetView<MainNavigationController> {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomeView(),
            CategoriesView(),
            CartView(),
            OrdersView(),
            ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changeTab,
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.accent.withValues(alpha: 0.18),
          elevation: 8,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: 'home'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.category_outlined),
              selectedIcon: const Icon(Icons.category_rounded),
              label: 'categories'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.shopping_bag_outlined),
              selectedIcon: const Icon(Icons.shopping_bag_rounded),
              label: 'cart'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long_rounded),
              label: 'orders'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: 'account'.tr,
            ),
          ],
        ),
      ),
    );
  }
}