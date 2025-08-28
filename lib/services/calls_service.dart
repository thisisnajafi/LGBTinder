import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class CallsService {
  /// Initiate a call
  static Future<Map<String, dynamic>> initiateCall({
    required String recipientId,
    required String callType, // 'voice' or 'video'
    String? accessToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.callsInitiate)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'recipient_id': recipientId,
          'call_type': callType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Recipient not found');
      } else if (response.statusCode == 403) {
        throw ApiException('Cannot call this user');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to initiate call: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while initiating call: $e');
    }
  }

  /// Accept a call
  static Future<Map<String, dynamic>> acceptCall(String callId, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.callsAccept)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'call_id': callId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Call not found');
      } else if (response.statusCode == 403) {
        throw ApiException('Cannot accept this call');
      } else if (response.statusCode == 409) {
        throw ApiException('Call already ended or answered');
      } else {
        throw ApiException('Failed to accept call: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while accepting call: $e');
    }
  }

  /// Reject a call
  static Future<Map<String, dynamic>> rejectCall(String callId, {String? accessToken, String? reason}) async {
    try {
      final requestBody = {'call_id': callId};
      if (reason != null) requestBody['reason'] = reason;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.callsReject)),
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
        throw ApiException('Call not found');
      } else if (response.statusCode == 403) {
        throw ApiException('Cannot reject this call');
      } else if (response.statusCode == 409) {
        throw ApiException('Call already ended or answered');
      } else {
        throw ApiException('Failed to reject call: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while rejecting call: $e');
    }
  }

  /// End a call
  static Future<Map<String, dynamic>> endCall(String callId, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.callsEnd)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'call_id': callId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Call not found');
      } else if (response.statusCode == 403) {
        throw ApiException('Cannot end this call');
      } else {
        throw ApiException('Failed to end call: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while ending call: $e');
    }
  }

  /// Get call history
  static Future<List<Map<String, dynamic>>> getCallHistory({
    String? accessToken,
    int? page,
    int? limit,
    String? callType,
    String? status,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.callsHistory));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (callType != null) queryParams['call_type'] = callType;
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
        throw ApiException('Failed to fetch call history: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching call history: $e');
    }
  }

  /// Get active calls
  static Future<List<Map<String, dynamic>>> getActiveCalls({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.callsActive)),
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
        throw ApiException('Failed to fetch active calls: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching active calls: $e');
    }
  }

  /// Get call status
  static Future<Map<String, dynamic>> getCallStatus(String callId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.callsActive) + '/$callId'),
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
        throw ApiException('Call not found');
      } else {
        throw ApiException('Failed to fetch call status: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching call status: $e');
    }
  }

  /// Update call settings during a call
  static Future<Map<String, dynamic>> updateCallSettings(String callId, Map<String, dynamic> settings, {String? accessToken}) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getUrl(ApiConfig.callsActive) + '/$callId/settings'),
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
        throw ApiException('Call not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid settings',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update call settings: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating call settings: $e');
    }
  }

  /// Report call quality
  static Future<bool> reportCallQuality(String callId, {
    required int rating, // 1-5
    String? feedback,
    String? accessToken,
    Map<String, dynamic>? technicalInfo,
  }) async {
    try {
      final requestBody = {
        'call_id': callId,
        'rating': rating,
      };
      
      if (feedback != null) requestBody['feedback'] = feedback;
      if (technicalInfo != null) requestBody['technical_info'] = technicalInfo;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.callsHistory) + '/quality-report'),
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
      } else if (response.statusCode == 404) {
        throw ApiException('Call not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid rating or feedback',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to report call quality: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while reporting call quality: $e');
    }
  }

  /// Get call statistics
  static Future<Map<String, dynamic>> getCallStatistics({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.callsHistory) + '/statistics'),
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
        throw ApiException('Failed to fetch call statistics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching call statistics: $e');
    }
  }

  /// Check if user is available for calls
  static Future<Map<String, dynamic>> checkUserAvailability(String userId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.callsActive) + '/availability?user_id=$userId'),
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
        throw ApiException('User not found');
      } else {
        throw ApiException('Failed to check user availability: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while checking user availability: $e');
    }
  }

  /// Update user's call availability status
  static Future<bool> updateCallAvailability({
    required bool isAvailable,
    String? accessToken,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final requestBody = {'is_available': isAvailable};
      if (settings != null) requestBody['settings'] = settings;

      final response = await http.put(
        Uri.parse(ApiConfig.getUrl(ApiConfig.callsActive) + '/availability'),
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
          data['message'] ?? 'Invalid availability settings',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update call availability: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating call availability: $e');
    }
  }
}
