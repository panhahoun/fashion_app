class OrderItem {
  final int productId;
  final String nameKhmer;
  final String nameEnglish;
  final String imageUrl;
  final int quantity;
  final double price;
  final String selectedSize;
  final String selectedColorName;

  OrderItem({
    required this.productId,
    required this.nameKhmer,
    required this.nameEnglish,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    required this.selectedSize,
    required this.selectedColorName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? 0,
      nameKhmer: json['nameKhmer'] ?? '',
      nameEnglish: json['nameEnglish'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      selectedSize: json['selectedSize'] ?? '',
      selectedColorName: json['selectedColorName'] ?? '',
    );
  }
}
