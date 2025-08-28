import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';
import '../utils/error_handler.dart';

class BlockingService {
  /// Block a user
  static Future<bool> blockUser(String userId, {String? accessToken, String? reason}) async {
    try {
      final requestBody = {'user_id': userId};
      if (reason != null) requestBody['reason'] = reason;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.blockUser)),
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
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 404) {
        throw ApiException('User not found');
      } else {
        throw ApiException('Failed to block user: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while blocking user: $e');
    }
  }

  /// Unblock a user
  static Future<bool> unblockUser(String userId, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrl(ApiConfig.blockUser) + '?user_id=$userId'),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('User not found or not blocked');
      } else {
        throw ApiException('Failed to unblock user: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while unblocking user: $e');
    }
  }

  /// Get list of blocked users
  static Future<List<User>> getBlockedUsers({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.blockList)),
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
        throw ApiException('Failed to fetch blocked users: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching blocked users: $e');
    }
  }

  /// Check if user is blocked
  static Future<bool> isUserBlocked(String userId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.blockCheck) + '?user_id=$userId'),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_blocked'] as bool? ?? false;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('User not found');
      } else {
        throw ApiException('Failed to check if user is blocked: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while checking if user is blocked: $e');
    }
  }
}

class MutingService {
  /// Mute a user
  static Future<bool> muteUser(String userId, {String? accessToken, Duration? duration}) async {
    try {
      final requestBody = {'user_id': userId};
      if (duration != null) {
        requestBody['duration_minutes'] = duration.inMinutes;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.mutesMute)),
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
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 404) {
        throw ApiException('User not found');
      } else {
        throw ApiException('Failed to mute user: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while muting user: $e');
    }
  }

  /// Unmute a user
  static Future<bool> unmuteUser(String userId, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrl(ApiConfig.mutesUnmute) + '?user_id=$userId'),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('User not found or not muted');
      } else {
        throw ApiException('Failed to unmute user: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while unmuting user: $e');
    }
  }

  /// Get list of muted users
  static Future<List<Map<String, dynamic>>> getMutedUsers({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.mutesList)),
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
        throw ApiException('Failed to fetch muted users: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching muted users: $e');
    }
  }

  /// Update mute settings
  static Future<Map<String, dynamic>> updateMuteSettings(Map<String, dynamic> settings, {String? accessToken}) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getUrl(ApiConfig.mutesSettings)),
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
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid settings',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update mute settings: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating mute settings: $e');
    }
  }

  /// Check if user is muted
  static Future<bool> isUserMuted(String userId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.mutesCheck) + '?user_id=$userId'),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_muted'] as bool? ?? false;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('User not found');
      } else {
        throw ApiException('Failed to check if user is muted: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while checking if user is muted: $e');
    }
  }
}
