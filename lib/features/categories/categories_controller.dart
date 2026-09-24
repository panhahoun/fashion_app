import 'package:fashion_app/core/routes/app_routes.dart';
import 'package:fashion_app/models/category.dart';
import 'package:fashion_app/services/api/category_service.dart';
import 'package:get/get.dart';

class CategoriesController extends GetxController {
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await CategoryService.getAllCategories();
      categories.value = result;
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
    }
  }

  void openCategory(Category category) {
    Get.toNamed(AppRoutes.categoryProducts, arguments: category);
  }
}