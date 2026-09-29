class Address {
  final int id;
  final String label;
  final String recipientName;
  final String phone;
  final String detail;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.detail,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      label: json['label'] ?? '',
      recipientName: json['recipientName'] ?? '',
      phone: json['phone'] ?? '',
      detail: json['detail'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Address copyWith({
    int? id,
    String? label,
    String? recipientName,
    String? phone,
    String? detail,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      detail: detail ?? this.detail,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
