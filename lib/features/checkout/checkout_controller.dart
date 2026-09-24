import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/stores/session_controller.dart';
import 'package:fashion_app/features/cart/cart_controller.dart';
import 'package:fashion_app/models/cart_item.dart';
import 'package:fashion_app/services/api/order_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final RxString paymentMethod = 'សាច់ប្រាក់'.obs;
  final RxBool isProcessing = false.obs;

  late List<CartItem> cartItems;
  late double total;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    cartItems = (args['cartItems'] as List).cast<CartItem>();
    total = args['total'] as double;

    final session = Get.find<SessionController>();
    nameController.text = session.userName.value;
    phoneController.text = session.userPhone.value;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }

  void selectPaymentMethod(String? method) {
    if (method != null) paymentMethod.value = method;
  }

  Future<void> placeOrder() async {
    if (!formKey.currentState!.validate()) return;

    isProcessing.value = true;

    try {
      final items = cartItems.map((item) {
        return {
          'product_id': item.productId,
          'quantity': item.quantity,
          'selected_size': item.selectedSize,
          'selected_color_name': item.selectedColorName,
        };
      }).toList();

      await OrderService.createOrder(
        customerName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        paymentMethod: paymentMethod.value,
        items: items,
      );

      Get.snackbar(
        'ជោគជ័យ',
        'ការបញ្ជាទិញបានបញ្ជាក់ដោយជោគជ័យ',
        backgroundColor: AppTheme.successGreen,
        colorText: Colors.white,
      );

      // Refresh the cart tab so the emptied cart is up to date.
      Get.find<CartController>().refreshCart();
      Get.until((route) => route.isFirst);
    } catch (e) {
      Get.snackbar(
        'មានបញ្ហា',
        e.toString(),
        backgroundColor: AppTheme.errorRed,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }
}