import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/localization/localized_content.dart';
import 'package:fashion_app/core/stores/session_controller.dart';
import 'package:fashion_app/features/cart/cart_controller.dart';
import 'package:fashion_app/features/orders/orders_controller.dart';
import 'package:fashion_app/models/address.dart';
import 'package:fashion_app/models/cart_item.dart';
import 'package:fashion_app/services/api/address_service.dart';
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

  List<CartItem> cartItems = <CartItem>[];
  double total = 0;

  /// Saved addresses offered as one-tap fill for the delivery field.
  final RxList<Address> savedAddresses = <Address>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      final rawItems = args['cartItems'];
      if (rawItems is List) {
        cartItems = rawItems.whereType<CartItem>().toList();
      }
      final rawTotal = args['total'];
      if (rawTotal is num) total = rawTotal.toDouble();
    }

    // Fall back to the live cart when arguments are missing or malformed.
    if (cartItems.isEmpty && Get.isRegistered<CartController>()) {
      cartItems = List<CartItem>.from(Get.find<CartController>().cartItems);
    }
    if (total <= 0) {
      total = cartItems.fold(0.0, (sum, item) => sum + item.total);
    }

    final session = Get.find<SessionController>();
    nameController.text = session.userName.value;
    phoneController.text = session.userPhone.value;
    loadSavedAddresses();
  }

  /// Loads saved addresses and pre-fills the default one, so the common case
  /// needs no typing at all.
  Future<void> loadSavedAddresses() async {
    try {
      final addresses = await AddressService.getAddresses();
      savedAddresses.assignAll(addresses);
      for (final address in addresses) {
        if (address.isDefault) {
          applyAddress(address);
          break;
        }
      }
    } catch (_) {
      // Saved addresses are optional; manual entry still works.
    }
  }

  void applyAddress(Address address) {
    if (address.recipientName.isNotEmpty) {
      nameController.text = address.recipientName;
    }
    if (address.phone.isNotEmpty) {
      phoneController.text = address.phone;
    }
    addressController.text = address.detail;
  }

  Future<void> pickSavedAddress() async {
    if (savedAddresses.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'no_saved_addresses'.tr,
        backgroundColor: AppTheme.errorRed,
        colorText: Colors.white,
      );
      return;
    }

    final selected = await Get.bottomSheet<Address>(
      Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'select_address'.tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: savedAddresses
                    .map(
                      (address) => ListTile(
                        leading: const Icon(
                          Icons.location_on,
                          color: AppTheme.primary,
                        ),
                        title: Text(
                          address.label.isEmpty
                              ? 'address'.tr
                              : address.label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(address.detail, maxLines: 2),
                        trailing: address.isDefault
                            ? const Icon(
                                Icons.star,
                                color: AppTheme.accent,
                                size: 20,
                              )
                            : null,
                        onTap: () => Get.back(result: address),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );

    if (selected != null) applyAddress(selected);
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
    if (cartItems.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'your_cart_is_empty'.tr,
        backgroundColor: AppTheme.errorRed,
        colorText: Colors.white,
      );
      return;
    }

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
        'success'.tr,
        'order_placed'.tr,
        backgroundColor: AppTheme.successGreen,
        colorText: Colors.white,
      );

      // Refresh cart + orders so both tabs show post-purchase state.
      if (Get.isRegistered<CartController>()) {
        await Get.find<CartController>().refreshCart();
      }
      if (Get.isRegistered<OrdersController>()) {
        await Get.find<OrdersController>().loadOrders();
      }
      Get.until((route) => route.isFirst);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        localizedErrorMessage(e),
        backgroundColor: AppTheme.errorRed,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }
}