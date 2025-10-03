import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/api_models/reference_data_models.dart';

/// Reference Data API Service
/// 
/// This service handles all reference data API calls including:
/// - Countries
/// - Cities by country
/// - Genders
/// - Jobs
/// - Education levels
/// - Interests
/// - Languages
/// - Music genres
/// - Relationship goals
/// - Preferred genders
class ReferenceDataApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  // ============================================================================
  // COUNTRIES
  // ============================================================================

  /// Get all available countries
  /// 
  /// Returns [CountriesResponse] with list of countries
  static Future<CountriesResponse> getCountries() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/countries'),
        headers: {
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return CountriesResponse.fromJson(responseData);
      } else {
        // Handle error response
        return CountriesResponse(
          status: 'error',
          data: [],
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      return CountriesResponse(
        status: 'error',
        data: [],
      );
    }
  }

  // ============================================================================
  // CITIES
  // ============================================================================

  /// Get all cities for a specific country
  /// 
  /// [countryId] - ID of the country to get cities for
  /// Returns [CitiesResponse] with list of cities
  static Future<CitiesResponse> getCitiesByCountry(int countryId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cities/country/$countryId'),
        headers: {
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return CitiesResponse.fromJson(responseData);
      } else {
        // Handle error response
        return CitiesResponse(
          status: 'error',
          data: [],
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      return CitiesResponse(
        status: 'error',
        data: [],
      );
    }
  }

  // ============================================================================
  // GENDERS
  // ============================================================================

  /// Get all available gender options
  /// 
  /// Returns [GendersResponse] with list of genders
  static Future<GendersResponse> getGenders() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/genders'),
        headers: {
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return GendersResponse.fromJson(responseData);
      } else {
        // Handle error response
        return GendersResponse(
          status: 'error',
          data: [],
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      return GendersResponse(
        status: 'error',
        data: [],
      );
    }
  }

  // ============================================================================
  // JOBS
  // ============================================================================

  /// Get all available job/profession options
  /// 
  /// Returns [JobsResponse] with list of jobs
  static Future<JobsResponse> getJobs() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/jobs'),
        headers: {
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return JobsResponse.fromJson(responseData);
      } else {
        // Handle error response
        return JobsResponse(
          status: 'error',
          data: [],
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      return JobsResponse(
        status: 'error',
        data: [],
      );
    }
  }

  // ============================================================================
  // EDUCATION
  // ============================================================================

  /// Get all available education level options
  /// 
  /// Returns [EducationResponse] with list of education levels
  static Future<EducationResponse> getEducation() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/education'),
        headers: {
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return EducationResponse.fromJson(responseData);
      } else {
        // Handle error response
        return EducationResponse(
          status: 'error',
          data: [],
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      return EducationResponse(
        status: 'error',
        data: [],
      );
    }
  }

  // ============================================================================
  // INTERESTS
  // ============================================================================

  /// Get all available interest options
  /// 
  /// Returns [InterestsResponse] with list of interests
  static Future<InterestsResponse> getInterests() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/interests'),
        headers: {
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return InterestsResponse.fromJson(responseData);
      } else {
        // Handle error response
        return InterestsResponse(
          status: 'error',
          data: [],
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      return InterestsResponse(
        status: 'error',
        data: [],
      );
    }
  }

  // ============================================================================
  // LANGUAGES
  // ============================================================================

  /// Get all available language options
  /// 
  /// Returns [LanguagesResponse] with list of languages
  static Future<LanguagesResponse> getLanguages() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/languages'),
        headers: {
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return LanguagesResponse.fromJson(responseData);
      } else {
        // Handle error response
        return LanguagesResponse(
          status: 'error',
          data: [],
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      return LanguagesResponse(
        status: 'error',
        data: [],
      );
    }
  }

  // ============================================================================
  // MUSIC GENRES
  // ============================================================================

  /// Get all available music genre options
  /// 
  /// Returns [MusicGenresResponse] with list of music genres
  static Future<MusicGenresResponse> getMusicGenres() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/music-genres'),
        headers: {
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return MusicGenresResponse.fromJson(responseData);
      } else {
        // Handle error response
        return MusicGenresResponse(
          status: 'error',
          data: [],
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      return MusicGenresResponse(
        status: 'error',
        data: [],
      );
    }
  }

  // ============================================================================
  // RELATIONSHIP GOALS
  // ============================================================================

  /// Get all available relationship goal options
  /// 
  /// Returns [RelationGoalsResponse] with list of relationship goals
  static Future<RelationGoalsResponse> getRelationGoals() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/relation-goals'),
        headers: {
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return RelationGoalsResponse.fromJson(responseData);
      } else {
        // Handle error response
        return RelationGoalsResponse(
          status: 'error',
          data: [],
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      return RelationGoalsResponse(
        status: 'error',
        data: [],
      );
    }
  }

  // ============================================================================
  // PREFERRED GENDERS
  // ============================================================================

  /// Get all available preferred gender options for matching
  /// 
  /// Returns [PreferredGendersResponse] with list of preferred genders
  static Future<PreferredGendersResponse> getPreferredGenders() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/preferred-genders'),
        headers: {
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return PreferredGendersResponse.fromJson(responseData);
      } else {
        // Handle error response
        return PreferredGendersResponse(
          status: 'error',
          data: [],
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      return PreferredGendersResponse(
        status: 'error',
        data: [],
      );
    }
  }

  // ============================================================================
  // BATCH OPERATIONS
  // ============================================================================

  /// Get all reference data in a single batch operation
  /// 
  /// Returns [Map<String, dynamic>] with all reference data
  static Future<Map<String, dynamic>> getAllReferenceData() async {
    try {
      // Execute all requests concurrently
      final results = await Future.wait([
        getCountries(),
        getGenders(),
        getJobs(),
        getEducation(),
        getInterests(),
        getLanguages(),
        getMusicGenres(),
        getRelationGoals(),
        getPreferredGenders(),
      ]);

      return {
        'countries': results[0] as CountriesResponse,
        'genders': results[1] as GendersResponse,
        'jobs': results[2] as JobsResponse,
        'education': results[3] as EducationResponse,
        'interests': results[4] as InterestsResponse,
        'languages': results[5] as LanguagesResponse,
        'music_genres': results[6] as MusicGenresResponse,
        'relation_goals': results[7] as RelationGoalsResponse,
        'preferred_genders': results[8] as PreferredGendersResponse,
      };
    } catch (e) {
      // Handle errors
      return {
        'countries': CountriesResponse(status: 'error', data: []),
        'genders': GendersResponse(status: 'error', data: []),
        'jobs': JobsResponse(status: 'error', data: []),
        'education': EducationResponse(status: 'error', data: []),
        'interests': InterestsResponse(status: 'error', data: []),
        'languages': LanguagesResponse(status: 'error', data: []),
        'music_genres': MusicGenresResponse(status: 'error', data: []),
        'relation_goals': RelationGoalsResponse(status: 'error', data: []),
        'preferred_genders': PreferredGendersResponse(status: 'error', data: []),
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
}
