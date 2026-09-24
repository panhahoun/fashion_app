import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Read full API URL from .env (API_BASE_URL), e.g.
  // API_BASE_URL=http://192.168.1.100/fashion_api_2/api
  static String get baseUrl {
    final envUrl = dotenv.maybeGet('API_BASE_URL')?.trim() ?? '';
    if (envUrl.isNotEmpty) return envUrl;

    // Fallback when .env is missing or API_BASE_URL is not set.
    if (kIsWeb) return 'API_BASE_URL';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2/fashion_api_3/api'
        : 'http://localhost/fashion_api_3/api';
  }

  // Alternative configurations:
  // Android Emulator: 'http://10.0.2.2/fashion_api_3/api'
  // iOS Simulator: 'http://localhost/fashion_api_3/api'
  // Real Device: 'http://YOUR_COMPUTER_IP/fashion_api_3/api'
  // Production: 'https://yourdomain.com/api'

  // Endpoints

  static String get authEndpoint => '$baseUrl/auth.php';
  static String get productsEndpoint => '$baseUrl/products.php';
  static String get cartEndpoint => '$baseUrl/cart.php';
  static String get ordersEndpoint => '$baseUrl/orders.php';
  static String get categoriesEndpoint => '$baseUrl/categories.php';
  static String get favoritesEndpoint => '$baseUrl/favorites.php';
  static String get profileEndpoint => '$baseUrl/profile.php';

  // Timeouts
  static const Duration timeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);
}
