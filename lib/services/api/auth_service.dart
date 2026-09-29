import 'package:fashion_app/core/network/dio_client.dart';
import 'package:fashion_app/services/api/api_service.dart';

class AuthService {
  // FastAPI returns {"access_token", "token_type", "user": {...}}.
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      ),
      (data) => data as Map<String, dynamic>,
    );
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        },
      ),
      (data) => data as Map<String, dynamic>,
    );
  }

  /// Current user from the server (source of truth for the profile screen).
  static Future<Map<String, dynamic>> me() {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.get('/auth/me'),
      (data) => data as Map<String, dynamic>,
    );
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
  }) {
    return ApiService.handleRequest(
      () => DioClient.instance.dio.put(
        '/auth/me',
        data: {'name': name, 'phone': phone},
      ),
      (data) => data as Map<String, dynamic>,
    );
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ApiService.handleRequest<dynamic>(
      () => DioClient.instance.dio.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      ),
      (_) {},
    );
  }
}