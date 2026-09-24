import 'dart:async';

import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/favorites_store.dart';
import 'package:fashion_app/core/user_session.dart';
import 'package:fashion_app/screens/favorites_screen.dart';
import 'package:fashion_app/models/product.dart';
import 'package:fashion_app/services/api/cart_service.dart';
import 'package:fashion_app/services/api/product_service.dart';
import 'package:fashion_app/widgets/product_card.dart';
import 'package:flutter/material.dart';

enum _SortMode { popular, newest, priceLowToHigh, priceHighToLow, name }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'ទាំងអស់';
  _SortMode _sortMode = _SortMode.popular;

  @override
  void initState() {
    super.initState();
    _initializeHome();
  }

  Future<void> _initializeHome() async {
    await FavoritesStore.load();
    if (!mounted) return;
    await _loadProducts();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await ProductService.getAllProducts();
      for (final product in products) {
        product.isFavorite = FavoritesStore.isFavorite(product.id);
      }
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = value.trim().toLowerCase();
      });
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchDebounce?.cancel();
    setState(() {
      _searchQuery = '';
    });
  }

  Future<void> _toggleFavorite(Product product) async {
    final next = !product.isFavorite;
    setState(() {
      product.isFavorite = next;
    });
    await FavoritesStore.setFavorite(product.id, next);
  }

  Future<void> _addProductToCart(Product product) async {
    if (product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.errorRed,
          content: Text('ផលិតផលនេះអស់ស្តុក'),
        ),
      );
      return;
    }

    final selectedSize = product.sizes.isNotEmpty
        ? product.sizes.first
        : 'One Size';
    final selectedColor = product.colors.isNotEmpty
        ? product.colors.first
        : ProductColor(name: 'Default', hex: '#000000');

    try {
      await CartService.addToCart(
        userId: UserSession.userId,
        productId: product.id,
        quantity: 1,
        selectedSize: selectedSize,
        selectedColorName: selectedColor.name,
        selectedColorHex: selectedColor.hex,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.errorRed,
          content: Text(e.toString()),
        ),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.successGreen,
        duration: const Duration(milliseconds: 900),
        content: Text('បានបន្ថែម ${product.nameKhmer} ទៅកន្ត្រក'),
      ),
    );
  }

  List<String> get _categories {
    final categories = _products
        .map((p) => p.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ['ទាំងអស់', ...categories];
  }

  List<Product> get _displayedProducts {
    Iterable<Product> products = _products;

    if (_selectedCategory != 'ទាំងអស់') {
      products = products.where(
        (product) => product.category.trim() == _selectedCategory,
      );
    }

    if (_searchQuery.isNotEmpty) {
      products = products.where((product) {
        final kh = product.nameKhmer.toLowerCase();
        final en = product.nameEnglish.toLowerCase();
        final category = product.category.toLowerCase();
        return kh.contains(_searchQuery) ||
            en.contains(_searchQuery) ||
            category.contains(_searchQuery);
      });
    }

    final result = products.toList();
    switch (_sortMode) {
      case _SortMode.popular:
        result.sort((a, b) {
          final ratingCompare = b.rating.compareTo(a.rating);
          if (ratingCompare != 0) return ratingCompare;
          return b.reviews.compareTo(a.reviews);
        });
      case _SortMode.newest:
        result.sort((a, b) => b.id.compareTo(a.id));
      case _SortMode.priceLowToHigh:
        result.sort((a, b) => a.price.compareTo(b.price));
      case _SortMode.priceHighToLow:
        result.sort((a, b) => b.price.compareTo(a.price));
      case _SortMode.name:
        result.sort((a, b) => a.nameKhmer.compareTo(b.nameKhmer));
    }

    return result;
  }

  String _sortLabel(_SortMode mode) {
    switch (mode) {
      case _SortMode.popular:
        return 'ពេញនិយម';
      case _SortMode.newest:
        return 'ថ្មីបំផុត';
      case _SortMode.priceLowToHigh:
        return 'តម្លៃទាបទៅខ្ពស់';
      case _SortMode.priceHighToLow:
        return 'តម្លៃខ្ពស់ទៅទាប';
      case _SortMode.name:
        return 'ឈ្មោះ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedProducts = _displayedProducts;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth >= 960
        ? 4
        : screenWidth >= 720
        ? 3
        : 2;

    return Scaffold(
      backgroundColor: AppTheme.softPeach,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeroHeader()),
            SliverToBoxAdapter(child: _buildCategorySection()),
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildErrorWidget(),
              )
            else if (displayedProducts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    '${displayedProducts.length} ផលិតផល',
                    style: const TextStyle(
                      color: AppTheme.mediumGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.66,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = displayedProducts[index];
                    return ProductCard(
                      product: product,
                      onFavoriteToggle: () {
                        _toggleFavorite(product);
                      },
                      onAddToCart: product.stock > 0
                          ? () => _addProductToCart(product)
                          : null,
                    );
                  }, childCount: displayedProducts.length),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFFFF4EC)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryOrange,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'សួស្ដី, ${UserSession.userName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'ជ្រើសរើសម៉ូដដែលសាកសមសម្រាប់ថ្ងៃនេះ',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppTheme.darkGray,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border_rounded, size: 24),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FavoritesScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 26),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(fontSize: 16, color: AppTheme.darkGray),
            decoration: InputDecoration(
              hintText: 'ស្វែងរកផលិតផល ឬ ប្រភេទ...',
              hintStyle: const TextStyle(
                fontSize: 16,
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: const Icon(Icons.search, size: 28),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 22),
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSortControl()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    if (_categories.length <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = _categories[index];
            final selected = category == _selectedCategory;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: EdgeInsets.symmetric(
                  horizontal: selected ? 12 : 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primaryOrange : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppTheme.primaryOrange : const Color(0xFFE5E5E5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selected) ...[
                      const Icon(Icons.check_rounded, size: 15, color: Colors.white),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : AppTheme.darkGray,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSortControl() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _openSortSheet,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.sort_rounded, size: 20, color: AppTheme.darkGray),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _sortLabel(_sortMode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkGray,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.mediumGray),
          ],
        ),
      ),
    );
  }

  Future<void> _openSortSheet() async {
    final selected = await showModalBottomSheet<_SortMode>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(height: 14),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'តម្រៀបតាម',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                ..._SortMode.values.map((mode) {
                  final active = _sortMode == mode;
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      active ? Icons.check_circle : Icons.circle_outlined,
                      color: active ? AppTheme.primaryOrange : AppTheme.mediumGray,
                    ),
                    title: Text(
                      _sortLabel(mode),
                      style: TextStyle(
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(mode),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _sortMode = selected;
      });
    }
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 72, color: AppTheme.errorRed),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'មានបញ្ហា',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: AppTheme.darkGray),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh),
            label: const Text('សាកល្បងម្ដងទៀត'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 72,
            color: AppTheme.mediumGray,
          ),
          const SizedBox(height: 12),
          const Text(
            'រកមិនឃើញផលិតផលដែលត្រូវលក្ខខណ្ឌទេ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppTheme.darkGray),
          ),
        ],
      ),
    );
  }
}
