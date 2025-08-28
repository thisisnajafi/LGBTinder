import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';
import '../utils/error_handler.dart';

class FavoritesService {
  /// Add user to favorites
  static Future<bool> addToFavorites(String userId, {String? accessToken, String? note}) async {
    try {
      final requestBody = {'user_id': userId};
      if (note != null && note.isNotEmpty) {
        requestBody['note'] = note;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.favoritesAdd)),
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
      } else if (response.statusCode == 409) {
        throw ApiException('User is already in favorites');
      } else {
        throw ApiException('Failed to add to favorites: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while adding to favorites: $e');
    }
  }

  /// Remove user from favorites
  static Future<bool> removeFromFavorites(String userId, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrl(ApiConfig.favoritesRemove) + '?user_id=$userId'),
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
        throw ApiException('User not found in favorites');
      } else {
        throw ApiException('Failed to remove from favorites: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while removing from favorites: $e');
    }
  }

  /// Get favorites list
  static Future<List<Map<String, dynamic>>> getFavoritesList({
    String? accessToken,
    int? page,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.favoritesList));
      
      // Add query parameters
      final queryParams = <String, String>{};
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
        throw ApiException('Failed to fetch favorites list: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching favorites list: $e');
    }
  }

  /// Check if user is in favorites
  static Future<bool> isFavorited(String userId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.favoritesCheck) + '?user_id=$userId'),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_favorited'] as bool? ?? false;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('User not found');
      } else {
        throw ApiException('Failed to check favorite status: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while checking favorite status: $e');
    }
  }

  /// Update favorite note
  static Future<Map<String, dynamic>> updateFavoriteNote(String userId, String note, {String? accessToken}) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getUrl(ApiConfig.favoritesNote)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'user_id': userId,
          'note': note,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('User not found in favorites');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update favorite note: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating favorite note: $e');
    }
  }

  /// Get favorite details (including note)
  static Future<Map<String, dynamic>?> getFavoriteDetails(String userId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.favoritesCheck) + '/details?user_id=$userId'),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        return null; // Not in favorites
      } else {
        throw ApiException('Failed to fetch favorite details: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching favorite details: $e');
    }
  }

  /// Get favorites count
  static Future<int> getFavoritesCount({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.favoritesList) + '/count'),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] as int? ?? 0;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch favorites count: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching favorites count: $e');
    }
  }

  /// Toggle favorite status (add if not favorited, remove if favorited)
  static Future<bool> toggleFavorite(String userId, {String? accessToken, String? note}) async {
    try {
      final isFav = await isFavorited(userId, accessToken: accessToken);
      
      if (isFav) {
        await removeFromFavorites(userId, accessToken: accessToken);
        return false; // Removed from favorites
      } else {
        await addToFavorites(userId, accessToken: accessToken, note: note);
        return true; // Added to favorites
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Bulk add to favorites
  static Future<Map<String, dynamic>> bulkAddToFavorites(List<String> userIds, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.favoritesAdd) + '/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'user_ids': userIds,
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
      } else {
        throw ApiException('Failed to bulk add to favorites: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while bulk adding to favorites: $e');
    }
  }

  /// Bulk remove from favorites
  static Future<Map<String, dynamic>> bulkRemoveFromFavorites(List<String> userIds, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrl(ApiConfig.favoritesRemove) + '/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'user_ids': userIds,
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
      } else {
        throw ApiException('Failed to bulk remove from favorites: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while bulk removing from favorites: $e');
    }
  }
}
