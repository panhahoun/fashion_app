import 'package:fashion_app/core/network/dio_client.dart';
import 'package:fashion_app/models/order.dart';
import 'package:fashion_app/services/api/api_service.dart';

class OrderService {
  static Future<List<Order>> getUserOrders() {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.get('/orders'),
      (data) {
        return [
          for (final item in (data as List))
            Order.fromJson(item as Map<String, dynamic>),
        ];
      },
    );
  }

  static Future<Map<String, dynamic>> createOrder({
    required String customerName,
    required String phone,
    required String address,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.post(
        '/orders',
        data: {
          'customer_name': customerName,
          'phone': phone,
          'address': address,
          'payment_method': paymentMethod,
          'items': items,
        },
      ),
      (data) => data as Map<String, dynamic>,
    );
  }
}