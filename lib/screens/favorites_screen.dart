import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/favorites_store.dart';
import 'package:fashion_app/core/user_session.dart';
import 'package:fashion_app/models/product.dart';
import 'package:fashion_app/services/api/cart_service.dart';
import 'package:fashion_app/services/api/product_service.dart';
import 'package:fashion_app/widgets/product_card.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Product> _allProducts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FavoritesStore.load();
      final products = await ProductService.getAllProducts();
      for (final product in products) {
        product.isFavorite = FavoritesStore.isFavorite(product.id);
      }
      if (!mounted) return;
      setState(() {
        _allProducts = products;
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

  List<Product> get _favoriteProducts {
    return _allProducts.where((product) => product.isFavorite).toList();
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.successGreen,
          content: Text('បានបន្ថែម ${product.nameKhmer} ទៅកន្ត្រក'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.errorRed,
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _favoriteProducts;
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 960
        ? 4
        : width >= 720
        ? 3
        : 2;

    return Scaffold(
      backgroundColor: AppTheme.softPeach,
      appBar: AppBar(
        title: const Text('ផលិតផលដែលចូលចិត្ត'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildError()
          : favorites.isEmpty
          ? _buildEmpty()
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: GridView.builder(
                itemCount: favorites.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.66,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final product = favorites[index];
                  return ProductCard(
                    product: product,
                    onFavoriteToggle: () => _toggleFavorite(product),
                    onAddToCart: () => _addProductToCart(product),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
            const SizedBox(height: 12),
            Text(_errorMessage ?? 'មានបញ្ហា', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('ព្យាយាមម្តងទៀត'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 72, color: AppTheme.mediumGray),
            SizedBox(height: 12),
            Text(
              'មិនទាន់មានផលិតផលដែលចូលចិត្តទេ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppTheme.darkGray),
            ),
          ],
        ),
      ),
    );
  }
}
