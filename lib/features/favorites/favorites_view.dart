import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/features/favorites/favorites_controller.dart';
import 'package:fashion_app/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoritesView extends GetView<FavoritesScreenController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('ផលិតផលដែលចូលចិត្ត'),
        centerTitle: true,
      ),
      body: Obx(() {
        final favorites = controller.favoriteProducts;
        final width = MediaQuery.of(context).size.width;
        final crossAxisCount = width >= 960
            ? 4
            : width >= 720
                ? 3
                : 2;

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return _buildError();
        }
        if (favorites.isEmpty) {
          return _buildEmpty();
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: GridView.builder(
            itemCount: favorites.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.66,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final product = favorites[index];
              return ProductCard(
                product: product,
                onFavoriteToggle: () => controller.toggleFavorite(product),
                onAddToCart: () => controller.addProductToCart(product),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value ?? 'មានបញ្ហា',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: controller.loadData,
              child: const Text('ព្យាយាមម្តងទៀត'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 72, color: AppTheme.textSecondary),
            SizedBox(height: 12),
            Text(
              'មិនទាន់មានផលិតផលដែលចូលចិត្តទេ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}