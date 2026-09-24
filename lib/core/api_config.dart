import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Read full API base URL from .env (API_BASE_URL), e.g.
  // API_BASE_URL=http://10.0.2.2:8000/api
  static String get baseUrl {
    final envUrl = dotenv.maybeGet('API_BASE_URL')?.trim() ?? '';
    if (envUrl.isNotEmpty) return envUrl;

    // Fallback when .env is missing or API_BASE_URL is not set.
    if (kIsWeb) return 'http://localhost:8000/api';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8000/api'
        : 'http://localhost:8000/api';
  }

  // Alternative configurations:
  // Android Emulator: 'http://10.0.2.2:8000/api'
  // iOS Simulator:    'http://localhost:8000/api'
  // Real Device:      'http://YOUR_COMPUTER_IP:8000/api'
  // Production:       'https://yourdomain.com/api'

  // Endpoints
  static String get authEndpoint => '$baseUrl/auth';
  static String get productsEndpoint => '$baseUrl/products';
  static String get cartEndpoint => '$baseUrl/cart';
  static String get ordersEndpoint => '$baseUrl/orders';
  static String get categoriesEndpoint => '$baseUrl/categories';

  // Timeouts
  static const Duration timeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
}