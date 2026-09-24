import 'package:fashion_app/features/product_detail/product_detail_controller.dart';
import 'package:fashion_app/models/product.dart';
import 'package:get/get.dart';

class ProductDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductDetailController>(
      () => ProductDetailController(
        product: Get.arguments as Product,
      ),
    );
  }
}