import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../config/api_config.dart';
import '../../models/premium_plan.dart';

/// Payment API Service
/// 
/// Handles all payment-related API calls
class PaymentApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// Get all subscription plans
  static Future<PlansResponse> getPlans({
    required String token,
  }) async {
    try {
      debugPrint('Fetching subscription plans');

      final response = await http.get(
        Uri.parse('$_baseUrl/plans'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        final plans = (data['data'] as List)
            .map((item) => PremiumPlan.fromJson(item as Map<String, dynamic>))
            .toList();

        return PlansResponse(
          success: true,
          plans: plans,
        );
      }

      return PlansResponse(
        success: false,
        plans: [],
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error fetching plans: $e');
      return PlansResponse(
        success: false,
        plans: [],
        error: e.toString(),
      );
    }
  }

  /// Get current subscription
  static Future<SubscriptionResponse> getCurrentSubscription({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/subscriptions/current'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return SubscriptionResponse(
          success: true,
          subscription: data['data'] != null
              ? UserSubscription.fromJson(data['data'] as Map<String, dynamic>)
              : null,
        );
      }

      return SubscriptionResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error getting current subscription: $e');
      return SubscriptionResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Upgrade subscription
  static Future<SubscriptionResponse> upgradeSubscription({
    required String token,
    required String planId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/subscriptions/upgrade'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'plan_id': planId,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return SubscriptionResponse(
          success: true,
          subscription: UserSubscription.fromJson(data['data'] as Map<String, dynamic>),
          message: data['message'] as String?,
        );
      }

      return SubscriptionResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error upgrading subscription: $e');
      return SubscriptionResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Downgrade subscription
  static Future<SubscriptionResponse> downgradeSubscription({
    required String token,
    required String planId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/subscriptions/downgrade'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'plan_id': planId,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return SubscriptionResponse(
          success: true,
          subscription: UserSubscription.fromJson(data['data'] as Map<String, dynamic>),
          message: data['message'] as String?,
        );
      }

      return SubscriptionResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error downgrading subscription: $e');
      return SubscriptionResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Cancel subscription
  static Future<SubscriptionResponse> cancelSubscription({
    required String token,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/subscriptions/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'reason': reason,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return SubscriptionResponse(
          success: true,
          message: data['message'] as String?,
        );
      }

      return SubscriptionResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error canceling subscription: $e');
      return SubscriptionResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Get superlike packs
  static Future<SuperlikePacksResponse> getSuperlikePacks({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/superlikes/packs'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        final packs = (data['data'] as List)
            .map((item) => SuperlikePack.fromJson(item as Map<String, dynamic>))
            .toList();

        return SuperlikePacksResponse(
          success: true,
          packs: packs,
        );
      }

      return SuperlikePacksResponse(
        success: false,
        packs: [],
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error fetching superlike packs: $e');
      return SuperlikePacksResponse(
        success: false,
        packs: [],
        error: e.toString(),
      );
    }
  }

  /// Purchase superlike pack
  static Future<PurchaseResponse> purchaseSuperlikePack({
    required String token,
    required String packId,
    String? paymentMethodId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/superlikes/purchase'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'pack_id': packId,
          'payment_method_id': paymentMethodId,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return PurchaseResponse(
          success: true,
          message: data['message'] as String?,
          data: data['data'] as Map<String, dynamic>?,
        );
      }

      return PurchaseResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error purchasing superlike pack: $e');
      return PurchaseResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Get superlike balance
  static Future<SuperlikeBalanceResponse> getSuperlikeBalance({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/superlikes/balance'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return SuperlikeBalanceResponse(
          success: true,
          balance: data['data']['balance'] as int,
          history: (data['data']['history'] as List?)
              ?.map((item) => SuperlikeUsage.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
      }

      return SuperlikeBalanceResponse(
        success: false,
        balance: 0,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error getting superlike balance: $e');
      return SuperlikeBalanceResponse(
        success: false,
        balance: 0,
        error: e.toString(),
      );
    }
  }
}

/// Plans Response
class PlansResponse {
  final bool success;
  final List<PremiumPlan> plans;
  final String? error;

  PlansResponse({
    required this.success,
    required this.plans,
    this.error,
  });
}

/// Subscription Response
class SubscriptionResponse {
  final bool success;
  final UserSubscription? subscription;
  final String? message;
  final String? error;

  SubscriptionResponse({
    required this.success,
    this.subscription,
    this.message,
    this.error,
  });
}

/// User Subscription Model
class UserSubscription {
  final String id;
  final String planId;
  final String planName;
  final String status; // active, cancelled, expired
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final double amount;
  final String currency;
  final String? paymentMethod;
  final bool cancelAtPeriodEnd;

  UserSubscription({
    required this.id,
    required this.planId,
    required this.planName,
    required this.status,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    required this.amount,
    required this.currency,
    this.paymentMethod,
    this.cancelAtPeriodEnd = false,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'].toString(),
      planId: json['plan_id'].toString(),
      planName: json['plan_name'] as String,
      status: json['status'] as String,
      currentPeriodStart: json['current_period_start'] != null
          ? DateTime.parse(json['current_period_start'] as String)
          : null,
      currentPeriodEnd: json['current_period_end'] != null
          ? DateTime.parse(json['current_period_end'] as String)
          : null,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'usd',
      paymentMethod: json['payment_method'] as String?,
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
    );
  }

  bool get isActive => status == 'active';
  bool get isCancelled => status == 'cancelled' || cancelAtPeriodEnd;
  bool get isExpired => status == 'expired';
}

/// Superlike Packs Response
class SuperlikePacksResponse {
  final bool success;
  final List<SuperlikePack> packs;
  final String? error;

  SuperlikePacksResponse({
    required this.success,
    required this.packs,
    this.error,
  });
}

/// Superlike Pack Model
class SuperlikePack {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String currency;
  final int? discount; // Percentage discount
  final bool isBestValue;

  SuperlikePack({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.currency,
    this.discount,
    this.isBestValue = false,
  });

  factory SuperlikePack.fromJson(Map<String, dynamic> json) {
    return SuperlikePack(
      id: json['id'].toString(),
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'usd',
      discount: json['discount'] as int?,
      isBestValue: json['is_best_value'] as bool? ?? false,
    );
  }

  double get pricePerSuperlike => price / quantity;

  String get displayPrice {
    return '\$${price.toStringAsFixed(2)}';
  }

  String get displayPricePerUnit {
    return '\$${pricePerSuperlike.toStringAsFixed(2)} each';
  }
}

/// Purchase Response
class PurchaseResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;
  final String? error;

  PurchaseResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });
}

/// Superlike Balance Response
class SuperlikeBalanceResponse {
  final bool success;
  final int balance;
  final List<SuperlikeUsage>? history;
  final String? error;

  SuperlikeBalanceResponse({
    required this.success,
    required this.balance,
    this.history,
    this.error,
  });
}

/// Superlike Usage Model
class SuperlikeUsage {
  final String id;
  final int targetUserId;
  final String? targetUserName;
  final DateTime usedAt;
  final bool wasMatch;

  SuperlikeUsage({
    required this.id,
    required this.targetUserId,
    this.targetUserName,
    required this.usedAt,
    this.wasMatch = false,
  });

  factory SuperlikeUsage.fromJson(Map<String, dynamic> json) {
    return SuperlikeUsage(
      id: json['id'].toString(),
      targetUserId: json['target_user_id'] as int,
      targetUserName: json['target_user_name'] as String?,
      usedAt: DateTime.parse(json['used_at'] as String),
      wasMatch: json['was_match'] as bool? ?? false,
    );
  }
}
