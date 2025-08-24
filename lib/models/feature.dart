import 'package:flutter/foundation.dart';

class Feature {
  final int id;
  final String name;
  final String description;
  final String planAccessLevel; // 'free', 'bronze', 'silver', 'gold'
  final bool isPremium;
  final String? icon;
  final String? category;
  final int? usageLimit;
  final String? usagePeriod; // 'daily', 'monthly', 'unlimited'
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Feature({
    required this.id,
    required this.name,
    required this.description,
    required this.planAccessLevel,
    required this.isPremium,
    this.icon,
    this.category,
    this.usageLimit,
    this.usagePeriod,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      planAccessLevel: json['plan_access_level'] as String,
      isPremium: json['is_premium'] as bool,
      icon: json['icon'] as String?,
      category: json['category'] as String?,
      usageLimit: json['usage_limit'] as int?,
      usagePeriod: json['usage_period'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'plan_access_level': planAccessLevel,
      'is_premium': isPremium,
      'icon': icon,
      'category': category,
      'usage_limit': usageLimit,
      'usage_period': usagePeriod,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Feature copyWith({
    int? id,
    String? name,
    String? description,
    String? planAccessLevel,
    bool? isPremium,
    String? icon,
    String? category,
    int? usageLimit,
    String? usagePeriod,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Feature(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      planAccessLevel: planAccessLevel ?? this.planAccessLevel,
      isPremium: isPremium ?? this.isPremium,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      usageLimit: usageLimit ?? this.usageLimit,
      usagePeriod: usagePeriod ?? this.usagePeriod,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if feature is available for free users
  bool get isFree => planAccessLevel == 'free';

  // Check if feature requires Bronze plan
  bool get requiresBronze => planAccessLevel == 'bronze';

  // Check if feature requires Silver plan
  bool get requiresSilver => planAccessLevel == 'silver';

  // Check if feature requires Gold plan
  bool get requiresGold => planAccessLevel == 'gold';

  // Get plan access level display text
  String get planAccessLevelDisplay {
    switch (planAccessLevel) {
      case 'free':
        return 'Free';
      case 'bronze':
        return 'Bronze';
      case 'silver':
        return 'Silver';
      case 'gold':
        return 'Gold';
      default:
        return planAccessLevel;
    }
  }

  // Check if feature has usage limits
  bool get hasUsageLimit => usageLimit != null && usageLimit! > 0;

  // Check if feature is unlimited
  bool get isUnlimited => usagePeriod == 'unlimited' || usageLimit == null;

  // Get usage limit display text
  String get usageLimitDisplay {
    if (isUnlimited) return 'Unlimited';
    if (usageLimit == null) return 'No limit';
    
    final period = usagePeriod ?? 'daily';
    return '$usageLimit per $period';
  }

  // Get feature category display text
  String get categoryDisplay {
    switch (category) {
      case 'matching':
        return 'Matching';
      case 'communication':
        return 'Communication';
      case 'discovery':
        return 'Discovery';
      case 'premium':
        return 'Premium';
      case 'safety':
        return 'Safety';
      default:
        return category ?? 'General';
    }
  }

  // Check if user with given plan can access this feature
  bool canAccess(String userPlan) {
    if (!isActive) return false;
    
    switch (userPlan.toLowerCase()) {
      case 'gold':
        return true; // Gold users can access all features
      case 'silver':
        return planAccessLevel != 'gold';
      case 'bronze':
        return planAccessLevel == 'free' || planAccessLevel == 'bronze';
      case 'free':
      default:
        return planAccessLevel == 'free';
    }
  }

  // Get minimum plan required for this feature
  String get minimumPlanRequired {
    switch (planAccessLevel) {
      case 'free':
        return 'Free';
      case 'bronze':
        return 'Bronze';
      case 'silver':
        return 'Silver';
      case 'gold':
        return 'Gold';
      default:
        return 'Unknown';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Feature &&
        other.id == id &&
        other.name == name &&
        other.planAccessLevel == planAccessLevel &&
        other.isPremium == isPremium &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, planAccessLevel, isPremium, isActive);
  }

  @override
  String toString() {
    return 'Feature(id: $id, name: $name, plan: $planAccessLevelDisplay, premium: $isPremium)';
  }
}
