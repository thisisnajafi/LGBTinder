import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class ProfileWizardService {
  /// Get current wizard step
  static Future<Map<String, dynamic>> getCurrentStep({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.profileWizardCurrentStep)),
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
        throw ApiException('Failed to fetch current wizard step: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching current wizard step: $e');
    }
  }

  /// Get step options for a specific wizard step
  static Future<Map<String, dynamic>> getStepOptions(String step, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.profileWizardStepOptions, {'step': step})),
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
      } else if (response.statusCode == 404) {
        throw ApiException('Wizard step not found');
      } else {
        throw ApiException('Failed to fetch step options: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching step options: $e');
    }
  }

  /// Save wizard step data
  static Future<Map<String, dynamic>> saveStep(String step, Map<String, dynamic> stepData, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.profileWizardSaveStep, {'step': step})),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(stepData),
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
        throw ApiException('Wizard step not found');
      } else {
        throw ApiException('Failed to save wizard step: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while saving wizard step: $e');
    }
  }

  /// Get wizard progress/completion status
  static Future<Map<String, dynamic>> getWizardProgress({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.profileWizardCurrentStep) + '/progress'),
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
        throw ApiException('Failed to fetch wizard progress: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching wizard progress: $e');
    }
  }

  /// Skip wizard step
  static Future<Map<String, dynamic>> skipStep(String step, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.profileWizardSaveStep, {'step': step}) + '/skip'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'action': 'skip'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Wizard step not found');
      } else {
        throw ApiException('Failed to skip wizard step: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while skipping wizard step: $e');
    }
  }

  /// Complete wizard
  static Future<bool> completeWizard({String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.profileWizardCurrentStep) + '/complete'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'action': 'complete'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Wizard not ready to complete',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to complete wizard: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while completing wizard: $e');
    }
  }
}
