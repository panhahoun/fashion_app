import 'package:fashion_app/core/app_theme.dart';
import 'package:fashion_app/models/order_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  /// Localized status label for the UI.
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'status_pending'.tr;
      case 'processing':
        return 'status_processing'.tr;
      case 'completed':
        return 'status_completed'.tr;
      case 'cancelled':
        return 'status_cancelled'.tr;
      default:
        return status;
    }
  }

  /// Maps the API's Khmer payment labels to translation keys.
  String get paymentLabel {
    switch (paymentMethod) {
      case 'សាច់ប្រាក់':
        return 'cash'.tr;
      case 'ធនាគារ':
        return 'bank'.tr;
      default:
        return paymentMethod;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return AppTheme.accent;
      case 'processing':
        return AppTheme.primary;
      case 'completed':
        return AppTheme.successGreen;
      case 'cancelled':
        return AppTheme.errorRed;
      default:
        return AppTheme.textSecondary;
    }
  }
}
