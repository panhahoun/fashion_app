import 'dart:async';

import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/stores/favorites_store_controller.dart';
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
  final RxString selectedCategory = 'ទាំងអស់'.obs;
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
      errorMessage.value = e.toString();
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
        'អស់ស្តុក',
        'ផលិតផលនេះអស់ស្តុក',
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
        'មានបញ្ហា',
        e.toString(),
        backgroundColor: AppTheme.errorRed,
        colorText: Colors.white,
      );
      return;
    }

    Get.closeCurrentSnackbar();
    Get.snackbar(
      'ជោគជ័យ',
      'បានបន្ថែម ${product.nameKhmer} ទៅកន្ត្រក',
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
    return ['ទាំងអស់', ...categoryList];
  }

  List<Product> get displayedProducts {
    Iterable<Product> result = products;

    if (selectedCategory.value != 'ទាំងអស់') {
      result = result.where(
        (product) => product.category.trim() == selectedCategory.value,
      );
    }

    if (searchQuery.value.isNotEmpty) {
      result = result.where((product) {
        final kh = product.nameKhmer.toLowerCase();
        final en = product.nameEnglish.toLowerCase();
        final category = product.category.toLowerCase();
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
        list.sort((a, b) => a.nameKhmer.compareTo(b.nameKhmer));
    }

    return list;
  }

  String sortLabel(SortMode mode) {
    switch (mode) {
      case SortMode.popular:
        return 'ពេញនិយម';
      case SortMode.newest:
        return 'ថ្មីបំផុត';
      case SortMode.priceLowToHigh:
        return 'តម្លៃទាបទៅខ្ពស់';
      case SortMode.priceHighToLow:
        return 'តម្លៃខ្ពស់ទៅទាប';
      case SortMode.name:
        return 'ឈ្មោះ';
    }
  }

  void selectCategory(String category) => selectedCategory.value = category;
  void setSortMode(SortMode mode) => sortMode.value = mode;
}