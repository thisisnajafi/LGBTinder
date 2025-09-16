import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class UserService {

  // Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _apiService.getData('/user/profile');
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> userData) async {
    return await _apiService.updateData('/user/profile', userData);
  }

  // Update user avatar
  Future<Map<String, dynamic>> updateAvatar(String imagePath) async {
    // This would typically involve file upload
    // For now, we'll use a simple update with image URL
    return await _apiService.updateData('/user/avatar', {
      'avatar_url': imagePath,
    });
  }

  // Get user by ID
  Future<Map<String, dynamic>> getUserById(String userId) async {
    return await _apiService.getData('/users/$userId');
  }

  // Search users
  Future<Map<String, dynamic>> searchUsers({
    String? query,
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = <String, String>{};
    
    if (query != null) queryParams['q'] = query;
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    
    if (filters != null) {
      filters.forEach((key, value) {
        if (value != null) queryParams[key] = value.toString();
      });
    }

    return await _apiService.getData('/users', queryParameters: queryParams);
  }

  // Get nearby users
  Future<Map<String, dynamic>> getNearbyUsers({
    required double latitude,
    required double longitude,
    double? radius,
    int? limit,
  }) async {
    final queryParams = <String, String>{
      'lat': latitude.toString(),
      'lng': longitude.toString(),
    };
    
    if (radius != null) queryParams['radius'] = radius.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    return await _apiService.getData('/users/nearby', queryParameters: queryParams);
  }

  // Delete user account
  Future<Map<String, dynamic>> deleteAccount() async {
    return await _apiService.deleteData('/user/account');
  }

  // Block user
  Future<Map<String, dynamic>> blockUser(String userId) async {
    return await _apiService.postData('/users/$userId/block', {});
  }

  // Unblock user
  Future<Map<String, dynamic>> unblockUser(String userId) async {
    return await _apiService.deleteData('/users/$userId/block');
  }

  // Report user
  Future<Map<String, dynamic>> reportUser(String userId, String reason) async {
    return await _apiService.postData('/users/$userId/report', {
      'reason': reason,
    });
  }

  // Get blocked users
  Future<Map<String, dynamic>> getBlockedUsers() async {
    return await _apiService.getData('/user/blocked');
  }

  // Update user preferences
  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> preferences) async {
    return await _apiService.updateData('/user/preferences', preferences);
  }

  // Get user preferences
  Future<Map<String, dynamic>> getPreferences() async {
    return await _apiService.getData('/user/preferences');
  }

  // Update user location
  Future<Map<String, dynamic>> updateLocation(double latitude, double longitude) async {
    return await _apiService.updateData('/user/location', {
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    return await _apiService.getData('/user/stats');
  }
} 