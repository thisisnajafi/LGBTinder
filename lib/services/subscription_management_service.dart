import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class SubscriptionManagementService {
  /// Get current subscription status
  static Future<Map<String, dynamic>> getCurrentSubscription({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionStatus)),
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
        throw ApiException('No active subscription found');
      } else {
        throw ApiException('Failed to fetch subscription status: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching subscription status: $e');
    }
  }

  /// Cancel subscription
  static Future<Map<String, dynamic>> cancelSubscription({
    String? accessToken,
    String? reason,
    bool? immediate,
    DateTime? cancelAt,
  }) async {
    try {
      final requestBody = <String, dynamic>{};
      
      if (reason != null) requestBody['reason'] = reason;
      if (immediate != null) requestBody['immediate'] = immediate;
      if (cancelAt != null) requestBody['cancel_at'] = cancelAt.toIso8601String();

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionCancel)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: requestBody.isNotEmpty ? jsonEncode(requestBody) : '{}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('No active subscription found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid cancellation parameters',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to cancel subscription: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while canceling subscription: $e');
    }
  }

  /// Reactivate subscription
  static Future<Map<String, dynamic>> reactivateSubscription({
    String? accessToken,
    String? reason,
  }) async {
    try {
      final requestBody = <String, dynamic>{};
      if (reason != null) requestBody['reason'] = reason;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionReactivate)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: requestBody.isNotEmpty ? jsonEncode(requestBody) : '{}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('No subscription found to reactivate');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Cannot reactivate subscription',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to reactivate subscription: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while reactivating subscription: $e');
    }
  }

  /// Pause subscription
  static Future<Map<String, dynamic>> pauseSubscription({
    String? accessToken,
    String? reason,
    DateTime? resumeAt,
    int? pauseDurationDays,
  }) async {
    try {
      final requestBody = <String, dynamic>{};
      
      if (reason != null) requestBody['reason'] = reason;
      if (resumeAt != null) requestBody['resume_at'] = resumeAt.toIso8601String();
      if (pauseDurationDays != null) requestBody['pause_duration_days'] = pauseDurationDays;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionPause)),
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
        throw ApiException('No active subscription found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid pause parameters',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to pause subscription: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while pausing subscription: $e');
    }
  }

  /// Resume subscription
  static Future<Map<String, dynamic>> resumeSubscription({
    String? accessToken,
    String? reason,
  }) async {
    try {
      final requestBody = <String, dynamic>{};
      if (reason != null) requestBody['reason'] = reason;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionResume)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: requestBody.isNotEmpty ? jsonEncode(requestBody) : '{}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('No paused subscription found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Cannot resume subscription',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to resume subscription: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while resuming subscription: $e');
    }
  }

  /// Change subscription plan
  static Future<Map<String, dynamic>> changeSubscriptionPlan({
    required String newPlanId,
    String? accessToken,
    bool? prorateBilling,
    DateTime? effectiveDate,
    String? reason,
  }) async {
    try {
      final requestBody = {
        'new_plan_id': newPlanId,
      };
      
      if (prorateBilling != null) requestBody['prorate_billing'] = prorateBilling;
      if (effectiveDate != null) requestBody['effective_date'] = effectiveDate.toIso8601String();
      if (reason != null) requestBody['reason'] = reason;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionChangePlan)),
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
        throw ApiException('No active subscription or plan not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid plan change parameters',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to change subscription plan: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while changing subscription plan: $e');
    }
  }

  /// Get subscription history
  static Future<List<Map<String, dynamic>>> getSubscriptionHistory({
    String? accessToken,
    int? page,
    int? limit,
    String? status,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionHistory));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
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
      } else {
        throw ApiException('Failed to fetch subscription history: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching subscription history: $e');
    }
  }

  /// Get subscription billing information
  static Future<Map<String, dynamic>> getBillingInformation({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionBilling)),
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
        throw ApiException('No billing information found');
      } else {
        throw ApiException('Failed to fetch billing information: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching billing information: $e');
    }
  }

  /// Update billing information
  static Future<Map<String, dynamic>> updateBillingInformation({
    required Map<String, dynamic> billingInfo,
    String? accessToken,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionBilling)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(billingInfo),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid billing information',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update billing information: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating billing information: $e');
    }
  }

  /// Get payment methods
  static Future<List<Map<String, dynamic>>> getPaymentMethods({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionPaymentMethods)),
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
      } else {
        throw ApiException('Failed to fetch payment methods: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching payment methods: $e');
    }
  }

  /// Set default payment method
  static Future<Map<String, dynamic>> setDefaultPaymentMethod({
    required String paymentMethodId,
    String? accessToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionPaymentMethods) + '/$paymentMethodId/set-default'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'action': 'set_default'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Payment method not found');
      } else {
        throw ApiException('Failed to set default payment method: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while setting default payment method: $e');
    }
  }

  /// Check feature access
  static Future<Map<String, dynamic>> checkFeatureAccess({
    required String feature,
    String? accessToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionFeatureAccess) + '/$feature'),
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
        throw ApiException('Feature not found');
      } else {
        throw ApiException('Failed to check feature access: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while checking feature access: $e');
    }
  }

  /// Get subscription usage statistics
  static Future<Map<String, dynamic>> getSubscriptionUsageStats({
    String? accessToken,
    String? period, // 'current', 'monthly', 'yearly'
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionUsageStats));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (period != null) queryParams['period'] = period;
      
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
      } else {
        throw ApiException('Failed to fetch subscription usage stats: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching subscription usage stats: $e');
    }
  }

  /// Get subscription renewal information
  static Future<Map<String, dynamic>> getSubscriptionRenewalInfo({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionRenewal)),
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
        throw ApiException('No active subscription found');
      } else {
        throw ApiException('Failed to fetch subscription renewal info: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching subscription renewal info: $e');
    }
  }

  /// Update subscription renewal settings
  static Future<Map<String, dynamic>> updateSubscriptionRenewalSettings({
    required Map<String, dynamic> renewalSettings,
    String? accessToken,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionRenewal)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(renewalSettings),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('No active subscription found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid renewal settings',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update subscription renewal settings: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating subscription renewal settings: $e');
    }
  }

  /// Get subscription cancellation reasons
  static Future<List<Map<String, dynamic>>> getCancellationReasons({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionCancelReasons)),
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
      } else {
        throw ApiException('Failed to fetch cancellation reasons: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching cancellation reasons: $e');
    }
  }

  /// Submit cancellation feedback
  static Future<bool> submitCancellationFeedback({
    required String reason,
    String? accessToken,
    String? additionalFeedback,
    int? rating,
  }) async {
    try {
      final requestBody = {'reason': reason};
      
      if (additionalFeedback != null) requestBody['additional_feedback'] = additionalFeedback;
      if (rating != null) requestBody['rating'] = rating;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subscriptionCancelFeedback)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid feedback data',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to submit cancellation feedback: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while submitting cancellation feedback: $e');
    }
  }
}
