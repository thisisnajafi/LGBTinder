import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/token_management_service.dart';

class ReferenceDataApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// Get list of jobs
  static Future<List<Map<String, dynamic>>> getJobs() async {
    try {
      final token = await TokenManagementService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.jobs}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading jobs: $e');
      return [];
    }
  }

  /// Get list of education levels
  static Future<List<Map<String, dynamic>>> getEducation() async {
    try {
      final token = await TokenManagementService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.education}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to load education: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading education: $e');
      return [];
    }
  }

  /// Get list of genders
  static Future<List<Map<String, dynamic>>> getGenders() async {
    try {
      final token = await TokenManagementService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.genders}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to load genders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading genders: $e');
      return [];
    }
  }

  /// Get list of preferred genders
  static Future<List<Map<String, dynamic>>> getPreferredGenders() async {
    try {
      final token = await TokenManagementService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.preferredGenders}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to load preferred genders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading preferred genders: $e');
      return [];
    }
  }

  /// Get list of interests
  static Future<List<Map<String, dynamic>>> getInterests() async {
    try {
      final token = await TokenManagementService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.interests}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to load interests: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading interests: $e');
      return [];
    }
  }

  /// Get list of languages
  static Future<List<Map<String, dynamic>>> getLanguages() async {
    try {
      final token = await TokenManagementService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.languages}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to load languages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading languages: $e');
      return [];
    }
  }

  /// Get list of relation goals
  static Future<List<Map<String, dynamic>>> getRelationGoals() async {
    try {
      final token = await TokenManagementService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.relationGoals}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to load relation goals: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading relation goals: $e');
      return [];
    }
  }

  /// Get list of music genres
  static Future<List<Map<String, dynamic>>> getMusicGenres() async {
    try {
      final token = await TokenManagementService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.musicGenres}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to load music genres: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading music genres: $e');
      return [];
    }
  }

  /// Get list of countries
  static Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      final token = await TokenManagementService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.countries}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading countries: $e');
      return [];
    }
  }

  /// Get country by ID
  static Future<Map<String, dynamic>?> getCountryById(String id) async {
    try {
      final token = await TokenManagementService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.countries}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load country: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading country: $e');
      return null;
    }
  }

  /// Get list of all cities
  static Future<List<Map<String, dynamic>>> getCities() async {
    try {
      final token = await TokenManagementService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.cities}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading cities: $e');
      return [];
    }
  }

  /// Get cities by country ID
  static Future<List<Map<String, dynamic>>> getCitiesByCountry(String countryId) async {
    try {
      final token = await TokenManagementService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.cities}/country/$countryId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading cities: $e');
      return [];
    }
  }

  /// Get city by ID
  static Future<Map<String, dynamic>?> getCityById(String id) async {
    try {
      final token = await TokenManagementService.getAccessToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.cities}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load city: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading city: $e');
      return null;
    }
  }

  /// Load all reference data at once
  static Future<Map<String, dynamic>> loadAllReferenceData() async {
    try {
      final results = await Future.wait([
        getGenders(),
        getPreferredGenders(),
        getJobs(),
        getEducation(),
        getRelationGoals(),
        getInterests(),
        getLanguages(),
        getMusicGenres(),
        getCountries(),
      ]);

      return {
        'genders': results[0],
        'preferredGenders': results[1],
        'jobs': results[2],
        'education': results[3],
        'relationGoals': results[4],
        'interests': results[5],
        'languages': results[6],
        'musicGenres': results[7],
        'countries': results[8],
      };
    } catch (e) {
      print('Error loading all reference data: $e');
      return {};
    }
  }
}
