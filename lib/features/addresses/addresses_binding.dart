import 'package:fashion_app/features/addresses/address_form_controller.dart';
import 'package:fashion_app/features/addresses/addresses_controller.dart';
import 'package:get/get.dart';

class AddressesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressesController>(() => AddressesController());
    // The form is pushed on top of the list and talks back to the list
    // controller, so the form controller itself is never registered.
  }
}

class AddressFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressFormController>(() => AddressFormController());
  }
}
