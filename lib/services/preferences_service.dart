import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';
import '../utils/error_handler.dart';

class PreferencesService {
  /// Get age preferences
  static Future<UserPreferences> getAgePreferences({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.preferencesAge)),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserPreferences.fromJson(data['data'] ?? data);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Age preferences not found');
      } else {
        throw ApiException('Failed to fetch age preferences: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching age preferences: $e');
    }
  }

  /// Update age preferences
  static Future<UserPreferences> updateAgePreferences(int minAge, int maxAge, {String? accessToken}) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getUrl(ApiConfig.preferencesAge)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'min_age': minAge,
          'max_age': maxAge,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserPreferences.fromJson(data['data'] ?? data);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update age preferences: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating age preferences: $e');
    }
  }

  /// Delete age preferences (reset to default)
  static Future<bool> deleteAgePreferences({String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrl(ApiConfig.preferencesAge)),
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
        throw ApiException('Age preferences not found');
      } else {
        throw ApiException('Failed to delete age preferences: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while deleting age preferences: $e');
    }
  }
}
