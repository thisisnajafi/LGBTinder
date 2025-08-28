import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';
import '../utils/error_handler.dart';

class LikesService {
  /// Like a user profile
  static Future<Map<String, dynamic>> likeUser(String userId, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.likesLike)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'user_id': userId,
        }),
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
      } else if (response.statusCode == 404) {
        throw ApiException('User not found');
      } else {
        throw ApiException('Failed to like user: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while liking user: $e');
    }
  }

  /// Dislike a user profile
  static Future<Map<String, dynamic>> dislikeUser(String userId, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.likesDislike)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'user_id': userId,
        }),
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
      } else if (response.statusCode == 404) {
        throw ApiException('User not found');
      } else {
        throw ApiException('Failed to dislike user: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while disliking user: $e');
    }
  }

  /// Superlike a user profile
  static Future<Map<String, dynamic>> superlikeUser(String userId, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.likesSuperlike)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'user_id': userId,
        }),
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
      } else if (response.statusCode == 404) {
        throw ApiException('User not found');
      } else if (response.statusCode == 403) {
        throw ApiException('Insufficient superlike credits');
      } else {
        throw ApiException('Failed to superlike user: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while superliking user: $e');
    }
  }

  /// Respond to a like (accept or reject)
  static Future<Map<String, dynamic>> respondToLike(String likeId, bool accept, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.likesRespond)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'like_id': likeId,
          'action': accept ? 'accept' : 'reject',
        }),
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
      } else if (response.statusCode == 404) {
        throw ApiException('Like not found');
      } else {
        throw ApiException('Failed to respond to like: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while responding to like: $e');
    }
  }

  /// Get user's matches
  static Future<List<User>> getMatches({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.likesMatches)),
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

  /// Get pending likes (users who liked you)
  static Future<List<Map<String, dynamic>>> getPendingLikes({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.likesPending)),
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
        throw ApiException('Failed to fetch pending likes: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching pending likes: $e');
    }
  }

  /// Get superlike history
  static Future<List<Map<String, dynamic>>> getSuperlikeHistory({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.likesSuperlieHistory)),
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
        throw ApiException('Failed to fetch superlike history: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching superlike history: $e');
    }
  }

  /// Check if user has available superlikes
  static Future<Map<String, dynamic>> checkSuperlikeAvailability({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.likesSuperlike) + '/availability'),
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
        throw ApiException('Failed to check superlike availability: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while checking superlike availability: $e');
    }
  }

  /// Undo last action (if available)
  static Future<Map<String, dynamic>> undoLastAction({String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.likesLike) + '/undo'),
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
      } else if (response.statusCode == 404) {
        throw ApiException('No action to undo');
      } else if (response.statusCode == 403) {
        throw ApiException('Undo not available with current plan');
      } else {
        throw ApiException('Failed to undo action: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while undoing action: $e');
    }
  }
}
