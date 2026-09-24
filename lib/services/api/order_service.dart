import 'dart:convert';

import 'package:fashion_app/core/api_config.dart';
import 'package:fashion_app/models/order.dart';
import 'package:fashion_app/services/api/api_service.dart';
import 'package:http/http.dart' as http;

class OrderService {
  static Future<List<Order>> getUserOrders(int userId) async {
    return ApiService.handleRequest(
      () => http.get(
        Uri.parse('${ApiConfig.ordersEndpoint}?user_id=$userId'),
        headers: ApiService.getHeaders(),
      ),
      (data) {
        List<Order> orders = [];
        for (var item in data['data']) {
          orders.add(Order.fromJson(item));
        }
        return orders;
      },
    );
  }

  static Future<Map<String, dynamic>> createOrder({
    required int userId,
    required double totalAmount,
    required String customerName,
    required String phone,
    required String address,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    return ApiService.handleRequest(
      () => http.post(
        Uri.parse(ApiConfig.ordersEndpoint),
        headers: ApiService.getHeaders(),
        body: json.encode({
          'user_id': userId,
          'total_amount': totalAmount,
          'customer_name': customerName,
          'phone': phone,
          'address': address,
          'payment_method': paymentMethod,
          'items': items,
        }),
      ),
      (data) => data,
    );
  }
}
