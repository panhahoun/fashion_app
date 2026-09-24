import 'package:fashion_app/core/routes/app_routes.dart';
import 'package:fashion_app/models/category.dart';
import 'package:fashion_app/models/product.dart';
import 'package:fashion_app/services/api/product_service.dart';
import 'package:get/get.dart';

class CategoryProductsController extends GetxController {
  final Category category;

  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  CategoryProductsController({required this.category});

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await ProductService.getProductsByCategory(
        category.nameKhmer,
      );
      products.value = result;
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
    }
  }

  void openProduct(Product product) {
    Get.toNamed(AppRoutes.productDetail, arguments: product);
  }
}