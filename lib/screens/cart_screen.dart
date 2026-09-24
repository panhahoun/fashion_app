import 'package:cached_network_image/cached_network_image.dart';
import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/core/user_session.dart';
import 'package:fashion_app/models/cart_item.dart';
import 'package:fashion_app/screens/checkout_screen.dart';
import 'package:fashion_app/services/api/cart_service.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only reload if not currently loading to avoid duplicate requests
    if (mounted && !_isLoading) {
      _loadCart();
    }
  }

  Future<void> _loadCart() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await CartService.getCartItems(UserSession.userId);
      if (mounted) {
        setState(() {
          _cartItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> refreshCart() async {
    await _loadCart();
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1 || newQuantity > item.stock) return;

    try {
      await CartService.updateCartItem(item.id, newQuantity);
      // Reload cart to get fresh data from server
      await _loadCart();
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    }
  }

  Future<void> _removeItem(CartItem item) async {
    try {
      await CartService.removeFromCart(item.id);
      // Reload cart to get fresh data from server
      await _loadCart();
      _showSnackBar('លុបផលិតផលដោយជោគជ័យ');
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorRed : AppTheme.successGreen,
      ),
    );
  }

  double get _subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.total);
  }

  void _proceedToCheckout() {
    if (_cartItems.isEmpty) {
      _showSnackBar('កន្ត្រករបស់អ្នកទទេ', isError: true);
      return;
    }

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) {
              return CheckoutScreen(cartItems: _cartItems, total: _subtotal);
            },
          ),
        )
        .then((_) => _loadCart());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softPeach,
      appBar: AppBar(
        title: const Text('កន្ត្រក'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : _cartItems.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      return _buildCartItem(_cartItems[index]);
                    },
                  ),
                ),
                _buildCheckoutBar(),
              ],
            ),
    );
  }

  Widget _buildErrorState() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorRed,
                ),
                const SizedBox(height: 16),
                Text(_errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadCart,
                  child: const Text('ព្យាយាមម្តងទៀត'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 100,
                  color: AppTheme.mediumGray.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'កន្ត្រករបស់អ្នកទទេ',
                  style: TextStyle(fontSize: 18, color: AppTheme.mediumGray),
                ),
                const SizedBox(height: 8),
                const Text(
                  'សូមបន្ថែមផលិតផលពីទំព័រដើម',
                  style: TextStyle(fontSize: 14, color: AppTheme.mediumGray),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.lightGray,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.lightGray,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nameKhmer,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ទំហំ: ${item.selectedSize} | ពណ៌: ${item.selectedColorName}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                _updateQuantity(item, item.quantity - 1),
                            icon: const Icon(Icons.remove_circle_outline),
                            iconSize: 24,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              item.quantity.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _updateQuantity(item, item.quantity + 1),
                            icon: const Icon(Icons.add_circle_outline),
                            iconSize: 24,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _removeItem(item),
              icon: const Icon(Icons.delete_outline),
              color: AppTheme.errorRed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'សរុប:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${_subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _proceedToCheckout,
                child: const Text('បន្តទៅបង់ប្រាក់'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
