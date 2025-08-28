import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';
import '../utils/error_handler.dart';

class MatchingService {
  /// Get user matches
  static Future<List<User>> getMatches({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.matchingMatches)),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.map((item) => User.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch matches: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching matches: $e');
    }
  }

  /// Get nearby suggestions
  static Future<List<User>> getNearbyUsers({String? accessToken, double? latitude, double? longitude, int? radius}) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.matchingNearby));
      
      // Add query parameters if provided
      if (latitude != null || longitude != null || radius != null) {
        final queryParams = <String, String>{};
        if (latitude != null) queryParams['latitude'] = latitude.toString();
        if (longitude != null) queryParams['longitude'] = longitude.toString();
        if (radius != null) queryParams['radius'] = radius.toString();
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
        return items.map((item) => User.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch nearby users: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching nearby users: $e');
    }
  }

  /// Get advanced matching suggestions
  static Future<List<User>> getAdvancedMatches({String? accessToken, Map<String, dynamic>? filters}) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.matchingAdvanced));
      
      // Add filter parameters if provided
      if (filters != null && filters.isNotEmpty) {
        uri = uri.replace(queryParameters: filters.map((key, value) => MapEntry(key, value.toString())));
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
        return items.map((item) => User.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch advanced matches: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching advanced matches: $e');
    }
  }

  /// Get AI-powered suggestions
  static Future<List<User>> getAISuggestions({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.matchingAi)),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.map((item) => User.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch AI suggestions: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching AI suggestions: $e');
    }
  }

  /// Get location-based matches
  static Future<List<User>> getLocationBasedMatches({String? accessToken, double? latitude, double? longitude}) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.matchingLocation));
      
      // Add location parameters if provided
      if (latitude != null && longitude != null) {
        uri = uri.replace(queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        });
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
        return items.map((item) => User.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch location-based matches: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching location-based matches: $e');
    }
  }

  /// Get compatibility score with another user
  static Future<Map<String, dynamic>> getCompatibilityScore(String userId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.matchingCompatibility) + '?user_id=$userId'),
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
        throw ApiException('Failed to get compatibility score: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while getting compatibility score: $e');
    }
  }

  /// Debug matching algorithm (for development)
  static Future<Map<String, dynamic>> debugMatching({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.matchingDebug)),
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
        throw ApiException('Failed to debug matching: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while debugging matching: $e');
    }
  }

  /// Test matching algorithm
  static Future<Map<String, dynamic>> testMatching({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.matchingTest)),
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
        throw ApiException('Failed to test matching: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while testing matching: $e');
    }
  }
}
