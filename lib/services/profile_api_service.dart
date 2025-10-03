import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/api_models/profile_models.dart';
import '../models/user.dart';
import '../services/token_management_service.dart';

class ProfileApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// Get current user profile
  static Future<UserProfile> getCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserProfile.fromJson(data['data']);
    } else {
      throw Exception('Failed to get user profile: ${response.body}');
    }
  }

  /// Update user profile
  static Future<UserProfile> updateProfile(String token, Map<String, dynamic> profileData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/user/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(profileData),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserProfile.fromJson(data['data']);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  /// Upload profile picture
  static Future<ProfilePictureUploadResponse> uploadProfilePicture(
    String token,
    ProfilePictureUploadRequest request,
  ) async {
    // Simplified implementation - would need multipart upload in real implementation
    final response = await http.post(
      Uri.parse('$_baseUrl/user/profile/picture'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ProfilePictureUploadResponse.fromJson(data['data']);
    } else {
      throw Exception('Failed to upload profile picture: ${response.body}');
    }
  }

  /// Delete profile picture
  static Future<void> deleteProfilePicture(String token, int pictureId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/user/profile/picture/$pictureId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete profile picture: ${response.body}');
    }
  }

  /// Update profile visibility settings
  static Future<UserProfile> updateVisibilitySettings(
    String token,
    Map<String, dynamic> settings
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/user/profile/visibility'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(settings),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserProfile.fromJson(data['data']);
    } else {
      throw Exception('Failed to update visibility settings: ${response.body}');
    }
  }
}
