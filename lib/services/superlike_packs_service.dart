import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class SuperlikePacksService {
  /// Handle Stripe webhook for superlike packs
  static Future<Map<String, dynamic>> handleStripeWebhook({
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
        Uri.parse(ApiConfig.getUrl(ApiConfig.superlikePacksWebhook)),
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

  /// Create Stripe checkout session for superlike pack
  static Future<Map<String, dynamic>> createStripeCheckout({
    required String packId,
    required String successUrl,
    required String cancelUrl,
    String? accessToken,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final requestBody = {
        'pack_id': packId,
        'success_url': successUrl,
        'cancel_url': cancelUrl,
      };

      if (customerId != null) requestBody['customer_id'] = customerId;
      if (metadata != null) requestBody['metadata'] = metadata;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.superlikePacksCheckout)),
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
        throw ApiException('Superlike pack not found');
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

  /// Get available superlike packs
  static Future<List<Map<String, dynamic>>> getAvailablePacks({
    String? accessToken,
    String? currency,
    bool? activeOnly,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.superlikePacksAvailable));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (currency != null) queryParams['currency'] = currency;
      if (activeOnly != null) queryParams['active_only'] = activeOnly.toString();
      
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
        throw ApiException('Failed to fetch available packs: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching available packs: $e');
    }
  }

  /// Purchase superlike pack
  static Future<Map<String, dynamic>> purchasePack({
    required String packId,
    required String paymentMethodId,
    String? accessToken,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final requestBody = {
        'pack_id': packId,
        'payment_method_id': paymentMethodId,
      };

      if (metadata != null) requestBody['metadata'] = metadata;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.superlikePacksPurchase)),
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
        throw ApiException('Superlike pack not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid purchase parameters',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 402) {
        throw ApiException('Payment required or payment method declined');
      } else {
        throw ApiException('Failed to purchase pack: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while purchasing pack: $e');
    }
  }

  /// Get user's superlike packs
  static Future<List<Map<String, dynamic>>> getUserPacks({
    String? accessToken,
    String? status, // 'active', 'expired', 'pending'
    int? page,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.superlikePacksUserPacks));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (page != null) queryParams['page'] = page.toString();
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
      } else {
        throw ApiException('Failed to fetch user packs: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching user packs: $e');
    }
  }

  /// Get purchase history
  static Future<List<Map<String, dynamic>>> getPurchaseHistory({
    String? accessToken,
    int? page,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.superlikePacksHistory));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
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

  /// Activate pending superlike pack
  static Future<Map<String, dynamic>> activatePendingPack({
    required String purchaseId,
    String? accessToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.superlikePacksActivate)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'purchase_id': purchaseId,
        }),
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
          data['message'] ?? 'Cannot activate this pack',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to activate pending pack: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while activating pending pack: $e');
    }
  }

  /// Get pack details
  static Future<Map<String, dynamic>> getPackDetails(String packId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.superlikePacksAvailable) + '/$packId'),
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
        throw ApiException('Pack not found');
      } else {
        throw ApiException('Failed to fetch pack details: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching pack details: $e');
    }
  }

  /// Get current superlike balance
  static Future<Map<String, dynamic>> getSuperlikeBalance({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.superlikePacksUserPacks) + '/balance'),
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
        throw ApiException('Failed to fetch superlike balance: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching superlike balance: $e');
    }
  }

  /// Use superlike from pack
  static Future<Map<String, dynamic>> useSuperlike({
    required String targetUserId,
    String? accessToken,
    String? packId,
  }) async {
    try {
      final requestBody = {'target_user_id': targetUserId};
      
      if (packId != null) requestBody['pack_id'] = packId;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.superlikePacksUserPacks) + '/use'),
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
        throw ApiException('Target user not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Cannot use superlike',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 429) {
        throw ApiException('Superlike limit reached or insufficient balance');
      } else {
        throw ApiException('Failed to use superlike: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while using superlike: $e');
    }
  }

  /// Get pack usage statistics
  static Future<Map<String, dynamic>> getPackUsageStats(String packId, {
    String? accessToken,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.superlikePacksUserPacks) + '/$packId/stats');
      
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
        throw ApiException('Pack not found');
      } else {
        throw ApiException('Failed to fetch pack usage statistics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching pack usage statistics: $e');
    }
  }

  /// Get recommended packs for user
  static Future<List<Map<String, dynamic>>> getRecommendedPacks({
    String? accessToken,
    String? currency,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.superlikePacksAvailable) + '/recommended');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (currency != null) queryParams['currency'] = currency;
      
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
        throw ApiException('Failed to fetch recommended packs: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching recommended packs: $e');
    }
  }

  /// Cancel pack purchase
  static Future<Map<String, dynamic>> cancelPackPurchase(String purchaseId, {
    String? accessToken,
    String? reason,
  }) async {
    try {
      final requestBody = <String, dynamic>{};
      if (reason != null) requestBody['reason'] = reason;

      final response = await http.delete(
        Uri.parse(ApiConfig.getUrl(ApiConfig.superlikePacksHistory) + '/$purchaseId'),
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
        throw ApiException('Failed to cancel pack purchase: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while canceling pack purchase: $e');
    }
  }

  /// Get pack expiry information
  static Future<Map<String, dynamic>> getPackExpiry(String packId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.superlikePacksUserPacks) + '/$packId/expiry'),
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
        throw ApiException('Pack not found');
      } else {
        throw ApiException('Failed to fetch pack expiry information: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching pack expiry information: $e');
    }
  }
}
