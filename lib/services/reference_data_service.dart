import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/profile_completion_models.dart';

class ReferenceDataService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// Get countries
  static Future<List<Country>> getCountries() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/countries'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((json) => Country.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching countries: $e');
      return [];
    }
  }

  /// Get cities by country
  static Future<List<City>> getCitiesByCountry(int countryId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/cities/country/$countryId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((json) => City.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching cities: $e');
      return [];
    }
  }

  /// Get genders
  static Future<List<ReferenceDataItem>> getGenders() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/genders'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((json) => ReferenceDataItem.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching genders: $e');
      return [];
    }
  }

  /// Get other reference data (jobs, educations, etc.)
  static Future<List<ReferenceDataItem>> getReferenceData(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/$endpoint'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((json) => ReferenceDataItem.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching $endpoint: $e');
      return [];
    }
  }

  /// Get all reference data needed for profile completion
  static Future<Map<String, dynamic>> getAllReferenceData() async {
    try {
      final results = await Future.wait([
        getCountries(),
        getGenders(),
        getReferenceData('preferred-genders'),
        getReferenceData('interests'),
        getReferenceData('music-genres'),
        getReferenceData('languages'),
        getReferenceData('jobs'),
        getReferenceData('education'),
        getReferenceData('relation-goals'),
      ]);

      return {
        'countries': results[0] as List<Country>,
        'genders': results[1] as List<ReferenceDataItem>,
        'preferred_genders': results[2] as List<ReferenceDataItem>,
        'interests': results[3] as List<ReferenceDataItem>,
        'music_genres': results[4] as List<ReferenceDataItem>,
        'languages': results[5] as List<ReferenceDataItem>,
        'jobs': results[6] as List<ReferenceDataItem>,
        'education': results[7] as List<ReferenceDataItem>,
        'relation_goals': results[8] as List<ReferenceDataItem>,
      };
    } catch (e) {
      print('Error fetching all reference data: $e');
      return {};
    }
  }
}