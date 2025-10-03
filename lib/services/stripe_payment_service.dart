import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/api_error_handler.dart';
import '../utils/error_handler.dart';

class StripePaymentService {
  /// Create a payment intent
  static Future<Map<String, dynamic>> createPaymentIntent({
    required String planId,
    required String accessToken,
    String? customerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripeCreatePaymentIntent)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'plan_id': planId,
          if (customerId != null) 'customer_id': customerId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to create payment intent: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while creating payment intent: $e');
    }
  }

  /// Confirm a payment
  static Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
    required String accessToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripeConfirmPayment)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'payment_intent_id': paymentIntentId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to confirm payment: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while confirming payment: $e');
    }
  }

  /// Create a payment method
  static Future<Map<String, dynamic>> createPaymentMethod({
    required Map<String, dynamic> paymentMethodData,
    required String accessToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripeCreatePaymentMethod)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(paymentMethodData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to create payment method: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
        throw NetworkException('Network error while creating payment method: $e');
    }
  }

  /// Attach a payment method to customer
  static Future<Map<String, dynamic>> attachPaymentMethod({
    required String paymentMethodId,
    required String customerId,
    required String accessToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripeAttachPaymentMethod)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'payment_method_id': paymentMethodId,
          'customer_id': customerId,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to attach payment method: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
        throw NetworkException('Network error while attaching payment method: $e');
    }
  }

  /// Create a customer
  static Future<Map<String, dynamic>> createCustomer({
    required String email,
    required String name,
    required String accessToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripeCreateCustomer)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'email': email,
          'name': name,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to create customer: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while creating customer: $e');
    }
  }

  /// Create a setup intent for saving payment methods
  static Future<Map<String, dynamic>> createSetupIntent({
    required String customerId,
    required String accessToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripeCreateSetupIntent)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'customer_id': customerId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to create setup intent: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while creating setup intent: $e');
    }
  }

  /// Get customer's payment methods
  static Future<List<Map<String, dynamic>>> getPaymentMethods({
    required String customerId,
    required String accessToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.stripePaymentMethods)}?customer_id=$customerId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> methods = data['data'] ?? data;
        return methods.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to get payment methods: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while getting payment methods: $e');
    }
  }

  /// Delete a payment method
  static Future<bool> deletePaymentMethod({
    required String paymentMethodId,
    required String accessToken,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.stripePaymentMethods)}/$paymentMethodId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to delete payment method: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while deleting payment method: $e');
    }
  }

  /// Create a subscription
  static Future<Map<String, dynamic>> createSubscription({
    required String customerId,
    required String priceId,
    required String accessToken,
    String? paymentMethodId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripeCreateSubscription)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'customer_id': customerId,
          'price_id': priceId,
          if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to create subscription: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while creating subscription: $e');
    }
  }

  /// Cancel a subscription
  static Future<Map<String, dynamic>> cancelSubscription({
    required String subscriptionId,
    required String accessToken,
    bool immediately = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripeCancelSubscription)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'subscription_id': subscriptionId,
          'immediately': immediately,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to cancel subscription: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while canceling subscription: $e');
    }
  }

  /// Update a subscription
  static Future<Map<String, dynamic>> updateSubscription({
    required String subscriptionId,
    required String priceId,
    required String accessToken,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.stripeUpdateSubscription)}/$subscriptionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'price_id': priceId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to update subscription: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating subscription: $e');
    }
  }

  /// Get subscription details
  static Future<Map<String, dynamic>> getSubscription({
    required String subscriptionId,
    required String accessToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.stripeGetSubscription)}/$subscriptionId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to get subscription: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while getting subscription: $e');
    }
  }

  /// Get customer's subscriptions
  static Future<List<Map<String, dynamic>>> getCustomerSubscriptions({
    required String customerId,
    required String accessToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.stripeCustomerSubscriptions)}?customer_id=$customerId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> subscriptions = data['data'] ?? data;
        return subscriptions.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to get customer subscriptions: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while getting customer subscriptions: $e');
    }
  }

  /// Handle webhook events
  static Future<bool> handleWebhook({
    required String payload,
    required String signature,
    required String endpointSecret,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripeWebhook)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Stripe-Signature': signature,
        },
        body: jsonEncode({
          'payload': payload,
          'endpoint_secret': endpointSecret,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get payment status
  static Future<Map<String, dynamic>> getPaymentStatus({
    required String paymentIntentId,
    required String accessToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.stripePaymentStatus)}/$paymentIntentId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to get payment status: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while getting payment status: $e');
    }
  }
}

class PaymentMethod {
  final String id;
  final String type;
  final Map<String, dynamic> card;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.card,
    required this.isDefault,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      card: json['card'] ?? {},
      isDefault: json['is_default'] ?? false,
    );
  }

  String get cardBrand => card['brand'] ?? 'Unknown';
  String get last4 => card['last4'] ?? '****';
  String get expiryMonth => card['exp_month']?.toString() ?? '**';
  String get expiryYear => card['exp_year']?.toString() ?? '****';

  String get formattedCard {
    return '$cardBrand •••• $last4';
  }

  String get formattedExpiry {
    return '$expiryMonth/$expiryYear';
  }
}

class Subscription {
  final String id;
  final String status;
  final String currentPeriodStart;
  final String currentPeriodEnd;
  final String customerId;
  final String priceId;
  final Map<String, dynamic> items;

  Subscription({
    required this.id,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.customerId,
    required this.priceId,
    required this.items,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      currentPeriodStart: json['current_period_start'] ?? '',
      currentPeriodEnd: json['current_period_end'] ?? '',
      customerId: json['customer'] ?? '',
      priceId: json['price_id'] ?? '',
      items: json['items'] ?? {},
    );
  }

  bool get isActive => status == 'active';
  bool get isCanceled => status == 'canceled';
  bool get isPastDue => status == 'past_due';
  bool get isUnpaid => status == 'unpaid';

  String get statusText {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'canceled':
        return 'Canceled';
      case 'past_due':
        return 'Past Due';
      case 'unpaid':
        return 'Unpaid';
      case 'incomplete':
        return 'Incomplete';
      case 'incomplete_expired':
        return 'Expired';
      default:
        return status;
    }
  }
}
