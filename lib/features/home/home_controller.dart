import 'dart:async';

import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/localization/localized_content.dart';
import 'package:fashion_app/core/localization/locale_controller.dart';
import 'package:fashion_app/core/stores/favorites_store_controller.dart';
import 'package:fashion_app/features/cart/cart_controller.dart';
import 'package:fashion_app/models/product.dart';
import 'package:fashion_app/services/api/cart_service.dart';
import 'package:fashion_app/services/api/product_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SortMode { popular, newest, priceLowToHigh, priceHighToLow, name }

class HomeController extends GetxController {
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final RxString searchQuery = ''.obs;
  static const String allCategoryValue = '__all__';

  final RxString selectedCategory = allCategoryValue.obs;
  final Rx<SortMode> sortMode = SortMode.popular.obs;

  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    _initializeHome();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> _initializeHome() async {
    await Get.find<FavoritesStoreController>().load();
    await loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await ProductService.getAllProducts();
      final favorites = Get.find<FavoritesStoreController>();
      for (final product in result) {
        product.isFavorite = favorites.isFavorite(product.id);
      }
      products.value = result;
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = localizedErrorMessage(e);
      isLoading.value = false;
    }
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = value.trim().toLowerCase();
    });
  }

  void clearSearch() {
    searchController.clear();
    _searchDebounce?.cancel();
    searchQuery.value = '';
  }

  Future<void> toggleFavorite(Product product) async {
    final next = !product.isFavorite;
    product.isFavorite = next;
    await Get.find<FavoritesStoreController>().setFavorite(product.id, next);
    products.refresh();
  }

  Future<void> addProductToCart(Product product) async {
    if (product.stock <= 0) {
      Get.snackbar(
        'out_of_stock'.tr,
        'out_of_stock'.tr,
        backgroundColor: AppTheme.errorRed,
        colorText: Colors.white,
      );
      return;
    }

    final selectedSize =
        product.sizes.isNotEmpty ? product.sizes.first : 'One Size';
    final selectedColor = product.colors.isNotEmpty
        ? product.colors.first
        : ProductColor(name: 'Default', hex: '#000000');

    try {
      await CartService.addToCart(
        productId: product.id,
        quantity: 1,
        selectedSize: selectedSize,
        selectedColorName: selectedColor.name,
        selectedColorHex: selectedColor.hex,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        localizedErrorMessage(e),
        backgroundColor: AppTheme.errorRed,
        colorText: Colors.white,
      );
      return;
    }

    if (Get.isRegistered<CartController>()) {
      await Get.find<CartController>().refreshCart();
    }

    Get.closeCurrentSnackbar();
    Get.snackbar(
      'success'.tr,
      'added_name_to_cart'.trParams({
        'name': localizedContent(
          khmer: product.nameKhmer,
          english: product.nameEnglish,
        ),
      }),
      backgroundColor: AppTheme.successGreen,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 900),
    );
  }

  List<String> get categories {
    final categoryList = products
        .map((p) => p.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return [allCategoryValue, ...categoryList];
  }

  List<Product> get displayedProducts {
    Iterable<Product> result = products;

    if (selectedCategory.value != allCategoryValue) {
      result = result.where(
        (product) => product.category.trim() == selectedCategory.value,
      );
    }

    if (searchQuery.value.isNotEmpty) {
      result = result.where((product) {
        final kh = product.nameKhmer.toLowerCase();
        final en = product.nameEnglish.toLowerCase();
        final category = localizedCategory(product.category).toLowerCase();
        return kh.contains(searchQuery.value) ||
            en.contains(searchQuery.value) ||
            category.contains(searchQuery.value);
      });
    }

    final list = result.toList();
    switch (sortMode.value) {
      case SortMode.popular:
        list.sort((a, b) {
          final ratingCompare = b.rating.compareTo(a.rating);
          if (ratingCompare != 0) return ratingCompare;
          return b.reviews.compareTo(a.reviews);
        });
      case SortMode.newest:
        list.sort((a, b) => b.id.compareTo(a.id));
      case SortMode.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortMode.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SortMode.name:
        final isKhmer = Get.find<LocaleController>().isKhmer;
        list.sort(
          (a, b) => isKhmer
              ? a.nameKhmer.compareTo(b.nameKhmer)
              : a.nameEnglish.compareTo(b.nameEnglish),
        );
    }

    return list;
  }

  String sortLabel(SortMode mode) {
    switch (mode) {
      case SortMode.popular:
        return 'popular'.tr;
      case SortMode.newest:
        return 'newest'.tr;
      case SortMode.priceLowToHigh:
        return 'price_low_to_high'.tr;
      case SortMode.priceHighToLow:
        return 'price_high_to_low'.tr;
      case SortMode.name:
        return 'sort_name'.tr;
    }
  }

  void selectCategory(String category) => selectedCategory.value = category;
  void setSortMode(SortMode mode) => sortMode.value = mode;
}