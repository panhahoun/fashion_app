import 'package:fashion_app/core/routes/app_routes.dart';
import 'package:fashion_app/features/category_products/category_products_binding.dart';
import 'package:fashion_app/features/category_products/category_products_view.dart';
import 'package:fashion_app/features/checkout/checkout_binding.dart';
import 'package:fashion_app/features/checkout/checkout_view.dart';
import 'package:fashion_app/features/favorites/favorites_binding.dart';
import 'package:fashion_app/features/favorites/favorites_view.dart';
import 'package:fashion_app/features/login/login_binding.dart';
import 'package:fashion_app/features/login/login_view.dart';
import 'package:fashion_app/features/main_navigation/main_navigation_binding.dart';
import 'package:fashion_app/features/main_navigation/main_navigation_view.dart';
import 'package:fashion_app/features/product_detail/product_detail_binding.dart';
import 'package:fashion_app/features/product_detail/product_detail_view.dart';
import 'package:fashion_app/features/register/register_binding.dart';
import 'package:fashion_app/features/register/register_view.dart';
import 'package:fashion_app/features/splash/splash_binding.dart';
import 'package:fashion_app/features/splash/splash_view.dart';
import 'package:get/get.dart';

abstract class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainNavigationView(),
      binding: MainNavigationBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailView(),
      binding: ProductDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.categoryProducts,
      page: () => const CategoryProductsView(),
      binding: CategoryProductsBinding(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesView(),
      binding: FavoritesBinding(),
    ),
  ];
}