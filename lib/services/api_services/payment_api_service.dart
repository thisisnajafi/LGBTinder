import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../config/api_config.dart';

/// Payment API Service
/// 
/// Handles all payment-related API calls:
/// - Payment methods management
/// - Payment intent creation
/// - Subscription management
/// - Superlike packs purchase
class PaymentApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  // ============================================================================
  // PAYMENT METHODS
  // ============================================================================

  /// Get saved payment methods
  /// 
  /// [token] - Authentication token
  /// Returns list of saved payment methods
  static Future<PaymentMethodsResponse> getPaymentMethods({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payment/methods'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        final methods = (responseData['data'] as List?)
                ?.map((json) => PaymentMethod.fromJson(json as Map<String, dynamic>))
                .toList() ??
            [];

        return PaymentMethodsResponse(
          success: true,
          paymentMethods: methods,
        );
      } else {
        return PaymentMethodsResponse(
          success: false,
          error: responseData['message'] as String? ?? 'Failed to fetch payment methods',
        );
      }
    } catch (e) {
      debugPrint('Error fetching payment methods: $e');
      return PaymentMethodsResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Add new payment method
  /// 
  /// [token] - Authentication token
  /// [paymentMethodId] - Stripe payment method ID
  /// [isDefault] - Set as default payment method
  static Future<PaymentMethodResponse> addPaymentMethod({
    required String token,
    required String paymentMethodId,
    bool isDefault = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment/methods'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'payment_method_id': paymentMethodId,
          'is_default': isDefault,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        return PaymentMethodResponse(
          success: true,
          paymentMethod: PaymentMethod.fromJson(responseData['data'] as Map<String, dynamic>),
        );
      } else {
        return PaymentMethodResponse(
          success: false,
          error: responseData['message'] as String? ?? 'Failed to add payment method',
        );
      }
    } catch (e) {
      debugPrint('Error adding payment method: $e');
      return PaymentMethodResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Delete payment method
  /// 
  /// [token] - Authentication token
  /// [methodId] - Payment method ID
  static Future<bool> deletePaymentMethod({
    required String token,
    required String methodId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/payment/methods/$methodId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return response.statusCode == 200 && responseData['status'] == true;
    } catch (e) {
      debugPrint('Error deleting payment method: $e');
      return false;
    }
  }

  /// Set default payment method
  /// 
  /// [token] - Authentication token
  /// [methodId] - Payment method ID
  static Future<bool> setDefaultPaymentMethod({
    required String token,
    required String methodId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/payment/methods/$methodId/default'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return response.statusCode == 200 && responseData['status'] == true;
    } catch (e) {
      debugPrint('Error setting default payment method: $e');
      return false;
    }
  }

  // ============================================================================
  // PAYMENT INTENTS
  // ============================================================================

  /// Create payment intent
  /// 
  /// [token] - Authentication token
  /// [amount] - Amount in cents (e.g., 1999 for $19.99)
  /// [currency] - Currency code (e.g., 'usd')
  /// [description] - Payment description
  /// [metadata] - Additional metadata
  /// Returns client secret for payment confirmation
  static Future<PaymentIntentResponse> createPaymentIntent({
    required String token,
    required int amount,
    String currency = 'usd',
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment/create-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'description': description,
          'metadata': metadata,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        return PaymentIntentResponse(
          success: true,
          clientSecret: responseData['data']?['client_secret'] as String?,
          paymentIntentId: responseData['data']?['payment_intent_id'] as String?,
          ephemeralKey: responseData['data']?['ephemeral_key'] as String?,
          customerId: responseData['data']?['customer_id'] as String?,
        );
      } else {
        return PaymentIntentResponse(
          success: false,
          error: responseData['message'] as String? ?? 'Failed to create payment intent',
        );
      }
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      return PaymentIntentResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Confirm payment on backend
  /// 
  /// [token] - Authentication token
  /// [paymentIntentId] - Payment intent ID
  static Future<bool> confirmPayment({
    required String token,
    required String paymentIntentId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'payment_intent_id': paymentIntentId,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return response.statusCode == 200 && responseData['status'] == true;
    } catch (e) {
      debugPrint('Error confirming payment: $e');
      return false;
    }
  }

  // ============================================================================
  // SUBSCRIPTIONS
  // ============================================================================

  /// Get subscription plans
  /// 
  /// [token] - Authentication token
  static Future<SubscriptionPlansResponse> getSubscriptionPlans({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/plans'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        final plans = (responseData['data'] as List?)
                ?.map((json) => SubscriptionPlan.fromJson(json as Map<String, dynamic>))
                .toList() ??
            [];

        return SubscriptionPlansResponse(
          success: true,
          plans: plans,
        );
      } else {
        return SubscriptionPlansResponse(
          success: false,
          error: responseData['message'] as String? ?? 'Failed to fetch plans',
        );
      }
    } catch (e) {
      debugPrint('Error fetching subscription plans: $e');
      return SubscriptionPlansResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Purchase subscription
  /// 
  /// [token] - Authentication token
  /// [planId] - Plan ID
  /// [paymentMethodId] - Payment method ID
  /// [promoCode] - Optional promo code
  static Future<SubscriptionResponse> purchaseSubscription({
    required String token,
    required String planId,
    required String paymentMethodId,
    String? promoCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/subscriptions/purchase'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'plan_id': planId,
          'payment_method_id': paymentMethodId,
          if (promoCode != null) 'promo_code': promoCode,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        return SubscriptionResponse(
          success: true,
          subscription: Subscription.fromJson(responseData['data'] as Map<String, dynamic>),
        );
      } else {
        return SubscriptionResponse(
          success: false,
          error: responseData['message'] as String? ?? 'Failed to purchase subscription',
        );
      }
    } catch (e) {
      debugPrint('Error purchasing subscription: $e');
      return SubscriptionResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get current subscription
  /// 
  /// [token] - Authentication token
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

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        return SubscriptionResponse(
          success: true,
          subscription: responseData['data'] != null
              ? Subscription.fromJson(responseData['data'] as Map<String, dynamic>)
              : null,
        );
      } else {
        return SubscriptionResponse(
          success: false,
          error: responseData['message'] as String? ?? 'Failed to fetch subscription',
        );
      }
    } catch (e) {
      debugPrint('Error fetching current subscription: $e');
      return SubscriptionResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Cancel subscription
  /// 
  /// [token] - Authentication token
  /// [reason] - Cancellation reason
  static Future<bool> cancelSubscription({
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
          if (reason != null) 'reason': reason,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return response.statusCode == 200 && responseData['status'] == true;
    } catch (e) {
      debugPrint('Error cancelling subscription: $e');
      return false;
    }
  }

  // ============================================================================
  // SUPERLIKE PACKS
  // ============================================================================

  /// Get superlike packs
  /// 
  /// [token] - Authentication token
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

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        final packs = (responseData['data'] as List?)
                ?.map((json) => SuperlikePack.fromJson(json as Map<String, dynamic>))
                .toList() ??
            [];

        return SuperlikePacksResponse(
          success: true,
          packs: packs,
        );
      } else {
        return SuperlikePacksResponse(
          success: false,
          error: responseData['message'] as String? ?? 'Failed to fetch packs',
        );
      }
    } catch (e) {
      debugPrint('Error fetching superlike packs: $e');
      return SuperlikePacksResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Purchase superlike pack
  /// 
  /// [token] - Authentication token
  /// [packId] - Pack ID
  /// [paymentMethodId] - Payment method ID
  static Future<SuperlikePackPurchaseResponse> purchaseSuperlikePack({
    required String token,
    required String packId,
    required String paymentMethodId,
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

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        return SuperlikePackPurchaseResponse(
          success: true,
          newBalance: responseData['data']?['new_balance'] as int?,
          message: responseData['message'] as String?,
        );
      } else {
        return SuperlikePackPurchaseResponse(
          success: false,
          error: responseData['message'] as String? ?? 'Failed to purchase pack',
        );
      }
    } catch (e) {
      debugPrint('Error purchasing superlike pack: $e');
      return SuperlikePackPurchaseResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get superlike balance
  /// 
  /// [token] - Authentication token
  static Future<int?> getSuperlikeBalance({
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

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        return responseData['data']?['balance'] as int?;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching superlike balance: $e');
      return null;
    }
  }
}

// ============================================================================
// RESPONSE MODELS
// ============================================================================

class PaymentMethodsResponse {
  final bool success;
  final List<PaymentMethod>? paymentMethods;
  final String? error;

  PaymentMethodsResponse({
    required this.success,
    this.paymentMethods,
    this.error,
  });
}

class PaymentMethodResponse {
  final bool success;
  final PaymentMethod? paymentMethod;
  final String? error;

  PaymentMethodResponse({
    required this.success,
    this.paymentMethod,
    this.error,
  });
}

class PaymentIntentResponse {
  final bool success;
  final String? clientSecret;
  final String? paymentIntentId;
  final String? ephemeralKey;
  final String? customerId;
  final String? error;

  PaymentIntentResponse({
    required this.success,
    this.clientSecret,
    this.paymentIntentId,
    this.ephemeralKey,
    this.customerId,
    this.error,
  });
}

class SubscriptionPlansResponse {
  final bool success;
  final List<SubscriptionPlan>? plans;
  final String? error;

  SubscriptionPlansResponse({
    required this.success,
    this.plans,
    this.error,
  });
}

class SubscriptionResponse {
  final bool success;
  final Subscription? subscription;
  final String? error;

  SubscriptionResponse({
    required this.success,
    this.subscription,
    this.error,
  });
}

class SuperlikePacksResponse {
  final bool success;
  final List<SuperlikePack>? packs;
  final String? error;

  SuperlikePacksResponse({
    required this.success,
    this.packs,
    this.error,
  });
}

class SuperlikePackPurchaseResponse {
  final bool success;
  final int? newBalance;
  final String? message;
  final String? error;

  SuperlikePackPurchaseResponse({
    required this.success,
    this.newBalance,
    this.message,
    this.error,
  });
}

// ============================================================================
// DATA MODELS
// ============================================================================

class PaymentMethod {
  final String id;
  final String type; // 'card'
  final CardDetails? card;
  final bool isDefault;
  final DateTime createdAt;

  PaymentMethod({
    required this.id,
    required this.type,
    this.card,
    required this.isDefault,
    required this.createdAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'card',
      card: json['card'] != null
          ? CardDetails.fromJson(json['card'] as Map<String, dynamic>)
          : null,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class CardDetails {
  final String brand; // 'visa', 'mastercard', etc.
  final String last4;
  final int expMonth;
  final int expYear;

  CardDetails({
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
  });

  factory CardDetails.fromJson(Map<String, dynamic> json) {
    return CardDetails(
      brand: json['brand'] as String,
      last4: json['last4'] as String,
      expMonth: json['exp_month'] as int,
      expYear: json['exp_year'] as int,
    );
  }

  String get displayBrand {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'American Express';
      default:
        return brand.toUpperCase();
    }
  }

  String get maskedNumber => '**** **** **** $last4';
}

class SubscriptionPlan {
  final String id;
  final String name; // 'Bronze', 'Silver', 'Gold'
  final String description;
  final List<String> features;
  final int monthlyPrice;
  final int? threeMonthPrice;
  final int? sixMonthPrice;
  final int? yearlyPrice;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.features,
    required this.monthlyPrice,
    this.threeMonthPrice,
    this.sixMonthPrice,
    this.yearlyPrice,
    this.isPopular = false,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      features: (json['features'] as List?)?.map((e) => e as String).toList() ?? [],
      monthlyPrice: json['monthly_price'] as int,
      threeMonthPrice: json['three_month_price'] as int?,
      sixMonthPrice: json['six_month_price'] as int?,
      yearlyPrice: json['yearly_price'] as int?,
      isPopular: json['is_popular'] as bool? ?? false,
    );
  }
}

class Subscription {
  final String id;
  final String planId;
  final String planName;
  final String status; // 'active', 'cancelled', 'expired'
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final bool cancelAtPeriodEnd;

  Subscription({
    required this.id,
    required this.planId,
    required this.planName,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      planName: json['plan_name'] as String,
      status: json['status'] as String,
      currentPeriodStart: DateTime.parse(json['current_period_start'] as String),
      currentPeriodEnd: DateTime.parse(json['current_period_end'] as String),
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
    );
  }

  bool get isActive => status == 'active';
}

class SuperlikePack {
  final String id;
  final int quantity; // 5, 25, 60
  final int price; // in cents
  final int? discount; // percentage
  final String? bestValue;

  SuperlikePack({
    required this.id,
    required this.quantity,
    required this.price,
    this.discount,
    this.bestValue,
  });

  factory SuperlikePack.fromJson(Map<String, dynamic> json) {
    return SuperlikePack(
      id: json['id'] as String,
      quantity: json['quantity'] as int,
      price: json['price'] as int,
      discount: json['discount'] as int?,
      bestValue: json['best_value'] as String?,
    );
  }

  double get pricePerSuperlike => price / quantity / 100;
}

