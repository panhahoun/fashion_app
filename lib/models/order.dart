import 'dart:ui';

import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/models/order_item.dart';
import 'package:flutter/material.dart';

class Order {
  final int id;
  final double totalAmount;
  final String status;
  final String customerName;
  final String phone;
  final String address;
  final String paymentMethod;
  final String createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      customerName: json['customerName'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      createdAt: json['createdAt'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList()
          : [],
    );
  }

  String get statusKhmer {
    switch (status) {
      case 'pending':
        return 'កំពុងរង់ចាំ';
      case 'processing':
        return 'កំពុងដំណើរការ';
      case 'completed':
        return 'បានបញ្ចប់';
      case 'cancelled':
        return 'បានលុបចោល';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return AppTheme.warningOrange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return AppTheme.successGreen;
      case 'cancelled':
        return AppTheme.errorRed;
      default:
        return Colors.grey;
    }
  }
}
