import 'dart:convert';

import 'package:fashion_app/core/api_config.dart';
import 'package:fashion_app/services/api/api_service.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    return ApiService.handleRequest(
      () => http.post(
        Uri.parse(ApiConfig.authEndpoint),
        headers: ApiService.getHeaders(),
        body: json.encode({
          'action': 'login',
          'email': email,
          'password': password,
        }),
      ),
      (data) => data['data'],
    );
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    return ApiService.handleRequest(
      () => http.post(
        Uri.parse(ApiConfig.authEndpoint),
        headers: ApiService.getHeaders(),
        body: json.encode({
          'action': 'register',
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      ),
      (data) => data['data'],
    );
  }
}
