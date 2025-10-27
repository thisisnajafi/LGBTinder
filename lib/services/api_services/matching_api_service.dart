import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/api_models/matching_models.dart';

/// Matching & Likes API Service
/// 
/// This service handles all matching and likes API calls including:
/// - Liking users
/// - Getting matches
/// - Match management
class MatchingApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  // ============================================================================
  // LIKES
  // ============================================================================

  /// Like another user
  /// 
  /// [request] - Like user request data
  /// [token] - Full access token for authentication
  /// Returns [LikeUserResponse] with like result
  static Future<LikeUserResponse> likeUser(LikeUserRequest request, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/likes/like'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return LikeUserResponse.fromJson(responseData);
      } else {
        // Handle error response
        return LikeUserResponse.fromJson(responseData);
      }
    } catch (e) {
      // Handle network or parsing errors
      return LikeUserResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Like user with error handling
  /// 
  /// [targetUserId] - ID of the user to like
  /// [token] - Full access token for authentication
  /// Returns [Map<String, dynamic>] with result and error information
  static Future<Map<String, dynamic>> likeUserWithErrorHandling(int targetUserId, String token) async {
    try {
      final request = LikeUserRequest(targetUserId: targetUserId);
      final response = await likeUser(request, token);

      if (response.status) {
        return {
          'success': true,
          'data': response.data,
          'error': null,
        };
      } else {
        return {
          'success': false,
          'data': null,
          'error': response.message,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Dislike/Pass on a user
  /// 
  /// [targetUserId] - ID of the user to dislike
  /// [token] - Full access token for authentication
  /// Returns [Map<String, dynamic>] with result
  static Future<Map<String, dynamic>> dislikeUser(int targetUserId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/matches/dislike'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'target_user_id': targetUserId,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'User disliked successfully',
          'error': null,
        };
      } else {
        return {
          'success': false,
          'message': null,
          'error': responseData['message'] ?? 'Failed to dislike user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': null,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Superlike a user
  /// 
  /// [targetUserId] - ID of the user to superlike
  /// [token] - Full access token for authentication
  /// Returns [Map<String, dynamic>] with result and match status
  static Future<Map<String, dynamic>> superlikeUser(int targetUserId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/matches/superlike'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'target_user_id': targetUserId,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        return {
          'success': true,
          'isMatch': responseData['data']?['is_match'] ?? false,
          'message': responseData['message'] ?? 'User superliked successfully',
          'data': responseData['data'],
          'error': null,
        };
      } else {
        return {
          'success': false,
          'isMatch': false,
          'message': null,
          'data': null,
          'error': responseData['message'] ?? 'Failed to superlike user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'isMatch': false,
        'message': null,
        'data': null,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // ============================================================================
  // MATCHES
  // ============================================================================

  /// Get user's matches
  /// 
  /// [token] - Full access token for authentication
  /// Returns [GetMatchesResponse] with list of matches
  static Future<GetMatchesResponse> getMatches(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/likes/matches'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return GetMatchesResponse.fromJson(responseData);
      } else {
        // Handle error response
        return GetMatchesResponse(
          status: false,
          data: [],
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      return GetMatchesResponse(
        status: false,
        data: [],
      );
    }
  }

  /// Get matches with error handling
  /// 
  /// [token] - Full access token for authentication
  /// Returns [Map<String, dynamic>] with result and error information
  static Future<Map<String, dynamic>> getMatchesWithErrorHandling(String token) async {
    try {
      final response = await getMatches(token);

      if (response.status) {
        return {
          'success': true,
          'data': response.data,
          'error': null,
        };
      } else {
        return {
          'success': false,
          'data': null,
          'error': 'Failed to fetch matches',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // ============================================================================
  // MATCHING UTILITIES
  // ============================================================================

  /// Check if user can like another user
  /// 
  /// [currentUserId] - ID of the current user
  /// [targetUserId] - ID of the user to like
  /// Returns [bool] indicating if user can like
  static bool canLikeUser(int currentUserId, int targetUserId) {
    return currentUserId != targetUserId;
  }

  /// Check if like resulted in a match
  /// 
  /// [likeData] - Like data to check
  /// Returns [bool] indicating if it's a match
  static bool isMatch(LikeData likeData) {
    return MatchingHelper.isMatch(likeData);
  }

  /// Check if like is pending
  /// 
  /// [likeData] - Like data to check
  /// Returns [bool] indicating if like is pending
  static bool isLikePending(LikeData likeData) {
    return MatchingHelper.isLikePending(likeData);
  }

  /// Get match count from matches
  /// 
  /// [matches] - List of matches
  /// Returns [int] with match count
  static int getMatchCount(List<MatchData> matches) {
    return matches.length;
  }

  /// Get unread match count
  /// 
  /// [matches] - List of matches
  /// Returns [int] with unread match count
  static int getUnreadMatchCount(List<MatchData> matches) {
    return matches.where((match) => MatchingHelper.hasUnreadMessages(match)).length;
  }

  /// Get recent matches
  /// 
  /// [matches] - List of matches
  /// [limit] - Maximum number of recent matches to return
  /// Returns [List<MatchData>] with recent matches
  static List<MatchData> getRecentMatches(List<MatchData> matches, {int limit = 10}) {
    final sortedMatches = List<MatchData>.from(matches);
    sortedMatches.sort((a, b) => DateTime.parse(b.matchedAt).compareTo(DateTime.parse(a.matchedAt)));
    return sortedMatches.take(limit).toList();
  }

  /// Get matches with unread messages
  /// 
  /// [matches] - List of matches
  /// Returns [List<MatchData>] with matches that have unread messages
  static List<MatchData> getMatchesWithUnreadMessages(List<MatchData> matches) {
    return matches.where((match) => MatchingHelper.hasUnreadMessages(match)).toList();
  }

  /// Get matches by user ID
  /// 
  /// [matches] - List of matches
  /// [userId] - User ID to search for
  /// Returns [MatchData?] with match data if found
  static MatchData? getMatchByUserId(List<MatchData> matches, int userId) {
    try {
      return matches.firstWhere((match) => match.user.id == userId);
    } catch (e) {
      return null;
    }
  }

  /// Sort matches by last message time
  /// 
  /// [matches] - List of matches
  /// Returns [List<MatchData>] with sorted matches
  static List<MatchData> sortMatchesByLastMessage(List<MatchData> matches) {
    final sortedMatches = List<MatchData>.from(matches);
    sortedMatches.sort((a, b) {
      if (a.lastMessage == null && b.lastMessage == null) {
        return DateTime.parse(b.matchedAt).compareTo(DateTime.parse(a.matchedAt));
      }
      if (a.lastMessage == null) return 1;
      if (b.lastMessage == null) return -1;
      return DateTime.parse(b.lastMessage!.sentAt).compareTo(DateTime.parse(a.lastMessage!.sentAt));
    });
    return sortedMatches;
  }

  /// Sort matches by match time
  /// 
  /// [matches] - List of matches
  /// Returns [List<MatchData>] with sorted matches
  static List<MatchData> sortMatchesByMatchTime(List<MatchData> matches) {
    final sortedMatches = List<MatchData>.from(matches);
    sortedMatches.sort((a, b) => DateTime.parse(b.matchedAt).compareTo(DateTime.parse(a.matchedAt)));
    return sortedMatches;
  }

  // ============================================================================
  // PREMIUM FEATURES
  // ============================================================================

  /// Undo last swipe (Premium feature)
  /// 
  /// [token] - Full access token for authentication
  /// Returns [Map<String, dynamic>] with result
  static Future<Map<String, dynamic>> undoLastSwipe(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/matches/undo'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Swipe undone successfully',
          'user': responseData['data'],
          'error': null,
        };
      } else {
        return {
          'success': false,
          'message': null,
          'user': null,
          'error': responseData['message'] ?? 'Failed to undo swipe',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': null,
        'user': null,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Boost profile (Premium feature)
  /// 
  /// [token] - Full access token for authentication
  /// Returns [Map<String, dynamic>] with result
  static Future<Map<String, dynamic>> boostProfile(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/profile/boost'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Profile boosted successfully',
          'boostEndTime': responseData['data']?['boost_end_time'],
          'error': null,
        };
      } else {
        return {
          'success': false,
          'message': null,
          'boostEndTime': null,
          'error': responseData['message'] ?? 'Failed to boost profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': null,
        'boostEndTime': null,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Check if response indicates success
  static bool isSuccessResponse(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  /// Check if response indicates client error
  static bool isClientErrorResponse(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }

  /// Check if response indicates server error
  static bool isServerErrorResponse(int statusCode) {
    return statusCode >= 500 && statusCode < 600;
  }

  /// Get error message from response
  static String getErrorMessage(Map<String, dynamic> responseData) {
    if (responseData.containsKey('message')) {
      return responseData['message'] as String;
    }
    return 'Unknown error occurred';
  }

  /// Check if user is authenticated
  static bool isAuthenticated(String? token) {
    return token != null && token.isNotEmpty;
  }

  /// Validate token format
  static bool isValidTokenFormat(String token) {
    // Basic token validation - should be non-empty and contain typical JWT structure
    return token.isNotEmpty && token.contains('.');
  }

  /// Validate user ID
  static bool isValidUserId(int userId) {
    return userId > 0;
  }

  /// Validate target user ID
  static bool isValidTargetUserId(int targetUserId) {
    return targetUserId > 0;
  }
}
