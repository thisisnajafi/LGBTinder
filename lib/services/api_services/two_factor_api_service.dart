import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../auth_service.dart';
import '../token_management_service.dart';

/// Two-Factor Authentication API Service
/// 
/// Endpoints:
/// - POST /api/2fa/enable - Enable 2FA
/// - POST /api/2fa/verify - Verify 2FA code during setup
/// - POST /api/2fa/disable - Disable 2FA
/// - GET /api/2fa/qr-code - Get QR code for authenticator app
/// - POST /api/2fa/backup-codes - Generate backup codes
/// - GET /api/2fa/status - Check 2FA status
class TwoFactorApiService {
  final AuthService _authService;

  TwoFactorApiService({
    required AuthService authService,
  }) : _authService = authService;

  /// Get 2FA status
  Future<Map<String, dynamic>> get2FAStatus() async {
    try {
        final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/2fa/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to fetch 2FA status');
      }
    } catch (e) {
      throw Exception('Error fetching 2FA status: $e');
    }
  }

  /// Enable 2FA
  Future<Map<String, dynamic>> enable2FA() async {
    try {
        final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/2fa/enable'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'] ?? {};
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to enable 2FA');
      }
    } catch (e) {
      throw Exception('Error enabling 2FA: $e');
    }
  }

  /// Verify 2FA code during setup
  Future<Map<String, dynamic>> verify2FASetup({
    required String code,
  }) async {
    try {
        final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/2fa/verify'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'code': code}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'] ?? {};
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Invalid verification code');
      }
    } catch (e) {
      throw Exception('Error verifying 2FA: $e');
    }
  }

  /// Disable 2FA
  Future<void> disable2FA({
    required String password,
    String? code,
  }) async {
    try {
        final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/2fa/disable'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'password': password,
          'code': code,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to disable 2FA');
      }
    } catch (e) {
      throw Exception('Error disabling 2FA: $e');
    }
  }

  /// Get QR code for authenticator app
  Future<String> getQRCode() async {
    try {
        final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/2fa/qr-code'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data']['qr_code'] ?? '';
      } else {
        throw Exception('Failed to fetch QR code');
      }
    } catch (e) {
      throw Exception('Error fetching QR code: $e');
    }
  }

  /// Generate backup codes
  Future<List<String>> generateBackupCodes() async {
    try {
        final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/2fa/backup-codes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> codes = data['data']['backup_codes'] ?? [];
        return codes.map((code) => code.toString()).toList();
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to generate backup codes');
      }
    } catch (e) {
      throw Exception('Error generating backup codes: $e');
    }
  }
}

