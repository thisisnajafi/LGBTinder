import 'package:flutter/foundation.dart';

class SubPlan {
  final int id;
  final int planId;
  final String subPlanTitle;
  final String subPlanDescription;
  final int durationDays;
  final double price;
  final double? discountedPrice;
  final String? discountType;
  final double? discountValue;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubPlan({
    required this.id,
    required this.planId,
    required this.subPlanTitle,
    required this.subPlanDescription,
    required this.durationDays,
    required this.price,
    this.discountedPrice,
    this.discountType,
    this.discountValue,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubPlan.fromJson(Map<String, dynamic> json) {
    return SubPlan(
      id: json['id'] as int,
      planId: json['plan_id'] as int,
      subPlanTitle: json['sub_plan_title'] as String,
      subPlanDescription: json['sub_plan_description'] as String,
      durationDays: json['duration_days'] as int,
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
      'plan_id': planId,
      'sub_plan_title': subPlanTitle,
      'sub_plan_description': subPlanDescription,
      'duration_days': durationDays,
      'price': price,
      'discounted_price': discountedPrice,
      'discount_type': discountType,
      'discount_value': discountValue,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SubPlan copyWith({
    int? id,
    int? planId,
    String? subPlanTitle,
    String? subPlanDescription,
    int? durationDays,
    double? price,
    double? discountedPrice,
    String? discountType,
    double? discountValue,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubPlan(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      subPlanTitle: subPlanTitle ?? this.subPlanTitle,
      subPlanDescription: subPlanDescription ?? this.subPlanDescription,
      durationDays: durationDays ?? this.durationDays,
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

  // Get duration in months
  double get durationMonths => durationDays / 30.0;

  // Get monthly price
  double get monthlyPrice => effectivePrice / durationMonths;

  // Get duration display text
  String get durationDisplay {
    if (durationDays == 30) return 'Monthly';
    if (durationDays == 90) return '3 Months';
    if (durationDays == 180) return '6 Months';
    if (durationDays == 365) return 'Yearly';
    return '${durationDays} Days';
  }

  // Check if this is the best value option
  bool get isBestValue => durationDays >= 180; // 6 months or more

  // Check if this is the most popular option
  bool get isMostPopular => durationDays == 90; // 3 months

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubPlan &&
        other.id == id &&
        other.planId == planId &&
        other.subPlanTitle == subPlanTitle &&
        other.durationDays == durationDays &&
        other.price == price &&
        other.discountedPrice == discountedPrice;
  }

  @override
  int get hashCode {
    return Object.hash(id, planId, subPlanTitle, durationDays, price, discountedPrice);
  }

  @override
  String toString() {
    return 'SubPlan(id: $id, title: $subPlanTitle, duration: $durationDisplay, price: \$${effectivePrice.toStringAsFixed(2)})';
  }
}
