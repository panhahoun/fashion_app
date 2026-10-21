import 'package:fashion_app/features/addresses/address_form_controller.dart';
import 'package:fashion_app/features/addresses/addresses_controller.dart';
import 'package:get/get.dart';

class AddressesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressesController>(() => AddressesController());
    // The form talks back to the list controller; it is not registered itself.
  }
}

class AddressFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressFormController>(() => AddressFormController());
  }
}
