import 'package:dio/dio.dart';
import 'package:fashion_app/core/api_config.dart';

/// In-memory holder for the current auth token.
///
/// The Dio interceptor reads this on every request so the token is always
/// attached without needing a circular dependency on the session store.
class AuthTokenHolder {
  static String? token;

  /// Invoked when an authenticated request is rejected with 401, so the app
  /// can clear the stale session and return to the login screen.
  static void Function()? onUnauthorized;
}

/// Central [Dio] instance with base URL, timeouts and an auth interceptor.
class DioClient {
  DioClient._();

  static final DioClient instance = DioClient._();

  late final Dio dio = Dio(
    BaseOptions(
      baseUrl: _normalizedBaseUrl,
      connectTimeout: ApiConfig.connectionTimeout,
      receiveTimeout: ApiConfig.timeout,
      sendTimeout: ApiConfig.timeout,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthTokenHolder.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final status = error.response?.statusCode;
          final path = error.requestOptions.path;
          // A 401 from the auth endpoints means bad credentials, not an
          // expired token, so it must not trigger a forced logout.
          final isAuthEndpoint =
              path.contains('/auth/login') || path.contains('/auth/register');
          if (status == 401 && !isAuthEndpoint) {
            AuthTokenHolder.onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );

  String get _normalizedBaseUrl {
    final url = ApiConfig.baseUrl.trim();
    if (url.endsWith('/')) return url.substring(0, url.length - 1);
    return url;
  }
}