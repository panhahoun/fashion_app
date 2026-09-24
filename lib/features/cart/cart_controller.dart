import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/routes/app_routes.dart';
import 'package:fashion_app/models/cart_item.dart';
import 'package:fashion_app/services/api/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  Future<void> loadCart() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final items = await CartService.getCartItems();
      cartItems.value = items;
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
    }
  }

  Future<void> refreshCart() async {
    await loadCart();
  }

  Future<void> updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1 || newQuantity > item.stock) return;

    try {
      await CartService.updateCartItem(item.id, newQuantity);
      // Reload cart to get fresh data from server.
      await loadCart();
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    }
  }

  Future<void> removeItem(CartItem item) async {
    try {
      await CartService.removeFromCart(item.id);
      // Reload cart to get fresh data from server.
      await loadCart();
      _showSnackBar('លុបផលិតផលដោយជោគជ័យ');
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
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

  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + item.total);
  }

  Future<void> proceedToCheckout() async {
    if (cartItems.isEmpty) {
      _showSnackBar('កន្ត្រករបស់អ្នកទទេ', isError: true);
      return;
    }

    await Get.toNamed(
      AppRoutes.checkout,
      arguments: {
        'cartItems': cartItems.toList(),
        'total': subtotal,
      },
    );
    await loadCart();
  }
}