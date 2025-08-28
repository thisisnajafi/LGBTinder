import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class PlanPurchasesService {
  /// Get plan purchases
  static Future<List<Map<String, dynamic>>> getPlanPurchases({
    String? accessToken,
    int? page,
    int? limit,
    String? status,
    String? planId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.planPurchases));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (status != null) queryParams['status'] = status;
      if (planId != null) queryParams['plan_id'] = planId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      
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
        throw ApiException('Failed to fetch plan purchases: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching plan purchases: $e');
    }
  }

  /// Create plan purchase
  static Future<Map<String, dynamic>> createPlanPurchase({
    required String planId,
    required String paymentMethodId,
    String? accessToken,
    String? promoCode,
    Map<String, dynamic>? metadata,
    bool? autoRenew,
  }) async {
    try {
      final requestBody = {
        'plan_id': planId,
        'payment_method_id': paymentMethodId,
      };

      if (promoCode != null) requestBody['promo_code'] = promoCode;
      if (metadata != null) requestBody['metadata'] = metadata;
      if (autoRenew != null) requestBody['auto_renew'] = autoRenew;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.planPurchases)),
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
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 402) {
        throw ApiException('Payment required or payment method declined');
      } else {
        throw ApiException('Failed to create plan purchase: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while creating plan purchase: $e');
    }
  }

  /// Get purchase history
  static Future<List<Map<String, dynamic>>> getPurchaseHistory({
    String? accessToken,
    int? page,
    int? limit,
    String? planType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.planPurchasesHistory));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (planType != null) queryParams['plan_type'] = planType;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      
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
        throw ApiException('Failed to fetch purchase history: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching purchase history: $e');
    }
  }

  /// Get active purchases
  static Future<List<Map<String, dynamic>>> getActivePurchases({
    String? accessToken,
    String? planType,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.planPurchasesActive));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (planType != null) queryParams['plan_type'] = planType;
      
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
        throw ApiException('Failed to fetch active purchases: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching active purchases: $e');
    }
  }

  /// Get expired purchases
  static Future<List<Map<String, dynamic>>> getExpiredPurchases({
    String? accessToken,
    int? page,
    int? limit,
    String? planType,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.planPurchasesExpired));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (planType != null) queryParams['plan_type'] = planType;
      
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
        throw ApiException('Failed to fetch expired purchases: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching expired purchases: $e');
    }
  }

  /// Get upgrade options
  static Future<List<Map<String, dynamic>>> getUpgradeOptions({
    String? accessToken,
    String? currentPurchaseId,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.planPurchasesUpgradeOptions));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (currentPurchaseId != null) queryParams['current_purchase_id'] = currentPurchaseId;
      
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
        throw ApiException('Failed to fetch upgrade options: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching upgrade options: $e');
    }
  }

  /// Get purchase by ID
  static Future<Map<String, dynamic>> getPurchase(String purchaseId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.planPurchasesById, {'id': purchaseId})),
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
        throw ApiException('Purchase not found');
      } else {
        throw ApiException('Failed to fetch purchase: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching purchase: $e');
    }
  }

  /// Cancel purchase
  static Future<Map<String, dynamic>> cancelPurchase(String purchaseId, {
    String? accessToken,
    String? reason,
    bool? immediate,
  }) async {
    try {
      final requestBody = <String, dynamic>{};
      
      if (reason != null) requestBody['reason'] = reason;
      if (immediate != null) requestBody['immediate'] = immediate;

      final response = await http.delete(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.planPurchasesById, {'id': purchaseId})),
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
        throw ApiException('Purchase not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Cannot cancel this purchase',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to cancel purchase: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while canceling purchase: $e');
    }
  }

  /// Renew purchase
  static Future<Map<String, dynamic>> renewPurchase(String purchaseId, {
    String? accessToken,
    String? paymentMethodId,
    bool? autoRenew,
  }) async {
    try {
      final requestBody = <String, dynamic>{};
      
      if (paymentMethodId != null) requestBody['payment_method_id'] = paymentMethodId;
      if (autoRenew != null) requestBody['auto_renew'] = autoRenew;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.planPurchasesById, {'id': purchaseId}) + '/renew'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: requestBody.isNotEmpty ? jsonEncode(requestBody) : jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Purchase not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Cannot renew this purchase',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 402) {
        throw ApiException('Payment required or payment method declined');
      } else {
        throw ApiException('Failed to renew purchase: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while renewing purchase: $e');
    }
  }

  /// Update purchase settings
  static Future<Map<String, dynamic>> updatePurchaseSettings(String purchaseId, Map<String, dynamic> settings, {String? accessToken}) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.planPurchasesById, {'id': purchaseId})),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(settings),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Purchase not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid settings',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update purchase settings: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating purchase settings: $e');
    }
  }

  /// Get purchase invoices
  static Future<List<Map<String, dynamic>>> getPurchaseInvoices(String purchaseId, {
    String? accessToken,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.planPurchasesById, {'id': purchaseId}) + '/invoices');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      
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
        throw ApiException('Purchase not found');
      } else {
        throw ApiException('Failed to fetch purchase invoices: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching purchase invoices: $e');
    }
  }

  /// Get purchase usage statistics
  static Future<Map<String, dynamic>> getPurchaseUsageStats(String purchaseId, {
    String? accessToken,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.planPurchasesById, {'id': purchaseId}) + '/usage');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      
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
      } else if (response.statusCode == 404) {
        throw ApiException('Purchase not found');
      } else {
        throw ApiException('Failed to fetch purchase usage statistics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching purchase usage statistics: $e');
    }
  }

  /// Apply promo code to purchase
  static Future<Map<String, dynamic>> applyPromoCode(String purchaseId, String promoCode, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.planPurchasesById, {'id': purchaseId}) + '/promo'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'promo_code': promoCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Purchase or promo code not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid or expired promo code',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to apply promo code: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while applying promo code: $e');
    }
  }

  /// Get purchase refund status
  static Future<Map<String, dynamic>> getPurchaseRefundStatus(String purchaseId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.planPurchasesById, {'id': purchaseId}) + '/refund'),
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
        throw ApiException('Purchase not found');
      } else {
        throw ApiException('Failed to fetch purchase refund status: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching purchase refund status: $e');
    }
  }

  /// Request refund for purchase
  static Future<Map<String, dynamic>> requestRefund(String purchaseId, {
    String? accessToken,
    String? reason,
    int? amount,
  }) async {
    try {
      final requestBody = <String, dynamic>{};
      
      if (reason != null) requestBody['reason'] = reason;
      if (amount != null) requestBody['amount'] = amount;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.planPurchasesById, {'id': purchaseId}) + '/refund'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: requestBody.isNotEmpty ? jsonEncode(requestBody) : jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Purchase not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Cannot request refund for this purchase',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to request refund: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while requesting refund: $e');
    }
  }
}
