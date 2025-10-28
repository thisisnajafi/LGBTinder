import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/emergency_contact.dart';
import '../auth_service.dart';

/// API Service for Emergency Contacts
/// 
/// Endpoints:
/// - GET /api/emergency-contacts - Get all emergency contacts
/// - POST /api/emergency-contacts - Add new emergency contact
/// - PUT /api/emergency-contacts/{id} - Update emergency contact
/// - DELETE /api/emergency-contacts/{id} - Delete emergency contact
/// - POST /api/emergency-contacts/{id}/verify - Send verification code
/// - POST /api/emergency-contacts/{id}/verify-code - Verify contact with code
/// - POST /api/emergency-contacts/alert - Send emergency alert to all contacts
class EmergencyContactApiService {
  final AuthService _authService;

  EmergencyContactApiService({
    required AuthService authService,
  }) : _authService = authService;

  /// Get all emergency contacts
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/emergency-contacts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> contactsJson = data['data'] ?? [];
        return contactsJson
            .map((json) => EmergencyContact.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch emergency contacts');
      }
    } catch (e) {
      throw Exception('Error fetching emergency contacts: $e');
    }
  }

  /// Add new emergency contact
  Future<EmergencyContact> addEmergencyContact({
    required String name,
    required String phoneNumber,
    String? email,
    required String relationship,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/emergency-contacts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'phone_number': phoneNumber,
          'email': email,
          'relationship': relationship,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return EmergencyContact.fromJson(data['data']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to add emergency contact');
      }
    } catch (e) {
      throw Exception('Error adding emergency contact: $e');
    }
  }

  /// Update emergency contact
  Future<EmergencyContact> updateEmergencyContact({
    required String contactId,
    String? name,
    String? phoneNumber,
    String? email,
    String? relationship,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phoneNumber != null) body['phone_number'] = phoneNumber;
      if (email != null) body['email'] = email;
      if (relationship != null) body['relationship'] = relationship;

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/emergency-contacts/$contactId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return EmergencyContact.fromJson(data['data']);
      } else {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Failed to update emergency contact');
      }
    } catch (e) {
      throw Exception('Error updating emergency contact: $e');
    }
  }

  /// Delete emergency contact
  Future<void> deleteEmergencyContact(String contactId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/emergency-contacts/$contactId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Failed to delete emergency contact');
      }
    } catch (e) {
      throw Exception('Error deleting emergency contact: $e');
    }
  }

  /// Send verification code to contact
  Future<void> sendVerificationCode(String contactId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/emergency-contacts/$contactId/verify'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Failed to send verification code');
      }
    } catch (e) {
      throw Exception('Error sending verification code: $e');
    }
  }

  /// Verify contact with code
  Future<EmergencyContact> verifyContact({
    required String contactId,
    required String code,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.post(
        Uri.parse(
            '${ApiConfig.baseUrl}/emergency-contacts/$contactId/verify-code'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'code': code}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return EmergencyContact.fromJson(data['data']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to verify contact');
      }
    } catch (e) {
      throw Exception('Error verifying contact: $e');
    }
  }

  /// Send emergency alert to all contacts
  Future<void> sendEmergencyAlert({
    required String message,
    required double latitude,
    required double longitude,
    String? meetingDetails,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/emergency-contacts/alert'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'message': message,
          'latitude': latitude,
          'longitude': longitude,
          'meeting_details': meetingDetails,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to send emergency alert');
      }
    } catch (e) {
      throw Exception('Error sending emergency alert: $e');
    }
  }
}

