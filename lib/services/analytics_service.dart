import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class AnalyticsService {
  /// Get user's personal analytics
  static Future<Map<String, dynamic>> getMyAnalytics({
    String? accessToken,
    String? period, // 'week', 'month', 'year'
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsMyAnalytics));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (period != null) queryParams['period'] = period;
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
      } else {
        throw ApiException('Failed to fetch user analytics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching user analytics: $e');
    }
  }

  /// Get engagement analytics
  static Future<Map<String, dynamic>> getEngagementAnalytics({
    String? accessToken,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? metrics,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsEngagement));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
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
      } else {
        throw ApiException('Failed to fetch engagement analytics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching engagement analytics: $e');
    }
  }

  /// Get retention analytics
  static Future<Map<String, dynamic>> getRetentionAnalytics({
    String? accessToken,
    String? cohortType, // 'daily', 'weekly', 'monthly'
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsRetention));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (cohortType != null) queryParams['cohort_type'] = cohortType;
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
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else {
        throw ApiException('Failed to fetch retention analytics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching retention analytics: $e');
    }
  }

  /// Get interactions analytics
  static Future<Map<String, dynamic>> getInteractionsAnalytics({
    String? accessToken,
    String? interactionType, // 'likes', 'matches', 'messages', 'calls'
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsInteractions));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (interactionType != null) queryParams['interaction_type'] = interactionType;
      if (period != null) queryParams['period'] = period;
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
      } else {
        throw ApiException('Failed to fetch interactions analytics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching interactions analytics: $e');
    }
  }

  /// Get profile metrics
  static Future<Map<String, dynamic>> getProfileMetrics({
    String? accessToken,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsProfileMetrics));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (period != null) queryParams['period'] = period;
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
      } else {
        throw ApiException('Failed to fetch profile metrics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching profile metrics: $e');
    }
  }

  /// Track user activity
  static Future<bool> trackActivity({
    required String activityType,
    String? accessToken,
    Map<String, dynamic>? properties,
    DateTime? timestamp,
    String? sessionId,
    Map<String, dynamic>? context,
  }) async {
    try {
      final requestBody = {'activity_type': activityType};

      if (properties != null) requestBody['properties'] = properties;
      if (timestamp != null) requestBody['timestamp'] = timestamp.toIso8601String();
      if (sessionId != null) requestBody['session_id'] = sessionId;
      if (context != null) requestBody['context'] = context;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsTrackActivity)),
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
          data['message'] ?? 'Invalid activity data',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to track activity: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while tracking activity: $e');
    }
  }

  /// Get dashboard summary
  static Future<Map<String, dynamic>> getDashboardSummary({
    String? accessToken,
    String? period,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsMyAnalytics) + '/dashboard');
      
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
        throw ApiException('Failed to fetch dashboard summary: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching dashboard summary: $e');
    }
  }

  /// Get comparative analytics (compare with similar users)
  static Future<Map<String, dynamic>> getComparativeAnalytics({
    String? accessToken,
    String? metric,
    String? period,
    List<String>? compareWith, // demographic filters
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsMyAnalytics) + '/compare');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (metric != null) queryParams['metric'] = metric;
      if (period != null) queryParams['period'] = period;
      if (compareWith != null) queryParams['compare_with'] = compareWith.join(',');
      
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
        throw ApiException('Failed to fetch comparative analytics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching comparative analytics: $e');
    }
  }

  /// Get funnel analytics
  static Future<Map<String, dynamic>> getFunnelAnalytics({
    String? accessToken,
    required List<String> funnelSteps,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsEngagement) + '/funnel');
      
      // Add query parameters
      final queryParams = <String, String>{
        'funnel_steps': funnelSteps.join(','),
      };
      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      
      uri = uri.replace(queryParameters: queryParams);

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
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid funnel steps',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to fetch funnel analytics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching funnel analytics: $e');
    }
  }

  /// Get heat map data
  static Future<Map<String, dynamic>> getHeatMapData({
    String? accessToken,
    required String heatMapType, // 'activity', 'interactions', 'time_spent'
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsEngagement) + '/heatmap');
      
      // Add query parameters
      final queryParams = <String, String>{
        'heatmap_type': heatMapType,
      };
      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      
      uri = uri.replace(queryParameters: queryParams);

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
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid heatmap parameters',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to fetch heatmap data: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching heatmap data: $e');
    }
  }

  /// Export analytics data
  static Future<Map<String, dynamic>> exportAnalyticsData({
    String? accessToken,
    required String exportType, // 'csv', 'json', 'pdf'
    required List<String> metrics,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final requestBody = {
        'export_type': exportType,
        'metrics': metrics,
      };

      if (period != null) requestBody['period'] = period;
      if (startDate != null) requestBody['start_date'] = startDate.toIso8601String();
      if (endDate != null) requestBody['end_date'] = endDate.toIso8601String();

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsMyAnalytics) + '/export'),
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
          data['message'] ?? 'Invalid export parameters',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to export analytics data: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while exporting analytics data: $e');
    }
  }

  /// Get real-time analytics
  static Future<Map<String, dynamic>> getRealTimeAnalytics({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsEngagement) + '/realtime'),
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
        throw ApiException('Failed to fetch real-time analytics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching real-time analytics: $e');
    }
  }

  /// Track custom event
  static Future<bool> trackCustomEvent({
    required String eventName,
    String? accessToken,
    Map<String, dynamic>? eventProperties,
    String? userId,
    DateTime? timestamp,
  }) async {
    try {
      final requestBody = {'event_name': eventName};

      if (eventProperties != null) requestBody['event_properties'] = eventProperties;
      if (userId != null) requestBody['user_id'] = userId;
      if (timestamp != null) requestBody['timestamp'] = timestamp.toIso8601String();

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsTrackActivity) + '/custom'),
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
          data['message'] ?? 'Invalid event data',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to track custom event: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while tracking custom event: $e');
    }
  }

  /// Get user journey analytics
  static Future<Map<String, dynamic>> getUserJourneyAnalytics({
    String? accessToken,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? journeySteps,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsEngagement) + '/journey');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (journeySteps != null) queryParams['journey_steps'] = journeySteps.join(',');
      
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
        throw ApiException('Failed to fetch user journey analytics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching user journey analytics: $e');
    }
  }

  /// Get conversion analytics
  static Future<Map<String, dynamic>> getConversionAnalytics({
    String? accessToken,
    String? conversionType, // 'signup', 'premium', 'match', 'message'
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsEngagement) + '/conversion');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (conversionType != null) queryParams['conversion_type'] = conversionType;
      if (period != null) queryParams['period'] = period;
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
      } else {
        throw ApiException('Failed to fetch conversion analytics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching conversion analytics: $e');
    }
  }

  /// Get cohort analytics
  static Future<Map<String, dynamic>> getCohortAnalytics({
    String? accessToken,
    String? cohortType, // 'signup', 'first_match', 'premium_purchase'
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsRetention) + '/cohort');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (cohortType != null) queryParams['cohort_type'] = cohortType;
      if (period != null) queryParams['period'] = period;
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
      } else {
        throw ApiException('Failed to fetch cohort analytics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching cohort analytics: $e');
    }
  }

  /// Get session analytics
  static Future<Map<String, dynamic>> getSessionAnalytics({
    String? accessToken,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    String? sessionType, // 'mobile', 'web', 'all'
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsEngagement) + '/sessions');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (sessionType != null) queryParams['session_type'] = sessionType;
      
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
        throw ApiException('Failed to fetch session analytics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching session analytics: $e');
    }
  }

  /// Track user session
  static Future<bool> trackUserSession({
    required String sessionId,
    required DateTime startTime,
    String? accessToken,
    DateTime? endTime,
    Map<String, dynamic>? sessionData,
    String? deviceInfo,
  }) async {
    try {
      final requestBody = {
        'session_id': sessionId,
        'start_time': startTime.toIso8601String(),
      };

      if (endTime != null) requestBody['end_time'] = endTime.toIso8601String();
      if (sessionData != null) requestBody['session_data'] = sessionData;
      if (deviceInfo != null) requestBody['device_info'] = deviceInfo;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsTrackActivity) + '/session'),
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
          data['message'] ?? 'Invalid session data',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to track user session: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while tracking user session: $e');
    }
  }

  /// Get performance metrics
  static Future<Map<String, dynamic>> getPerformanceMetrics({
    String? accessToken,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? metrics, // 'response_time', 'error_rate', 'throughput'
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsEngagement) + '/performance');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
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
      } else {
        throw ApiException('Failed to fetch performance metrics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching performance metrics: $e');
    }
  }

  /// Get user segmentation analytics
  static Future<Map<String, dynamic>> getUserSegmentationAnalytics({
    String? accessToken,
    String? segmentType, // 'demographic', 'behavioral', 'engagement'
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.analyticsMyAnalytics) + '/segmentation');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (segmentType != null) queryParams['segment_type'] = segmentType;
      if (period != null) queryParams['period'] = period;
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
      } else {
        throw ApiException('Failed to fetch user segmentation analytics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching user segmentation analytics: $e');
    }
  }
}
