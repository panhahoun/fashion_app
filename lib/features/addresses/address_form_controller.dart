import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/stores/session_controller.dart';
import 'package:fashion_app/features/addresses/addresses_controller.dart';
import 'package:fashion_app/models/address.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressFormController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController labelController = TextEditingController();
  final TextEditingController recipientController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController detailController = TextEditingController();
  final RxBool isDefault = false.obs;
  final RxBool isSaving = false.obs;

  Address? editing;

  AddressesController get _addressesController => Get.find<AddressesController>();

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    editing = arg is Address ? arg : null;

    if (editing != null) {
      labelController.text = editing!.label;
      recipientController.text = editing!.recipientName;
      phoneController.text = editing!.phone;
      detailController.text = editing!.detail;
      isDefault.value = editing!.isDefault;
    } else {
      // Pre-fill from the signed-in user; still editable before saving.
      final session = Get.find<SessionController>();
      recipientController.text = session.userName.value;
      phoneController.text = session.userPhone.value;
      isDefault.value = _addressesController.addresses.isEmpty;
    }
  }

  @override
  void onClose() {
    labelController.dispose();
    recipientController.dispose();
    phoneController.dispose();
    detailController.dispose();
    super.onClose();
  }

  void setDefault(bool value) => isDefault.value = value;

  Future<void> save() async {
    if (isSaving.value) return;
    if (!formKey.currentState!.validate()) return;

    isSaving.value = true;
    await _addressesController.saveAddress(
      existing: editing,
      label: labelController.text.trim(),
      recipientName: recipientController.text.trim(),
      phone: phoneController.text.trim(),
      detail: detailController.text.trim(),
      isDefault: isDefault.value,
    );
    isSaving.value = false;
    Get.back();
  }

  InputDecoration decoration({
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 21),
      filled: true,
      fillColor: const Color(0xFFF7F5F2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFF0EEEA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.4),
      ),
    );
  }
}
