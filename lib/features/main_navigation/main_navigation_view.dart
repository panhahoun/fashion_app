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
        () => Material(
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.border.withValues(alpha: 0.7),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(6, 7, 6, 5),
              child: Row(
                children: [
                  _buildDestination(
                    index: 0,
                    label: 'home'.tr,
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                  ),
                  _buildDestination(
                    index: 1,
                    label: 'categories'.tr,
                    icon: Icons.category_outlined,
                    selectedIcon: Icons.category_rounded,
                  ),
                  _buildDestination(
                    index: 2,
                    label: 'cart'.tr,
                    icon: Icons.shopping_bag_outlined,
                    selectedIcon: Icons.shopping_bag_rounded,
                  ),
                  _buildDestination(
                    index: 3,
                    label: 'orders'.tr,
                    icon: Icons.receipt_long_outlined,
                    selectedIcon: Icons.receipt_long_rounded,
                  ),
                  _buildDestination(
                    index: 4,
                    label: 'account'.tr,
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestination({
    required int index,
    required String label,
    required IconData icon,
    required IconData selectedIcon,
  }) {
    final selected = controller.currentIndex.value == index;
    final color = selected ? AppTheme.primary : AppTheme.navUnselected;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: () => controller.changeTab(index),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 38,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.accent.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    selected ? selectedIcon : icon,
                    size: 21,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    height: 1.25,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}