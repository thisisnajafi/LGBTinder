import 'package:flutter/foundation.dart';

class SuperlikePack {
  final int id;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final double? discountedPrice;
  final String? discountType;
  final double? discountValue;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SuperlikePack({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    this.discountedPrice,
    this.discountType,
    this.discountValue,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SuperlikePack.fromJson(Map<String, dynamic> json) {
    return SuperlikePack(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      discountedPrice: json['discounted_price'] != null 
          ? (json['discounted_price'] as num).toDouble() 
          : null,
      discountType: json['discount_type'] as String?,
      discountValue: json['discount_value'] != null 
          ? (json['discount_value'] as num).toDouble() 
          : null,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'price': price,
      'discounted_price': discountedPrice,
      'discount_type': discountType,
      'discount_value': discountValue,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SuperlikePack copyWith({
    int? id,
    String? name,
    String? description,
    int? quantity,
    double? price,
    double? discountedPrice,
    String? discountType,
    double? discountValue,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SuperlikePack(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get the effective price (discounted if available, otherwise regular price)
  double get effectivePrice => discountedPrice ?? price;

  // Check if there's a discount
  bool get hasDiscount => discountedPrice != null && discountedPrice! < price;

  // Calculate savings amount
  double get savingsAmount => hasDiscount ? price - discountedPrice! : 0.0;

  // Calculate savings percentage
  double get savingsPercentage => hasDiscount ? (savingsAmount / price) * 100 : 0.0;

  // Calculate price per superlike
  double get pricePerSuperlike => effectivePrice / quantity;

  // Get pack size category
  String get packSize {
    if (quantity <= 5) return 'Small';
    if (quantity <= 15) return 'Medium';
    if (quantity <= 30) return 'Large';
    return 'Mega';
  }

  // Check if this is the best value option
  bool get isBestValue => pricePerSuperlike <= 0.4; // $0.40 or less per superlike

  // Check if this is the most popular option
  bool get isMostPopular => quantity == 15; // Medium pack

  // Get pack display name
  String get displayName {
    switch (packSize) {
      case 'Small':
        return 'Small Pack';
      case 'Medium':
        return 'Medium Pack';
      case 'Large':
        return 'Large Pack';
      case 'Mega':
        return 'Mega Pack';
      default:
        return name;
    }
  }

  // Get pack benefits description
  String get benefitsDescription {
    switch (packSize) {
      case 'Small':
        return 'Perfect for trying out superlikes';
      case 'Medium':
        return 'Great value for regular users';
      case 'Large':
        return 'Best value for active users';
      case 'Mega':
        return 'Maximum value for power users';
      default:
        return description;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SuperlikePack &&
        other.id == id &&
        other.name == name &&
        other.quantity == quantity &&
        other.price == price &&
        other.discountedPrice == discountedPrice;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, quantity, price, discountedPrice);
  }

  @override
  String toString() {
    return 'SuperlikePack(id: $id, name: $displayName, quantity: $quantity, price: \$${effectivePrice.toStringAsFixed(2)})';
  }
}
