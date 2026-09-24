import 'package:fashion_app/core/app_theme.dart';
import 'package:flutter/material.dart';

class Category {
  final int id;
  final String nameKhmer;
  final String nameEnglish;
  final String icon;
  final String color;

  Category({
    required this.id,
    required this.nameKhmer,
    required this.nameEnglish,
    required this.icon,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      nameKhmer: json['nameKhmer'] ?? '',
      nameEnglish: json['nameEnglish'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '#FF8C42',
    );
  }

  IconData get iconData {
    switch (icon) {
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'sports_handball':
        return Icons.sports_handball;
      case 'star':
        return Icons.star;
      case 'face':
        return Icons.face;
      case 'checkroom':
        return Icons.checkroom;
      default:
        return Icons.category;
    }
  }

  Color get colorValue {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppTheme.primaryOrange;
    }
  }
}
