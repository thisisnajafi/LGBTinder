import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/profile_completion_models.dart';

class ProfileCompletionService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// Fetch all reference data needed for profile completion
  static Future<Map<String, dynamic>> fetchReferenceData() async {
    final endpoints = [
      'genders',
      'preferred-genders',
      'interests',
      'music-genres',
      'languages',
      'jobs',
      'education',
      'relation-goals'
    ];

    Map<String, dynamic> referenceData = {};

    // Fetch countries
    try {
      final countriesResponse = await http.get(
        Uri.parse('$_baseUrl/api/countries'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (countriesResponse.statusCode == 200) {
        final data = json.decode(countriesResponse.body);
        final countries = (data['data'] as List)
            .map((item) => Country.fromJson(item as Map<String, dynamic>))
            .toList();
        referenceData['countries'] = countries;
      } else {
        print('Failed to fetch countries: ${countriesResponse.statusCode}');
      }
    } catch (error) {
      print('Error fetching countries: $error');
    }

    // Fetch other reference data
    for (final endpoint in endpoints) {
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
          final referenceResponse = ReferenceDataResponse.fromJson(data);
          referenceData[endpoint.replaceAll('-', '_')] = referenceResponse.data;
        } else {
          print('Failed to fetch $endpoint: ${response.statusCode}');
        }
      } catch (error) {
        print('Error fetching $endpoint: $error');
      }
    }

    return referenceData;
  }

  /// Fetch cities by country ID
  static Future<List<City>> fetchCitiesByCountry(int countryId) async {
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
        return (data['data'] as List)
            .map((item) => City.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch cities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching cities: $e');
    }
  }

  /// Complete user profile with all required information
  static Future<ProfileCompletionResponse> completeProfile(
    ProfileCompletionRequest request,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/complete-registration'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: json.encode(request.toJson()),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ProfileCompletionResponse.fromJson(responseData);
      } else {
        // Handle error responses
        if (responseData is Map<String, dynamic>) {
          final errorMessage = responseData['message'] ?? 'Profile completion failed';
          final errors = responseData['errors'] as Map<String, dynamic>?;
          
          if (errors != null) {
            final errorDetails = errors.entries
                .map((e) => '${e.key}: ${(e.value as List).join(', ')}')
                .join('\n');
            throw Exception('$errorMessage\n$errorDetails');
          } else {
            throw Exception(errorMessage);
          }
        } else {
          throw Exception('Profile completion failed');
        }
      }
    } catch (e) {
      throw Exception('Network error during profile completion: $e');
    }
  }

  /// Get specific reference data by endpoint
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
        final referenceResponse = ReferenceDataResponse.fromJson(data);
        return referenceResponse.data;
      } else {
        throw Exception('Failed to fetch $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching $endpoint: $e');
    }
  }
}
