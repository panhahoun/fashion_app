import 'package:fashion_app/core/network/dio_client.dart';
import 'package:fashion_app/models/product.dart';
import 'package:fashion_app/services/api/api_service.dart';

class ProductService {
  static List<Product> _parseList(dynamic data) {
    return [
      for (final item in (data as List))
        Product.fromJson(item as Map<String, dynamic>),
    ];
  }

  static Future<List<Product>> getAllProducts() {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.get('/products'),
      _parseList,
    );
  }

  static Future<Product> getProductById(int id) {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.get('/products/$id'),
      (data) => Product.fromJson(data as Map<String, dynamic>),
    );
  }

  static Future<List<Product>> searchProducts(String query) {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.get(
        '/products',
        queryParameters: {'search': query},
      ),
      _parseList,
    );
  }

  static Future<List<Product>> getProductsByCategory(String category) {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.get(
        '/products',
        queryParameters: {'category': category},
      ),
      _parseList,
    );
  }
}