import 'package:fashion_app/core/network/dio_client.dart';
import 'package:fashion_app/models/address.dart';
import 'package:fashion_app/services/api/api_service.dart';

class AddressService {
  static Future<List<Address>> getAddresses() {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.get('/addresses'),
      (data) => (data as List)
          .map((item) => Address.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<Address> createAddress({
    required String label,
    required String recipientName,
    required String phone,
    required String detail,
    bool isDefault = false,
  }) {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.post(
        '/addresses',
        data: {
          'label': label,
          'recipient_name': recipientName,
          'phone': phone,
          'detail': detail,
          'is_default': isDefault,
        },
      ),
      (data) => Address.fromJson(data as Map<String, dynamic>),
    );
  }

  static Future<Address> updateAddress(
    int id, {
    required String label,
    required String recipientName,
    required String phone,
    required String detail,
    bool isDefault = false,
  }) {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.put(
        '/addresses/$id',
        data: {
          'label': label,
          'recipient_name': recipientName,
          'phone': phone,
          'detail': detail,
          'is_default': isDefault,
        },
      ),
      (data) => Address.fromJson(data as Map<String, dynamic>),
    );
  }

  static Future<void> deleteAddress(int id) async {
    await ApiService.handleRequest<dynamic>(
      () => DioClient.instance.dio.delete('/addresses/$id'),
      (_) {},
    );
  }

  static Future<void> makeDefault(Address address) async {
    await ApiService.handleRequest<dynamic>(
      () => DioClient.instance.dio.put(
        '/addresses/${address.id}',
        data: {
          'label': address.label,
          'recipient_name': address.recipientName,
          'phone': address.phone,
          'detail': address.detail,
          'is_default': true,
        },
      ),
      (_) {},
    );
  }
}
