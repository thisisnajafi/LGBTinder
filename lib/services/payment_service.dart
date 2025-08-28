import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class PaymentService {
  /// Create payment intent for one-time payments
  static Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
    String? accessToken,
    Map<String, dynamic>? metadata,
    String? description,
    String? customerId,
    bool? confirmationRequired,
  }) async {
    try {
      final requestBody = {
        'amount': amount,
        'currency': currency,
      };

      if (metadata != null) requestBody['metadata'] = metadata;
      if (description != null) requestBody['description'] = description;
      if (customerId != null) requestBody['customer_id'] = customerId;
      if (confirmationRequired != null) requestBody['confirmation_required'] = confirmationRequired;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripePaymentIntent)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid payment parameters',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to create payment intent: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while creating payment intent: $e');
    }
  }

  /// Create checkout session for hosted payment flow
  static Future<Map<String, dynamic>> createCheckoutSession({
    required List<Map<String, dynamic>> lineItems,
    required String successUrl,
    required String cancelUrl,
    String? accessToken,
    String? mode, // 'payment', 'subscription', 'setup'
    String? customerId,
    Map<String, dynamic>? metadata,
    String? clientReferenceId,
    bool? allowPromotionCodes,
  }) async {
    try {
      final requestBody = {
        'line_items': lineItems,
        'success_url': successUrl,
        'cancel_url': cancelUrl,
      };

      if (mode != null) requestBody['mode'] = mode;
      if (customerId != null) requestBody['customer_id'] = customerId;
      if (metadata != null) requestBody['metadata'] = metadata;
      if (clientReferenceId != null) requestBody['client_reference_id'] = clientReferenceId;
      if (allowPromotionCodes != null) requestBody['allow_promotion_codes'] = allowPromotionCodes;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripeCheckout)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid checkout parameters',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to create checkout session: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while creating checkout session: $e');
    }
  }

  /// Create subscription
  static Future<Map<String, dynamic>> createSubscription({
    required String customerId,
    required List<String> priceIds,
    String? accessToken,
    Map<String, dynamic>? metadata,
    int? trialPeriodDays,
    String? defaultPaymentMethod,
    bool? prorationBehavior,
  }) async {
    try {
      final requestBody = {
        'customer_id': customerId,
        'price_ids': priceIds,
      };

      if (metadata != null) requestBody['metadata'] = metadata;
      if (trialPeriodDays != null) requestBody['trial_period_days'] = trialPeriodDays;
      if (defaultPaymentMethod != null) requestBody['default_payment_method'] = defaultPaymentMethod;
      if (prorationBehavior != null) requestBody['proration_behavior'] = prorationBehavior;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripeSubscription)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid subscription parameters',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to create subscription: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while creating subscription: $e');
    }
  }

  /// Cancel subscription
  static Future<Map<String, dynamic>> cancelSubscription(String subscriptionId, {
    String? accessToken,
    bool? atPeriodEnd,
    String? cancellationReason,
  }) async {
    try {
      final requestBody = <String, dynamic>{};
      
      if (atPeriodEnd != null) requestBody['at_period_end'] = atPeriodEnd;
      if (cancellationReason != null) requestBody['cancellation_reason'] = cancellationReason;

      final response = await http.delete(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.stripeSubscriptionDelete, {'subscriptionId': subscriptionId})),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: requestBody.isNotEmpty ? jsonEncode(requestBody) : null,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Subscription not found');
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

  /// Create refund
  static Future<Map<String, dynamic>> createRefund({
    required String paymentIntentId,
    String? accessToken,
    int? amount,
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final requestBody = {'payment_intent_id': paymentIntentId};

      if (amount != null) requestBody['amount'] = amount;
      if (reason != null) requestBody['reason'] = reason;
      if (metadata != null) requestBody['metadata'] = metadata;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripeRefund)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Payment intent not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid refund parameters',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to create refund: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while creating refund: $e');
    }
  }

  /// Get payment analytics
  static Future<Map<String, dynamic>> getPaymentAnalytics({
    String? accessToken,
    DateTime? startDate,
    DateTime? endDate,
    String? currency,
    List<String>? metrics,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.stripeAnalytics));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (currency != null) queryParams['currency'] = currency;
      if (metrics != null) queryParams['metrics'] = metrics.join(',');
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else {
        throw ApiException('Failed to fetch payment analytics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching payment analytics: $e');
    }
  }

  /// Handle Stripe webhook
  static Future<Map<String, dynamic>> handleWebhook({
    required Map<String, dynamic> payload,
    required String signature,
    String? accessToken,
  }) async {
    try {
      final requestBody = {
        'payload': payload,
        'signature': signature,
      };

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripeWebhook)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid webhook payload',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to handle webhook: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while handling webhook: $e');
    }
  }

  /// Get customer payment methods
  static Future<List<Map<String, dynamic>>> getCustomerPaymentMethods(String customerId, {
    String? accessToken,
    String? type,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.stripePaymentIntent) + '/customer/$customerId/payment-methods');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Customer not found');
      } else {
        throw ApiException('Failed to fetch customer payment methods: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching customer payment methods: $e');
    }
  }

  /// Get subscription details
  static Future<Map<String, dynamic>> getSubscription(String subscriptionId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripeSubscription) + '/$subscriptionId'),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Subscription not found');
      } else {
        throw ApiException('Failed to fetch subscription: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching subscription: $e');
    }
  }

  /// Update subscription
  static Future<Map<String, dynamic>> updateSubscription(String subscriptionId, Map<String, dynamic> updates, {String? accessToken}) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripeSubscription) + '/$subscriptionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Subscription not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid subscription updates',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update subscription: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating subscription: $e');
    }
  }

  /// Get customer invoices
  static Future<List<Map<String, dynamic>>> getCustomerInvoices(String customerId, {
    String? accessToken,
    int? limit,
    String? status,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.stripeAnalytics) + '/customer/$customerId/invoices');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (status != null) queryParams['status'] = status;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Customer not found');
      } else {
        throw ApiException('Failed to fetch customer invoices: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching customer invoices: $e');
    }
  }

  /// Retry invoice payment
  static Future<Map<String, dynamic>> retryInvoicePayment(String invoiceId, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.stripePaymentIntent) + '/invoice/$invoiceId/retry'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Invoice not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Cannot retry invoice payment',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to retry invoice payment: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while retrying invoice payment: $e');
    }
  }
}
