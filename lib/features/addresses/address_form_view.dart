import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/features/addresses/address_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressFormView extends GetView<AddressFormController> {
  const AddressFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final isEditing = controller.editing != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F1),
      appBar: AppBar(
        title: Text(isEditing ? 'edit_address'.tr : 'add_address'.tr),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F5F1),
        elevation: 0,
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            TextFormField(
              controller: controller.labelController,
              textInputAction: TextInputAction.next,
              decoration: controller.decoration(
                label: 'address_label'.tr,
                icon: Icons.bookmark_border,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller.recipientController,
              textInputAction: TextInputAction.next,
              decoration: controller.decoration(
                label: 'recipient_name'.tr,
                icon: Icons.person_outline,
              ),
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? 'enter_recipient'.tr
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: controller.decoration(
                label: 'phone_number'.tr,
                icon: Icons.phone_outlined,
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'enter_phone'.tr;
                if (text.length < 6) return 'invalid_phone'.tr;
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller.detailController,
              maxLines: 3,
              decoration: controller.decoration(
                label: 'address_info'.tr,
                icon: Icons.map_outlined,
              ),
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? 'enter_address_info'.tr
                  : null,
            ),
            const SizedBox(height: 18),
            Obx(
              () => SwitchListTile(
                value: controller.isDefault.value,
                onChanged: controller.setDefault,
                activeThumbColor: AppTheme.primary,
                title: Text('set_as_default_address'.tr),
                subtitle: Text(
                  'will_be_used_at_checkout'.tr,
                  style: TextStyle(fontSize: 12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      controller.isSaving.value ? null : controller.save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'save'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
