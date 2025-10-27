import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/user.dart';

/// Discovery API Service
/// 
/// This service handles all discovery-related API calls including:
/// - Fetching potential matches with filters
/// - Searching users
/// - Profile recommendations
class DiscoveryApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  // ============================================================================
  // DISCOVERY PROFILES
  // ============================================================================

  /// Fetch discovery profiles with filters and pagination
  /// 
  /// [token] - Full access token for authentication
  /// [page] - Page number for pagination (default: 1)
  /// [limit] - Number of profiles per page (default: 20)
  /// [filters] - Optional filters (age, distance, gender, etc.)
  /// Returns [Map<String, dynamic>] with profiles and pagination info
  static Future<Map<String, dynamic>> getDiscoveryProfiles({
    required String token,
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // Build query parameters
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Add filters if provided
      if (filters != null) {
        if (filters.containsKey('minAge')) {
          queryParams['min_age'] = filters['minAge'].toString();
        }
        if (filters.containsKey('maxAge')) {
          queryParams['max_age'] = filters['maxAge'].toString();
        }
        if (filters.containsKey('distance')) {
          queryParams['distance'] = filters['distance'].toString();
        }
        if (filters.containsKey('gender')) {
          queryParams['gender'] = filters['gender'].toString();
        }
        if (filters.containsKey('interests')) {
          queryParams['interests'] = (filters['interests'] as List).join(',');
        }
      }

      final uri = Uri.parse('$_baseUrl/discovery/profiles').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        final List<dynamic> profilesData = responseData['data']['profiles'] ?? [];
        final List<User> profiles = profilesData
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'profiles': profiles,
          'pagination': responseData['data']['pagination'] ?? {},
          'total': responseData['data']['total'] ?? 0,
          'error': null,
        };
      } else {
        return {
          'success': false,
          'profiles': <User>[],
          'pagination': {},
          'total': 0,
          'error': responseData['message'] ?? 'Failed to fetch profiles',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'profiles': <User>[],
        'pagination': {},
        'total': 0,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Search users by name or username
  /// 
  /// [token] - Full access token for authentication
  /// [query] - Search query string
  /// [page] - Page number for pagination (default: 1)
  /// [limit] - Number of results per page (default: 20)
  /// Returns [Map<String, dynamic>] with search results
  static Future<Map<String, dynamic>> searchUsers({
    required String token,
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/discovery/search').replace(
        queryParameters: {
          'query': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        final List<dynamic> resultsData = responseData['data']['results'] ?? [];
        final List<User> results = resultsData
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'results': results,
          'total': responseData['data']['total'] ?? 0,
          'error': null,
        };
      } else {
        return {
          'success': false,
          'results': <User>[],
          'total': 0,
          'error': responseData['message'] ?? 'Search failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'results': <User>[],
        'total': 0,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Get who liked you (Premium feature)
  /// 
  /// [token] - Full access token for authentication
  /// Returns [Map<String, dynamic>] with users who liked you
  static Future<Map<String, dynamic>> getLikesReceived({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/matches/likes-received'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        final List<dynamic> usersData = responseData['data'] ?? [];
        final List<User> users = usersData
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'users': users,
          'error': null,
        };
      } else {
        return {
          'success': false,
          'users': <User>[],
          'error': responseData['message'] ?? 'Failed to fetch likes',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'users': <User>[],
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Validate filters
  static bool isValidFilters(Map<String, dynamic>? filters) {
    if (filters == null) return true;
    
    // Validate age range
    if (filters.containsKey('minAge') && filters.containsKey('maxAge')) {
      final minAge = filters['minAge'] as int?;
      final maxAge = filters['maxAge'] as int?;
      if (minAge != null && maxAge != null && minAge > maxAge) {
        return false;
      }
    }
    
    return true;
  }

  /// Check if response indicates success
  static bool isSuccessResponse(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }
}

