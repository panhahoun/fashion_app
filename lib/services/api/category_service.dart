import 'package:fashion_app/core/network/dio_client.dart';
import 'package:fashion_app/models/category.dart';
import 'package:fashion_app/services/api/api_service.dart';

class CategoryService {
  static Future<List<Category>> getAllCategories() {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.get('/categories'),
      (data) {
        return [
          for (final item in (data as List))
            Category.fromJson(item as Map<String, dynamic>),
        ];
      },
    );
  }
}