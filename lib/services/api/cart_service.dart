import 'dart:convert';

import 'package:fashion_app/core/api_config.dart';
import 'package:fashion_app/models/cart_item.dart';
import 'package:fashion_app/services/api/api_service.dart';
import 'package:http/http.dart' as http;

class CartService {
  static Future<List<CartItem>> getCartItems(int userId) async {
    return ApiService.handleRequest(
      () => http.get(
        Uri.parse('${ApiConfig.cartEndpoint}?user_id=$userId'),
        headers: ApiService.getHeaders(),
      ),
      (data) {
        List<CartItem> items = [];
        for (var item in data['data']) {
          items.add(CartItem.fromJson(item));
        }
        return items;
      },
    );
  }

  static Future<bool> addToCart({
    required int userId,
    required int productId,
    required int quantity,
    required String selectedSize,
    required String selectedColorName,
    required String selectedColorHex,
  }) async {
    return ApiService.handleRequest(
      () => http.post(
        Uri.parse(ApiConfig.cartEndpoint),
        headers: ApiService.getHeaders(),
        body: json.encode({
          'user_id': userId,
          'product_id': productId,
          'quantity': quantity,
          'selected_size': selectedSize,
          'selected_color_name': selectedColorName,
          'selected_color_hex': selectedColorHex,
        }),
      ),
      (data) => true,
    );
  }

  static Future<bool> updateCartItem(int cartId, int quantity) async {
    return ApiService.handleRequest(
      () => http.put(
        Uri.parse(ApiConfig.cartEndpoint),
        headers: ApiService.getHeaders(),
        body: json.encode({'id': cartId, 'quantity': quantity}),
      ),
      (data) => true,
    );
  }

  static Future<bool> removeFromCart(int cartId) async {
    return ApiService.handleRequest(
      () => http.delete(
        Uri.parse('${ApiConfig.cartEndpoint}?id=$cartId'),
        headers: ApiService.getHeaders(),
      ),
      (data) => true,
    );
  }
}
