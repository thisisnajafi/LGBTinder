import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class SubscriptionPlansService {
  /// Get all subscription plans
  static Future<List<Map<String, dynamic>>> getSubscriptionPlans({
    String? accessToken,
    bool? activeOnly,
    String? currency,
    String? sortBy,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.subPlans));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (activeOnly != null) queryParams['active_only'] = activeOnly.toString();
      if (currency != null) queryParams['currency'] = currency;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      
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
        throw ApiException('Failed to fetch subscription plans: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching subscription plans: $e');
    }
  }

  /// Get subscription plans by duration
  static Future<List<Map<String, dynamic>>> getSubscriptionPlansByDuration({
    String? accessToken,
    String? duration, // 'monthly', 'quarterly', 'yearly'
    String? currency,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.subPlansDuration));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (duration != null) queryParams['duration'] = duration;
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
        throw ApiException('Failed to fetch subscription plans by duration: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching subscription plans by duration: $e');
    }
  }

  /// Compare subscription plans
  static Future<Map<String, dynamic>> comparePlans({
    required List<String> planIds,
    String? accessToken,
    String? currency,
  }) async {
    try {
      final requestBody = {'plan_ids': planIds};
      if (currency != null) requestBody['currency'] = currency;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subPlansCompare)),
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
          data['message'] ?? 'Invalid plan IDs for comparison',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to compare plans: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while comparing plans: $e');
    }
  }

  /// Get subplans for a specific plan
  static Future<List<Map<String, dynamic>>> getSubplansForPlan(String planId, {
    String? accessToken,
    String? currency,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.subPlansGetByPlan, {'planId': planId}));
      
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
      } else if (response.statusCode == 404) {
        throw ApiException('Plan not found');
      } else {
        throw ApiException('Failed to fetch subplans for plan: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching subplans for plan: $e');
    }
  }

  /// Get upgrade options for current subscription
  static Future<List<Map<String, dynamic>>> getUpgradeOptions({
    String? accessToken,
    String? currentPlanId,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.subPlansUpgradeOptions));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (currentPlanId != null) queryParams['current_plan_id'] = currentPlanId;
      
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

  /// Upgrade subscription plan
  static Future<Map<String, dynamic>> upgradePlan({
    required String newPlanId,
    String? accessToken,
    bool? prorateBilling,
    DateTime? effectiveDate,
  }) async {
    try {
      final requestBody = {'new_plan_id': newPlanId};
      
      if (prorateBilling != null) requestBody['prorate_billing'] = prorateBilling;
      if (effectiveDate != null) requestBody['effective_date'] = effectiveDate.toIso8601String();

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subPlansUpgrade)),
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
        throw ApiException('Plan not found or no active subscription');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid upgrade parameters',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to upgrade plan: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while upgrading plan: $e');
    }
  }

  /// Get subplan by ID
  static Future<Map<String, dynamic>> getSubplan(String subPlanId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.subPlansGetById, {'subPlan': subPlanId})),
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
        throw ApiException('Subplan not found');
      } else {
        throw ApiException('Failed to fetch subplan: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching subplan: $e');
    }
  }

  /// Get plan features comparison
  static Future<Map<String, dynamic>> getPlanFeaturesComparison({
    required List<String> planIds,
    String? accessToken,
  }) async {
    try {
      final requestBody = {'plan_ids': planIds};

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subPlansCompare) + '/features'),
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
          data['message'] ?? 'Invalid plan IDs for features comparison',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to get plan features comparison: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while getting plan features comparison: $e');
    }
  }

  /// Get plan pricing by region
  static Future<Map<String, dynamic>> getPlanPricingByRegion(String planId, {
    String? accessToken,
    String? region,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.subPlansGetById, {'subPlan': planId}) + '/pricing');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (region != null) queryParams['region'] = region;
      
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
        throw ApiException('Plan not found');
      } else {
        throw ApiException('Failed to get plan pricing by region: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while getting plan pricing by region: $e');
    }
  }

  /// Get downgrade options
  static Future<List<Map<String, dynamic>>> getDowngradeOptions({
    String? accessToken,
    String? currentPlanId,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.subPlansUpgradeOptions) + '/downgrade');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (currentPlanId != null) queryParams['current_plan_id'] = currentPlanId;
      
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
        throw ApiException('Failed to fetch downgrade options: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching downgrade options: $e');
    }
  }

  /// Get popular plans
  static Future<List<Map<String, dynamic>>> getPopularPlans({
    String? accessToken,
    String? currency,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.subPlans) + '/popular');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (currency != null) queryParams['currency'] = currency;
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
        throw ApiException('Failed to fetch popular plans: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching popular plans: $e');
    }
  }

  /// Get plan recommendations based on user profile
  static Future<List<Map<String, dynamic>>> getPlanRecommendations({
    String? accessToken,
    String? currency,
    Map<String, dynamic>? userPreferences,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.subPlans) + '/recommendations');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (currency != null) queryParams['currency'] = currency;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final requestBody = <String, dynamic>{};
      if (userPreferences != null) requestBody['user_preferences'] = userPreferences;

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: requestBody.isNotEmpty ? jsonEncode(requestBody) : null,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch plan recommendations: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching plan recommendations: $e');
    }
  }

  /// Calculate plan savings
  static Future<Map<String, dynamic>> calculatePlanSavings({
    required String fromPlanId,
    required String toPlanId,
    String? accessToken,
    String? currency,
  }) async {
    try {
      final requestBody = {
        'from_plan_id': fromPlanId,
        'to_plan_id': toPlanId,
      };
      
      if (currency != null) requestBody['currency'] = currency;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.subPlansCompare) + '/savings'),
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
        throw ApiException('One or both plans not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid plan IDs for savings calculation',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to calculate plan savings: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while calculating plan savings: $e');
    }
  }
}
