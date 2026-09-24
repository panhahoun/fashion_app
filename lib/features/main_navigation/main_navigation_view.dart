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
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.navUnselected,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'ទំព័រដើម',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category),
              label: 'ប្រភេទ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'កន្ត្រក',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'ការបញ្ជាទិញ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'គណនី',
            ),
          ],
        ),
      ),
    );
  }
}