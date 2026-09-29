import 'package:fashion_app/models/order.dart';
import 'package:fashion_app/core/localization/localized_content.dart';
import 'package:fashion_app/services/api/order_service.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  final RxList<Order> orders = <Order>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await OrderService.getUserOrders();
      orders.value = result;
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = localizedErrorMessage(e);
      isLoading.value = false;
    }
  }
}