import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/reference_data.dart';
import '../utils/error_handler.dart';

class ReferenceDataService {
  /// Get all education options
  static Future<List<Education>> getEducationOptions() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.education)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.map((item) => Education.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch education options: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching education options: $e');
    }
  }

  /// Get all gender options
  static Future<List<Gender>> getGenderOptions() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.genders)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.map((item) => Gender.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch gender options: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching gender options: $e');
    }
  }

  /// Get all interest options
  static Future<List<Interest>> getInterestOptions() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.interests)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.map((item) => Interest.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch interest options: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching interest options: $e');
    }
  }

  /// Get all job options
  static Future<List<Job>> getJobOptions() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.jobs)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.map((item) => Job.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch job options: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching job options: $e');
    }
  }

  /// Get all language options
  static Future<List<Language>> getLanguageOptions() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.languages)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.map((item) => Language.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch language options: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching language options: $e');
    }
  }

  /// Get all music genre options
  static Future<List<MusicGenre>> getMusicGenreOptions() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.musicGenres)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.map((item) => MusicGenre.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch music genre options: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching music genre options: $e');
    }
  }

  /// Get all preferred gender options
  static Future<List<PreferredGender>> getPreferredGenderOptions() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.preferredGenders)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.map((item) => PreferredGender.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch preferred gender options: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching preferred gender options: $e');
    }
  }

  /// Get all relationship goal options
  static Future<List<RelationGoal>> getRelationGoalOptions() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.relationGoals)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.map((item) => RelationGoal.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch relationship goal options: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching relationship goal options: $e');
    }
  }
}
