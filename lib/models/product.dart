import 'package:flutter/material.dart';

class Product {
  final int id;
  final String nameKhmer;
  final String nameEnglish;
  final String descriptionKhmer;
  final String descriptionEnglish;
  final double price;
  final int stock;
  final double rating;
  final int reviews;
  final String imageUrl;
  final String category;
  final List<String> images;
  final List<String> sizes;
  final List<ProductColor> colors;
  bool isFavorite;

  Product({
    required this.id,
    required this.nameKhmer,
    required this.nameEnglish,
    required this.descriptionKhmer,
    required this.descriptionEnglish,
    required this.price,
    required this.stock,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
    required this.category,
    required this.images,
    required this.sizes,
    required this.colors,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final parsedRating = _parseDouble(
      json['rating'] ?? json['avg_rating'] ?? json['average_rating'],
    );

    return Product(
      id: _parseInt(json['id']),
      nameKhmer: json['nameKhmer'] ?? '',
      nameEnglish: json['nameEnglish'] ?? '',
      descriptionKhmer: json['descriptionKhmer'] ?? '',
      descriptionEnglish: json['descriptionEnglish'] ?? '',
      price: _parseDouble(json['price']),
      stock: _parseInt(json['stock']),
      // Clamp rating to valid 0.0 - 5.0 range.
      rating: parsedRating.clamp(0.0, 5.0),
      reviews: _parseInt(json['reviews'] ?? json['review_count']),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : [],
      colors: json['colors'] != null
          ? (json['colors'] as List)
              .map((color) => ProductColor.fromJson(color))
              .toList()
          : [],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // Treat 0 as "unrated" so UI does not show a misleading star score.
  bool get hasRating => rating > 0;
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

double _parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0.0;
  return 0.0;
}

class ProductColor {
  final String name;
  final String hex;

  ProductColor({required this.name, required this.hex});

  factory ProductColor.fromJson(Map<String, dynamic> json) {
    return ProductColor(
      name: json['name'] ?? '',
      hex: json['hex'] ?? '#000000',
    );
  }

  Color get color {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.black;
    }
  }
}
