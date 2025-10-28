import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/token_management_service.dart';

/// Stripe Payment Service
/// 
/// Handles all Stripe payment operations:
/// - Initialize Stripe SDK
/// - Create payment intents
/// - Process payments
/// - Handle 3D Secure authentication
/// - Manage payment methods
class StripePaymentService {
  static final StripePaymentService _instance = StripePaymentService._internal();
  factory StripePaymentService() => _instance;
  StripePaymentService._internal();

  static const String _baseUrl = ApiConfig.baseUrl;
  bool _isInitialized = false;

  /// Initialize Stripe SDK
  /// 
  /// Must be called once at app startup
  /// [publishableKey] - Stripe publishable key from backend
  Future<void> initialize(String publishableKey) async {
    if (_isInitialized) return;

    try {
      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();
      _isInitialized = true;
      debugPrint('Stripe initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Stripe: $e');
      rethrow;
    }
  }

  /// Get Stripe publishable key from backend
  Future<String> getPublishableKey() async {
    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$_baseUrl/payment/config'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data['status'] == true) {
        return data['data']['publishable_key'] as String;
      }

      throw Exception('Failed to get publishable key');
    } catch (e) {
      debugPrint('Error getting publishable key: $e');
      rethrow;
    }
  }

  /// Create payment intent
  /// 
  /// [amount] - Amount in cents (e.g., 1000 = $10.00)
  /// [currency] - Currency code (e.g., 'usd')
  /// [description] - Payment description
  /// [metadata] - Additional metadata
  /// Returns payment intent client secret
  Future<String> createPaymentIntent({
    required int amount,
    String currency = 'usd',
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

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

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return data['data']['client_secret'] as String;
      }

      throw Exception(data['message'] ?? 'Failed to create payment intent');
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      rethrow;
    }
  }

  /// Process payment with card
  /// 
  /// [clientSecret] - Payment intent client secret
  /// [billingDetails] - Card billing details
  /// Returns payment result
  Future<PaymentResult> processPayment({
    required String clientSecret,
    BillingDetails? billingDetails,
  }) async {
    try {
      // Present payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'LGBTinder',
          billingDetails: billingDetails,
          style: ThemeMode.dark,
        ),
      );

      // Show payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful
      return PaymentResult(
        success: true,
        message: 'Payment successful',
      );
    } on StripeException catch (e) {
      debugPrint('Stripe error: ${e.error.localizedMessage}');
      
      if (e.error.code == FailureCode.Canceled) {
        return PaymentResult(
          success: false,
          message: 'Payment cancelled',
          error: 'cancelled',
        );
      }

      return PaymentResult(
        success: false,
        message: e.error.localizedMessage ?? 'Payment failed',
        error: e.error.code.name,
      );
    } catch (e) {
      debugPrint('Payment error: $e');
      return PaymentResult(
        success: false,
        message: 'Payment failed: ${e.toString()}',
        error: 'unknown',
      );
    }
  }

  /// Confirm payment on backend
  /// 
  /// [paymentIntentId] - Payment intent ID
  /// Returns confirmation result
  Future<bool> confirmPayment(String paymentIntentId) async {
    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

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

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return response.statusCode == 200 && data['status'] == true;
    } catch (e) {
      debugPrint('Error confirming payment: $e');
      return false;
    }
  }

  /// Get saved payment methods
  Future<List<PaymentMethodData>> getPaymentMethods() async {
    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$_baseUrl/payment/methods'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        final methods = (data['data'] as List)
            .map((item) => PaymentMethodData.fromJson(item as Map<String, dynamic>))
            .toList();
        return methods;
      }

      return [];
    } catch (e) {
      debugPrint('Error getting payment methods: $e');
      return [];
    }
  }

  /// Add new payment method
  Future<PaymentMethodData?> addPaymentMethod() async {
    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      // Create setup intent
      final response = await http.post(
        Uri.parse('$_baseUrl/payment/setup-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 || data['status'] != true) {
        throw Exception('Failed to create setup intent');
      }

      final clientSecret = data['data']['client_secret'] as String;

      // Present payment sheet for setup
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: clientSecret,
          merchantDisplayName: 'LGBTinder',
          style: ThemeMode.dark,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // Save payment method on backend
      final saveResponse = await http.post(
        Uri.parse('$_baseUrl/payment/methods'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'setup_intent_id': data['data']['setup_intent_id'],
        }),
      );

      final saveData = jsonDecode(saveResponse.body) as Map<String, dynamic>;

      if (saveResponse.statusCode == 200 && saveData['status'] == true) {
        return PaymentMethodData.fromJson(saveData['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      debugPrint('Error adding payment method: $e');
      return null;
    }
  }

  /// Delete payment method
  Future<bool> deletePaymentMethod(String paymentMethodId) async {
    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.delete(
        Uri.parse('$_baseUrl/payment/methods/$paymentMethodId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return response.statusCode == 200 && data['status'] == true;
    } catch (e) {
      debugPrint('Error deleting payment method: $e');
      return false;
    }
  }

  /// Set default payment method
  Future<bool> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.put(
        Uri.parse('$_baseUrl/payment/methods/$paymentMethodId/default'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return response.statusCode == 200 && data['status'] == true;
    } catch (e) {
      debugPrint('Error setting default payment method: $e');
      return false;
    }
  }

  /// Process subscription payment
  Future<PaymentResult> processSubscriptionPayment({
    required String planId,
    String? promoCode,
    String? paymentMethodId,
  }) async {
    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      // Create subscription payment intent
      final response = await http.post(
        Uri.parse('$_baseUrl/subscriptions/purchase'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'plan_id': planId,
          'promo_code': promoCode,
          'payment_method_id': paymentMethodId,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        // If requires payment confirmation
        if (data['data']['requires_action'] == true) {
          final clientSecret = data['data']['client_secret'] as String;
          return await processPayment(clientSecret: clientSecret);
        }

        // Subscription activated immediately
        return PaymentResult(
          success: true,
          message: 'Subscription activated successfully',
        );
      }

      throw Exception(data['message'] ?? 'Failed to process subscription');
    } catch (e) {
      debugPrint('Error processing subscription payment: $e');
      return PaymentResult(
        success: false,
        message: e.toString(),
        error: 'subscription_failed',
      );
    }
  }
}

/// Payment Result Model
class PaymentResult {
  final bool success;
  final String message;
  final String? error;

  PaymentResult({
    required this.success,
    required this.message,
    this.error,
  });
}

/// Payment Method Data Model
class PaymentMethodData {
  final String id;
  final String type; // card, paypal, etc.
  final String? last4;
  final String? brand; // visa, mastercard, etc.
  final int? expMonth;
  final int? expYear;
  final bool isDefault;

  PaymentMethodData({
    required this.id,
    required this.type,
    this.last4,
    this.brand,
    this.expMonth,
    this.expYear,
    this.isDefault = false,
  });

  factory PaymentMethodData.fromJson(Map<String, dynamic> json) {
    return PaymentMethodData(
      id: json['id'] as String,
      type: json['type'] as String,
      last4: json['last4'] as String?,
      brand: json['brand'] as String?,
      expMonth: json['exp_month'] as int?,
      expYear: json['exp_year'] as int?,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  String get displayName {
    if (type == 'card' && brand != null && last4 != null) {
      return '${brand!.toUpperCase()} •••• $last4';
    }
    return type.toUpperCase();
  }

  String get expiryDisplay {
    if (expMonth != null && expYear != null) {
      return '${expMonth.toString().padLeft(2, '0')}/${expYear! % 100}';
    }
    return '';
  }
}
