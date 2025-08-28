import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';
import '../utils/error_handler.dart';

class VerificationService {
  /// Get verification status
  static Future<UserVerification> getVerificationStatus({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.verificationStatus)),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserVerification.fromJson(data['data'] ?? data);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch verification status: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching verification status: $e');
    }
  }

  /// Get verification guidelines
  static Future<Map<String, dynamic>> getVerificationGuidelines({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.verificationGuidelines)),
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
        throw ApiException('Failed to fetch verification guidelines: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching verification guidelines: $e');
    }
  }

  /// Get verification history
  static Future<List<Map<String, dynamic>>> getVerificationHistory({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.verificationHistory)),
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
        throw ApiException('Failed to fetch verification history: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching verification history: $e');
    }
  }

  /// Submit photo verification
  static Future<Map<String, dynamic>> submitPhotoVerification(File imageFile, {String? accessToken}) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.getUrl(ApiConfig.verificationSubmitPhoto)),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      });

      request.files.add(await http.MultipartFile.fromPath('photo', imageFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(responseBody);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to submit photo verification: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while submitting photo verification: $e');
    }
  }

  /// Submit ID verification
  static Future<Map<String, dynamic>> submitIdVerification(File imageFile, {String? accessToken}) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.getUrl(ApiConfig.verificationSubmitId)),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      });

      request.files.add(await http.MultipartFile.fromPath('id_document', imageFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(responseBody);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to submit ID verification: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while submitting ID verification: $e');
    }
  }

  /// Submit video verification
  static Future<Map<String, dynamic>> submitVideoVerification(File videoFile, {String? accessToken}) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.getUrl(ApiConfig.verificationSubmitVideo)),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      });

      request.files.add(await http.MultipartFile.fromPath('video', videoFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(responseBody);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to submit video verification: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while submitting video verification: $e');
    }
  }

  /// Cancel verification
  static Future<bool> cancelVerification(String verificationId, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.verificationCancel, {'verificationId': verificationId})),
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
        throw ApiException('Verification not found');
      } else {
        throw ApiException('Failed to cancel verification: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while canceling verification: $e');
    }
  }
}
