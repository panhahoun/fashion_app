import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fashion_app/core/api_config.dart';

/// Shared Dio request wrapper + typed exception.
///
/// FastAPI returns raw JSON (not a {success, data} envelope), so parsers read
/// values straight off the response body.
class ApiService {
  static Future<T> handleRequest<T>(
    Future<Response<dynamic>> Function() request,
    T Function(dynamic data) parser,
  ) async {
    try {
      final response = await request().timeout(ApiConfig.timeout);
      return parser(response.data);
    } on TimeoutException {
      throw ApiException('Connection timeout. Please check your internet.');
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      throw ApiException('Error: $e');
    }
  }

  static ApiException _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (status == 401) {
      return ApiException('Unauthorized. Please login again.');
    }

    // FastAPI errors look like {"detail": "..."} — surface that message.
    if (data is Map && data['detail'] != null) {
      final detail = data['detail'];
      return ApiException(detail is String ? detail : detail.toString());
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timeout. Please check your internet.');
      case DioExceptionType.connectionError:
        return ApiException(
          'Network error: ${e.message}\nAPI: ${ApiConfig.baseUrl}',
        );
      default:
        return ApiException('Server error: ${status ?? 'unknown'}');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}