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

  /// Get all countries
  static Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.countries)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch countries: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching countries: $e');
    }
  }

  /// Get all cities by country
  static Future<List<Map<String, dynamic>>> getCitiesByCountry(String countryCode) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.cities) + '/$countryCode'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Country not found');
      } else {
        throw ApiException('Failed to fetch cities: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching cities: $e');
    }
  }

  /// Get all age ranges
  static Future<List<Map<String, dynamic>>> getAgeRanges() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.ageRanges)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch age ranges: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching age ranges: $e');
    }
  }

  /// Get all height ranges
  static Future<List<Map<String, dynamic>>> getHeightRanges() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.heightRanges)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch height ranges: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching height ranges: $e');
    }
  }

  /// Get all body types
  static Future<List<Map<String, dynamic>>> getBodyTypes() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.bodyTypes)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch body types: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching body types: $e');
    }
  }

  /// Get all zodiac signs
  static Future<List<Map<String, dynamic>>> getZodiacSigns() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.zodiacSigns)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch zodiac signs: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching zodiac signs: $e');
    }
  }

  /// Get all drinking habits
  static Future<List<Map<String, dynamic>>> getDrinkingHabits() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.drinkingHabits)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch drinking habits: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching drinking habits: $e');
    }
  }

  /// Get all smoking habits
  static Future<List<Map<String, dynamic>>> getSmokingHabits() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.smokingHabits)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch smoking habits: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching smoking habits: $e');
    }
  }

  /// Get all exercise habits
  static Future<List<Map<String, dynamic>>> getExerciseHabits() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.exerciseHabits)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch exercise habits: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching exercise habits: $e');
    }
  }

  /// Get all pet preferences
  static Future<List<Map<String, dynamic>>> getPetPreferences() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.petPreferences)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch pet preferences: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching pet preferences: $e');
    }
  }

  /// Get all children preferences
  static Future<List<Map<String, dynamic>>> getChildrenPreferences() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.childrenPreferences)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch children preferences: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching children preferences: $e');
    }
  }

  /// Get all report categories
  static Future<List<Map<String, dynamic>>> getReportCategories() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.reportCategories)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch report categories: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching report categories: $e');
    }
  }

  /// Get all notification types
  static Future<List<Map<String, dynamic>>> getNotificationTypes() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.notificationTypes)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch notification types: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching notification types: $e');
    }
  }

  /// Get all privacy settings
  static Future<List<Map<String, dynamic>>> getPrivacySettings() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.privacySettings)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch privacy settings: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching privacy settings: $e');
    }
  }

  /// Get all app settings
  static Future<List<Map<String, dynamic>>> getAppSettings() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.appSettings)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch app settings: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching app settings: $e');
    }
  }

  /// Get all reference data at once
  static Future<Map<String, dynamic>> getAllReferenceData() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.referenceData)),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch all reference data: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching all reference data: $e');
    }
  }

  /// Search reference data
  static Future<List<Map<String, dynamic>>> searchReferenceData({
    required String query,
    String? category,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.referenceDataSearch));
      
      // Add query parameters
      final queryParams = <String, String>{
        'q': query,
      };
      if (category != null) queryParams['category'] = category;
      if (limit != null) queryParams['limit'] = limit.toString();
      
      uri = uri.replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid search parameters',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to search reference data: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while searching reference data: $e');
    }
  }
}
