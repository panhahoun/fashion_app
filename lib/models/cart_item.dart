class CartItem {
  final int id;
  final int productId;
  final String nameKhmer;
  final String nameEnglish;
  final double price;
  final String imageUrl;
  int quantity;
  final String selectedSize;
  final String selectedColorName;
  final String selectedColorHex;
  final int stock;

  CartItem({
    required this.id,
    required this.productId,
    required this.nameKhmer,
    required this.nameEnglish,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColorName,
    required this.selectedColorHex,
    required this.stock,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      nameKhmer: json['nameKhmer'] ?? '',
      nameEnglish: json['nameEnglish'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      quantity: json['quantity'] ?? 1,
      selectedSize: json['selectedSize'] ?? '',
      selectedColorName: json['selectedColorName'] ?? '',
      selectedColorHex: json['selectedColorHex'] ?? '#000000',
      stock: json['stock'] ?? 0,
    );
  }

  double get total => price * quantity;
}
