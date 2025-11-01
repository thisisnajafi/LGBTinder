import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../auth_service.dart';
import '../token_management_service.dart';

/// Account Management API Service
/// 
/// Endpoints:
/// - PUT /api/account/email - Update email
/// - PUT /api/account/password - Update password
/// - POST /api/account/deactivate - Deactivate account
/// - DELETE /api/account - Delete account permanently
class AccountManagementApiService {
  final AuthService _authService;

  AccountManagementApiService({
    required AuthService authService,
  }) : _authService = authService;

  /// Update email
  Future<void> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
        final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/account/email'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': newEmail,
          'password': password,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update email');
      }
    } catch (e) {
      throw Exception('Error updating email: $e');
    }
  }

  /// Update password
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
        final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/account/password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update password');
      }
    } catch (e) {
      throw Exception('Error updating password: $e');
    }
  }

  /// Deactivate account
  Future<void> deactivateAccount({
    required String password,
    String? reason,
  }) async {
    try {
        final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/account/deactivate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'password': password,
          'reason': reason,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to deactivate account');
      }
    } catch (e) {
      throw Exception('Error deactivating account: $e');
    }
  }

  /// Delete account permanently
  Future<void> deleteAccount({
    required String password,
    String? reason,
  }) async {
    try {
        final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/account'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'password': password,
          'reason': reason,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete account');
      }
    } catch (e) {
      throw Exception('Error deleting account: $e');
    }
  }
}

