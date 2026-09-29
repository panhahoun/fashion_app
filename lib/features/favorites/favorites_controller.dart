import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/localization/localized_content.dart';
import 'package:fashion_app/core/stores/favorites_store_controller.dart';
import 'package:fashion_app/models/product.dart';
import 'package:fashion_app/services/api/cart_service.dart';
import 'package:fashion_app/services/api/product_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoritesScreenController extends GetxController {
  final RxList<Product> allProducts = <Product>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await Get.find<FavoritesStoreController>().load();
      final products = await ProductService.getAllProducts();
      for (final product in products) {
        product.isFavorite =
            Get.find<FavoritesStoreController>().isFavorite(product.id);
      }
      allProducts.value = products;
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = localizedErrorMessage(e);
      isLoading.value = false;
    }
  }

  List<Product> get favoriteProducts {
    return allProducts.where((product) => product.isFavorite).toList();
  }

  Future<void> toggleFavorite(Product product) async {
    final next = !product.isFavorite;
    product.isFavorite = next;
    await Get.find<FavoritesStoreController>().setFavorite(product.id, next);
    allProducts.refresh();
  }

  Future<void> addProductToCart(Product product) async {
    if (product.stock <= 0) {
      Get.snackbar(
        'out_of_stock'.tr,
        'out_of_stock'.tr,
        backgroundColor: AppTheme.errorRed,
        colorText: Colors.white,
      );
      return;
    }

    final selectedSize =
        product.sizes.isNotEmpty ? product.sizes.first : 'One Size';
    final selectedColor = product.colors.isNotEmpty
        ? product.colors.first
        : ProductColor(name: 'Default', hex: '#000000');

    try {
      await CartService.addToCart(
        productId: product.id,
        quantity: 1,
        selectedSize: selectedSize,
        selectedColorName: selectedColor.name,
        selectedColorHex: selectedColor.hex,
      );
      Get.snackbar(
        'success'.tr,
        'added_name_to_cart'.trParams({
          'name': localizedContent(
            khmer: product.nameKhmer,
            english: product.nameEnglish,
          ),
        }),
        backgroundColor: AppTheme.successGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        localizedErrorMessage(e),
        backgroundColor: AppTheme.errorRed,
        colorText: Colors.white,
      );
    }
  }
}