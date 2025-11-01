import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/device_session.dart';
import '../auth_service.dart';
import '../token_management_service.dart';

/// Device Session API Service
/// 
/// Endpoints:
/// - GET /api/sessions - Get all active sessions
/// - DELETE /api/sessions/{id} - Revoke a specific session
/// - DELETE /api/sessions - Revoke all other sessions
class DeviceSessionApiService {
  final AuthService _authService;

  DeviceSessionApiService({
    required AuthService authService,
  }) : _authService = authService;

  /// Get all active sessions
  Future<List<DeviceSession>> getSessions() async {
    try {
        final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/sessions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> sessionsJson = data['data'] ?? [];
        return sessionsJson
            .map((json) => DeviceSession.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch sessions');
      }
    } catch (e) {
      throw Exception('Error fetching sessions: $e');
    }
  }

  /// Revoke a specific session
  Future<void> revokeSession(String sessionId) async {
    try {
        final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/sessions/$sessionId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to revoke session');
      }
    } catch (e) {
      throw Exception('Error revoking session: $e');
    }
  }

  /// Revoke all other sessions (keep current)
  Future<void> revokeAllOtherSessions() async {
    try {
        final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/sessions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Failed to revoke all sessions');
      }
    } catch (e) {
      throw Exception('Error revoking all sessions: $e');
    }
  }
}

