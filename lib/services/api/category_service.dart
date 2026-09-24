import 'package:fashion_app/core/api_config.dart';
import 'package:fashion_app/models/category.dart';
import 'package:fashion_app/services/api/api_service.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  static Future<List<Category>> getAllCategories() async {
    return ApiService.handleRequest(
      () => http.get(
        Uri.parse(ApiConfig.categoriesEndpoint),
        headers: ApiService.getHeaders(),
      ),
      (data) {
        List<Category> categories = [];
        for (var item in data['data']) {
          categories.add(Category.fromJson(item));
        }
        return categories;
      },
    );
  }
}
