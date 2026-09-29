import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/localization/localized_content.dart';
import 'package:fashion_app/core/routes/app_routes.dart';
import 'package:fashion_app/models/address.dart';
import 'package:fashion_app/services/api/address_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressesController extends GetxController {
  final RxList<Address> addresses = <Address>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  Address? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  Future<void> loadAddresses() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      addresses.assignAll(await AddressService.getAddresses());
    } catch (e) {
      errorMessage.value = localizedErrorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveAddress({
    Address? existing,
    required String label,
    required String recipientName,
    required String phone,
    required String detail,
    required bool isDefault,
  }) async {
    try {
      if (existing == null) {
        await AddressService.createAddress(
          label: label,
          recipientName: recipientName,
          phone: phone,
          detail: detail,
          isDefault: isDefault,
        );
      } else {
        await AddressService.updateAddress(
          existing.id,
          label: label,
          recipientName: recipientName,
          phone: phone,
          detail: detail,
          isDefault: isDefault || existing.isDefault,
        );
      }
      await loadAddresses();
      _toast('address_saved'.tr, isError: false);
    } catch (e) {
      _toast(localizedErrorMessage(e), isError: true);
    }
  }

  Future<void> makeDefault(Address address) async {
    if (address.isDefault) return;
    try {
      await AddressService.makeDefault(address);
      await loadAddresses();
      _toast('default_address_set'.tr, isError: false);
    } catch (e) {
      _toast(localizedErrorMessage(e), isError: true);
    }
  }

  Future<void> deleteAddress(Address address) async {
    try {
      await AddressService.deleteAddress(address.id);
      await loadAddresses();
      _toast('address_deleted'.tr, isError: false);
    } catch (e) {
      _toast(localizedErrorMessage(e), isError: true);
    }
  }

  Future<void> confirmDelete(Address address) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('delete_address'.tr),
        content: Text('delete_address_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
    if (confirmed == true) await deleteAddress(address);
  }

  void openForm({Address? existing}) {
    Get.toNamed(
      AppRoutes.addressForm,
      arguments: existing,
    );
  }

  void _toast(String message, {required bool isError}) {
    Get.snackbar(
      isError ? 'error'.tr : 'success'.tr,
      message,
      backgroundColor: isError ? AppTheme.errorRed : AppTheme.successGreen,
      colorText: Colors.white,
    );
  }
}
