import 'package:fashion_app/features/category_products/category_products_controller.dart';
import 'package:fashion_app/models/category.dart';
import 'package:get/get.dart';

class CategoryProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryProductsController>(
      () => CategoryProductsController(
        category: Get.arguments as Category,
      ),
    );
  }
}