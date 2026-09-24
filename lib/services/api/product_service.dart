import 'package:fashion_app/core/api_config.dart';
import 'package:fashion_app/models/product.dart';
import 'package:fashion_app/services/api/api_service.dart';
import 'package:http/http.dart' as http;

class ProductService {
  static Future<List<Product>> getAllProducts() async {
    return ApiService.handleRequest(
      () => http.get(
        Uri.parse(ApiConfig.productsEndpoint),
        headers: ApiService.getHeaders(),
      ),
      (data) {
        List<Product> products = [];
        for (var item in data['data']) {
          products.add(Product.fromJson(item));
        }
        return products;
      },
    );
  }

  static Future<Product> getProductById(int id) async {
    return ApiService.handleRequest(
      () => http.get(
        Uri.parse('${ApiConfig.productsEndpoint}?id=$id'),
        headers: ApiService.getHeaders(),
      ),
      (data) => Product.fromJson(data['data']),
    );
  }

  static Future<List<Product>> searchProducts(String query) async {
    return ApiService.handleRequest(
      () => http.get(
        Uri.parse('${ApiConfig.productsEndpoint}?search=$query'),
        headers: ApiService.getHeaders(),
      ),
      (data) {
        List<Product> products = [];
        for (var item in data['data']) {
          products.add(Product.fromJson(item));
        }
        return products;
      },
    );
  }

  static Future<List<Product>> getProductsByCategory(String category) async {
    return ApiService.handleRequest(
      () => http.get(
        Uri.parse('${ApiConfig.productsEndpoint}?category=$category'),
        headers: ApiService.getHeaders(),
      ),
      (data) {
        List<Product> products = [];
        for (var item in data['data']) {
          products.add(Product.fromJson(item));
        }
        return products;
      },
    );
  }
}
