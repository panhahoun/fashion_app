import 'dart:async';
import 'dart:convert';

import 'package:fashion_app/core/api_config.dart';
import 'package:fashion_app/core/user_session.dart';
import 'package:http/http.dart' as http;

//api service, api exception
class ApiService {
  static const Duration timeout = Duration(seconds: 30);

  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (UserSession.authToken != null)
        'Authorization': 'Bearer ${UserSession.authToken}',
    };
  }

  static Future<T> handleRequest<T>(
    Future<http.Response> Function() request,
    T Function(Map<String, dynamic>) parser,
  ) async {
    try {
      final response = await request().timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return parser(data);
        } else {
          throw ApiException(data['message'] ?? 'Unknown error');
        }
      } else if (response.statusCode == 401) {
        throw ApiException('Unauthorized. Please login again.');
      } else {
        throw ApiException('Server error: ${response.statusCode}');
      }
    } on TimeoutException {
      throw ApiException('Connection timeout. Please check your internet.');
    } on http.ClientException catch (e) {
      // Include API URL to make connection issues easier to diagnose.
      throw ApiException(
        'Network error: ${e.message}\nAPI: ${ApiConfig.baseUrl}',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error: $e');
    }
  }

  // Auth APIs

  // Products APIs

  // Cart APIs

  // Orders APIs

  // Categories API
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
