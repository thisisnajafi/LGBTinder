import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class PlanPurchaseActionsService {
  /// Get purchase actions
  static Future<List<Map<String, dynamic>>> getPurchaseActions({
    String? accessToken,
    int? page,
    int? limit,
    String? status,
    String? actionType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.planPurchaseActions));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (status != null) queryParams['status'] = status;
      if (actionType != null) queryParams['action_type'] = actionType;
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
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else {
        throw ApiException('Failed to fetch purchase actions: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching purchase actions: $e');
    }
  }

  /// Create purchase action
  static Future<Map<String, dynamic>> createPurchaseAction({
    required String actionType,
    required String planId,
    String? accessToken,
    Map<String, dynamic>? actionData,
    String? description,
    DateTime? scheduledDate,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final requestBody = {
        'action_type': actionType,
        'plan_id': planId,
      };

      if (actionData != null) requestBody['action_data'] = actionData;
      if (description != null) requestBody['description'] = description;
      if (scheduledDate != null) requestBody['scheduled_date'] = scheduledDate.toIso8601String();
      if (metadata != null) requestBody['metadata'] = metadata;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.planPurchaseActions)),
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
      } else {
        throw ApiException('Failed to create purchase action: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while creating purchase action: $e');
    }
  }

  /// Get purchase action statistics
  static Future<Map<String, dynamic>> getPurchaseActionStatistics({
    String? accessToken,
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy, // 'day', 'week', 'month'
    List<String>? actionTypes,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.planPurchaseActionsStats));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (groupBy != null) queryParams['group_by'] = groupBy;
      if (actionTypes != null) queryParams['action_types'] = actionTypes.join(',');
      
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
        throw ApiException('Failed to fetch purchase action statistics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching purchase action statistics: $e');
    }
  }

  /// Get today's purchase actions
  static Future<List<Map<String, dynamic>>> getTodaysPurchaseActions({
    String? accessToken,
    String? status,
    String? actionType,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.planPurchaseActionsToday));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (actionType != null) queryParams['action_type'] = actionType;
      
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
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else {
        throw ApiException('Failed to fetch today\'s purchase actions: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching today\'s purchase actions: $e');
    }
  }

  /// Get purchase action status
  static Future<Map<String, dynamic>> getPurchaseActionStatus({
    String? accessToken,
    String? actionId,
    String? userId,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.planPurchaseActionsStatus));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (actionId != null) queryParams['action_id'] = actionId;
      if (userId != null) queryParams['user_id'] = userId;
      
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
        throw ApiException('Purchase action not found');
      } else {
        throw ApiException('Failed to fetch purchase action status: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching purchase action status: $e');
    }
  }

  /// Get user's purchase actions
  static Future<List<Map<String, dynamic>>> getUserPurchaseActions(String userId, {
    String? accessToken,
    int? page,
    int? limit,
    String? status,
    String? actionType,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.planPurchaseActionsUser, {'userId': userId}));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (status != null) queryParams['status'] = status;
      if (actionType != null) queryParams['action_type'] = actionType;
      
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
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException('User not found');
      } else {
        throw ApiException('Failed to fetch user purchase actions: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching user purchase actions: $e');
    }
  }

  /// Get purchase action by ID
  static Future<Map<String, dynamic>> getPurchaseAction(String actionId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.planPurchaseActionsById, {'id': actionId})),
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
      } else if (response.statusCode == 404) {
        throw ApiException('Purchase action not found');
      } else {
        throw ApiException('Failed to fetch purchase action: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching purchase action: $e');
    }
  }

  /// Update purchase action status
  static Future<Map<String, dynamic>> updatePurchaseActionStatus(String actionId, {
    required String status,
    String? accessToken,
    String? reason,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final requestBody = {'status': status};
      
      if (reason != null) requestBody['reason'] = reason;
      if (additionalData != null) requestBody['additional_data'] = additionalData;

      final response = await http.patch(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.planPurchaseActionsUpdateStatus, {'id': actionId})),
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
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException('Purchase action not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid status update',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update purchase action status: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating purchase action status: $e');
    }
  }

  /// Cancel purchase action
  static Future<bool> cancelPurchaseAction(String actionId, {
    String? accessToken,
    String? reason,
  }) async {
    try {
      final requestBody = <String, dynamic>{};
      if (reason != null) requestBody['reason'] = reason;

      final response = await http.delete(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.planPurchaseActionsById, {'id': actionId})),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: requestBody.isNotEmpty ? jsonEncode(requestBody) : null,
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException('Purchase action not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Cannot cancel this purchase action',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to cancel purchase action: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while canceling purchase action: $e');
    }
  }

  /// Execute purchase action
  static Future<Map<String, dynamic>> executePurchaseAction(String actionId, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.planPurchaseActionsById, {'id': actionId}) + '/execute'),
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
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException('Purchase action not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Cannot execute this purchase action',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to execute purchase action: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while executing purchase action: $e');
    }
  }

  /// Get purchase action types
  static Future<List<Map<String, dynamic>>> getPurchaseActionTypes({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.planPurchaseActions) + '/types'),
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
        throw ApiException('Failed to fetch purchase action types: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching purchase action types: $e');
    }
  }

  /// Get purchase action history
  static Future<List<Map<String, dynamic>>> getPurchaseActionHistory(String actionId, {
    String? accessToken,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.planPurchaseActionsById, {'id': actionId}) + '/history');
      
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
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException('Purchase action not found');
      } else {
        throw ApiException('Failed to fetch purchase action history: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching purchase action history: $e');
    }
  }

  /// Retry failed purchase action
  static Future<Map<String, dynamic>> retryPurchaseAction(String actionId, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.planPurchaseActionsById, {'id': actionId}) + '/retry'),
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
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException('Purchase action not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Cannot retry this purchase action',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to retry purchase action: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while retrying purchase action: $e');
    }
  }
}
