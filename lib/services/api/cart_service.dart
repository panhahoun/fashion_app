import 'package:fashion_app/core/network/dio_client.dart';
import 'package:fashion_app/models/cart_item.dart';
import 'package:fashion_app/services/api/api_service.dart';

class CartService {
  static Future<List<CartItem>> getCartItems() {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.get('/cart'),
      (data) {
        return [
          for (final item in (data as List))
            CartItem.fromJson(item as Map<String, dynamic>),
        ];
      },
    );
  }

  static Future<bool> addToCart({
    required int productId,
    required int quantity,
    required String selectedSize,
    required String selectedColorName,
    required String selectedColorHex,
  }) {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.post(
        '/cart',
        data: {
          'product_id': productId,
          'quantity': quantity,
          'selected_size': selectedSize,
          'selected_color_name': selectedColorName,
          'selected_color_hex': selectedColorHex,
        },
      ),
      (data) => true,
    );
  }

  static Future<bool> updateCartItem(int cartId, int quantity) {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.put(
        '/cart/$cartId',
        data: {'quantity': quantity},
      ),
      (data) => true,
    );
  }

  static Future<bool> removeFromCart(int cartId) {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.delete('/cart/$cartId'),
      (data) => true,
    );
  }
}