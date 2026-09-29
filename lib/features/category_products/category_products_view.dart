import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/localization/localized_content.dart';
import 'package:fashion_app/features/category_products/category_products_controller.dart';
import 'package:fashion_app/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryProductsView extends GetView<CategoryProductsController> {
  const CategoryProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: LocalizedText(
          khmer: controller.category.nameKhmer,
          english: controller.category.nameEnglish,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorRed,
                ),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadProducts,
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }
        if (controller.products.isEmpty) {
          return Center(
            child: Text(
              'no_products'.tr,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return ProductCard(
              product: product,
              onFavoriteToggle: null,
              onAddToCart: null,
            );
          },
        );
      }),
    );
  }
}