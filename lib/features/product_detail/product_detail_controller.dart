import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/models/product.dart';
import 'package:fashion_app/services/api/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailController extends GetxController {
  static const String _defaultSize = 'Free Size';
  static const String _defaultColorName = 'Default';

  final Product product;

  final RxnString selectedSize = RxnString();
  final Rxn<ProductColor> selectedColor = Rxn<ProductColor>();
  final RxInt quantity = 1.obs;
  final RxInt currentImageIndex = 0.obs;
  final RxBool isAddingToCart = false.obs;

  ProductDetailController({required this.product}) {
    selectedSize.value = product.sizes.isNotEmpty
        ? product.sizes.first
        : _defaultSize;
    selectedColor.value = product.colors.isNotEmpty
        ? product.colors.first
        : ProductColor(name: _defaultColorName, hex: '#000000');
  }

  void selectSize(String size) => selectedSize.value = size;
  void selectColor(ProductColor color) => selectedColor.value = color;
  void setImageIndex(int index) => currentImageIndex.value = index;

  void incrementQuantity() {
    if (quantity.value < product.stock) quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }

  Future<void> addToCart() async {
    final size = selectedSize.value ?? _defaultSize;
    final color = selectedColor.value ??
        ProductColor(name: _defaultColorName, hex: '#000000');

    isAddingToCart.value = true;

    try {
      await CartService.addToCart(
        productId: product.id,
        quantity: quantity.value,
        selectedSize: size,
        selectedColorName: color.name,
        selectedColorHex: color.hex,
      );

      _showSnackBar('បានបន្ថែមទៅកន្ត្រកដោយជោគជ័យ');
      Get.back();
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      isAddingToCart.value = false;
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'មានបញ្ហា' : 'ជោគជ័យ',
      message,
      backgroundColor: isError ? AppTheme.errorRed : AppTheme.successGreen,
      colorText: Colors.white,
    );
  }
}