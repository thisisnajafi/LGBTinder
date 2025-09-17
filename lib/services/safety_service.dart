import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class SafetyService {
  /// Get safety guidelines
  static Future<Map<String, dynamic>> getSafetyGuidelines({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyGuidelines)),
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
        throw ApiException('Failed to fetch safety guidelines: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching safety guidelines: $e');
    }
  }

  /// Get emergency contacts
  static Future<List<Map<String, dynamic>>> getEmergencyContacts({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyEmergencyContacts)),
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
        throw ApiException('Failed to fetch emergency contacts: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching emergency contacts: $e');
    }
  }

  /// Add emergency contact
  static Future<Map<String, dynamic>> addEmergencyContact({
    required String name,
    required String phoneNumber,
    required String relationship,
    String? accessToken,
    String? email,
    bool? isPrimary,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'name': name,
        'phone_number': phoneNumber,
        'relationship': relationship,
      };

      if (email != null) requestBody['email'] = email;
      if (isPrimary != null) requestBody['is_primary'] = isPrimary;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyEmergencyContacts)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
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
      } else {
        throw ApiException('Failed to add emergency contact: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while adding emergency contact: $e');
    }
  }

  /// Update emergency contact
  static Future<Map<String, dynamic>> updateEmergencyContact(String contactId, Map<String, dynamic> updates, {String? accessToken}) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyEmergencyContacts) + '/$contactId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Emergency contact not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update emergency contact: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating emergency contact: $e');
    }
  }

  /// Delete emergency contact
  static Future<bool> deleteEmergencyContact(String contactId, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyEmergencyContacts) + '/$contactId'),
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
        throw ApiException('Emergency contact not found');
      } else {
        throw ApiException('Failed to delete emergency contact: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while deleting emergency contact: $e');
    }
  }

  /// Send emergency alert
  static Future<Map<String, dynamic>> sendEmergencyAlert({
    required String alertType,
    String? accessToken,
    String? message,
    Map<String, double>? location,
    List<String>? recipientIds,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final requestBody = <String, dynamic>{'alert_type': alertType};

      if (message != null) requestBody['message'] = message;
      if (location != null) requestBody['location'] = location;
      if (recipientIds != null) requestBody['recipient_ids'] = recipientIds;
      if (additionalInfo != null) requestBody['additional_info'] = additionalInfo;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyEmergencyAlert)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
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
      } else {
        throw ApiException('Failed to send emergency alert: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while sending emergency alert: $e');
    }
  }

  /// Share location with emergency contacts
  static Future<Map<String, dynamic>> shareLocation({
    required Map<String, double> location,
    String? accessToken,
    Duration? duration,
    List<String>? recipientIds,
    String? message,
  }) async {
    try {
      final requestBody = <String, dynamic>{'location': location};

      if (duration != null) requestBody['duration_minutes'] = duration.inMinutes;
      if (recipientIds != null) requestBody['recipient_ids'] = recipientIds;
      if (message != null) requestBody['message'] = message;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyShareLocation)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
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
      } else {
        throw ApiException('Failed to share location: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while sharing location: $e');
    }
  }

  /// Get nearby safe places
  static Future<List<Map<String, dynamic>>> getNearbySafePlaces({
    required Map<String, double> location,
    String? accessToken,
    double? radius,
    String? placeType,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.safetySafePlaces));
      
      // Add query parameters
      final queryParams = <String, String>{
        'latitude': location['latitude'].toString(),
        'longitude': location['longitude'].toString(),
      };
      
      if (radius != null) queryParams['radius'] = radius.toString();
      if (placeType != null) queryParams['place_type'] = placeType;
      
      uri = uri.replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
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
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid location parameters',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to fetch nearby safe places: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching nearby safe places: $e');
    }
  }

  /// Submit safety report
  static Future<Map<String, dynamic>> submitSafetyReport({
    required String incidentType,
    required String description,
    String? accessToken,
    Map<String, double>? location,
    String? reportedUserId,
    List<String>? evidenceUrls,
    File? evidenceFile,
    DateTime? incidentDate,
    String? severity,
  }) async {
    try {
      if (evidenceFile != null) {
        // Submit report with evidence file
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(ApiConfig.getUrl(ApiConfig.safetyReport)),
        );

        request.headers.addAll({
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        });

        request.fields.addAll({
          'incident_type': incidentType,
          'description': description,
          if (location != null) 'location': jsonEncode(location),
          if (reportedUserId != null) 'reported_user_id': reportedUserId,
          if (evidenceUrls != null) 'evidence_urls': jsonEncode(evidenceUrls),
          if (incidentDate != null) 'incident_date': incidentDate.toIso8601String(),
          if (severity != null) 'severity': severity,
        });

        request.files.add(await http.MultipartFile.fromPath('evidence_file', evidenceFile.path));

        final streamResponse = await request.send();
        final responseBody = await streamResponse.stream.bytesToString();
        final response = http.Response(responseBody, streamResponse.statusCode);

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
        } else {
          throw ApiException('Failed to submit safety report: ${response.statusCode}');
        }
      } else {
        // Submit report without evidence file
        final requestBody = <String, dynamic>{
          'incident_type': incidentType,
          'description': description,
        };

        if (location != null) requestBody['location'] = location;
        if (reportedUserId != null) requestBody['reported_user_id'] = reportedUserId;
        if (evidenceUrls != null) requestBody['evidence_urls'] = evidenceUrls;
        if (incidentDate != null) requestBody['incident_date'] = incidentDate.toIso8601String();
        if (severity != null) requestBody['severity'] = severity;

        final response = await http.post(
          Uri.parse(ApiConfig.getUrl(ApiConfig.safetyReport)),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(requestBody),
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
        } else {
          throw ApiException('Failed to submit safety report: ${response.statusCode}');
        }
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while submitting safety report: $e');
    }
  }

  /// Get safety report categories
  static Future<List<Map<String, dynamic>>> getSafetyReportCategories({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyReportCategories)),
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
        throw ApiException('Failed to fetch safety report categories: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching safety report categories: $e');
    }
  }

  /// Get safety report history
  static Future<List<Map<String, dynamic>>> getSafetyReportHistory({
    String? accessToken,
    int? page,
    int? limit,
    String? status,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.safetyReportHistory));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (status != null) queryParams['status'] = status;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
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
        throw ApiException('Failed to fetch safety report history: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching safety report history: $e');
    }
  }

  /// Moderate content (for admin/moderator users)
  static Future<Map<String, dynamic>> moderateContent({
    required String contentId,
    required String contentType,
    required String action,
    String? accessToken,
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'content_id': contentId,
        'content_type': contentType,
        'action': action,
      };

      if (reason != null) requestBody['reason'] = reason;
      if (metadata != null) requestBody['metadata'] = metadata;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyModerateContent)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException('Content not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to moderate content: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while moderating content: $e');
    }
  }

  /// Get safety statistics (for admin users)
  static Future<Map<String, dynamic>> getSafetyStatistics({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyStatistics)),
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
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else {
        throw ApiException('Failed to fetch safety statistics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching safety statistics: $e');
    }
  }

  /// Check user safety status
  static Future<Map<String, dynamic>> checkUserSafetyStatus(String userId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyStatistics) + '/user/$userId'),
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
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException('User not found');
      } else {
        throw ApiException('Failed to check user safety status: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while checking user safety status: $e');
    }
  }

  /// Stop location sharing
  static Future<bool> stopLocationSharing(String sharingId, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyShareLocation) + '/$sharingId'),
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
        throw ApiException('Location sharing session not found');
      } else {
        throw ApiException('Failed to stop location sharing: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while stopping location sharing: $e');
    }
  }

  /// Get safety tips
  static Future<List<Map<String, dynamic>>> getSafetyTips({
    String? accessToken,
    String? category, // 'dating', 'meeting', 'online', 'general'
    String? language,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.safetyGuidelines) + '/tips');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (language != null) queryParams['language'] = language;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
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
        throw ApiException('Failed to fetch safety tips: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching safety tips: $e');
    }
  }

  /// Get safety check-in status
  static Future<Map<String, dynamic>> getSafetyCheckInStatus({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyEmergencyAlert) + '/checkin'),
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
        throw ApiException('Failed to fetch safety check-in status: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching safety check-in status: $e');
    }
  }

  /// Send safety check-in
  static Future<Map<String, dynamic>> sendSafetyCheckIn({
    required String checkInType, // 'safe', 'unsafe', 'help_needed'
    String? accessToken,
    String? message,
    Map<String, double>? location,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final requestBody = <String, dynamic>{'check_in_type': checkInType};

      if (message != null) requestBody['message'] = message;
      if (location != null) requestBody['location'] = location;
      if (additionalInfo != null) requestBody['additional_info'] = additionalInfo;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyEmergencyAlert) + '/checkin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
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
      } else {
        throw ApiException('Failed to send safety check-in: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while sending safety check-in: $e');
    }
  }

  /// Get safety report by ID
  static Future<Map<String, dynamic>> getSafetyReportById(String reportId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyReportHistory) + '/$reportId'),
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
        throw ApiException('Safety report not found');
      } else {
        throw ApiException('Failed to fetch safety report: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching safety report: $e');
    }
  }

  /// Update safety report
  static Future<Map<String, dynamic>> updateSafetyReport(String reportId, {
    required Map<String, dynamic> updates,
    String? accessToken,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyReportHistory) + '/$reportId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Safety report not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update safety report: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating safety report: $e');
    }
  }

  /// Get safety alerts history
  static Future<List<Map<String, dynamic>>> getSafetyAlertsHistory({
    String? accessToken,
    int? page,
    int? limit,
    String? alertType,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.safetyEmergencyAlert) + '/history');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (alertType != null) queryParams['alert_type'] = alertType;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
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
        throw ApiException('Failed to fetch safety alerts history: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching safety alerts history: $e');
    }
  }

  /// Get location sharing history
  static Future<List<Map<String, dynamic>>> getLocationSharingHistory({
    String? accessToken,
    int? page,
    int? limit,
    String? status, // 'active', 'expired', 'stopped'
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.safetyShareLocation) + '/history');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (status != null) queryParams['status'] = status;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
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
        throw ApiException('Failed to fetch location sharing history: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching location sharing history: $e');
    }
  }

  /// Get safety resources
  static Future<List<Map<String, dynamic>>> getSafetyResources({
    String? accessToken,
    String? resourceType, // 'helpline', 'website', 'app', 'organization'
    String? category,
    String? language,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.safetyGuidelines) + '/resources');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (resourceType != null) queryParams['resource_type'] = resourceType;
      if (category != null) queryParams['category'] = category;
      if (language != null) queryParams['language'] = language;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
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
        throw ApiException('Failed to fetch safety resources: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching safety resources: $e');
    }
  }

  /// Report false emergency alert
  static Future<bool> reportFalseEmergencyAlert(String alertId, {
    required String reason,
    String? accessToken,
    String? additionalInfo,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'alert_id': alertId,
        'reason': reason,
      };

      if (additionalInfo != null) requestBody['additional_info'] = additionalInfo;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyEmergencyAlert) + '/false-report'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Emergency alert not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid false report data',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to report false emergency alert: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while reporting false emergency alert: $e');
    }
  }

  /// Get safety settings
  static Future<Map<String, dynamic>> getSafetySettings({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyGuidelines) + '/settings'),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? {};
      } else {
        throw ApiException('Failed to get safety settings: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      } else {
        throw NetworkException('Network error while getting safety settings: $e');
      }
    }
  }

  /// Update safety setting
  static Future<bool> updateSafetySetting({
    required String key,
    required dynamic value,
    String? accessToken,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        key: value,
      };

      final response = await http.put(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyGuidelines) + '/settings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ApiException('Failed to update safety setting: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      } else {
        throw NetworkException('Network error while updating safety setting: $e');
      }
    }
  }

  /// Remove emergency contact
  static Future<bool> removeEmergencyContact(String contactId, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrl(ApiConfig.safetyEmergencyContacts) + '/$contactId'),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ApiException('Failed to remove emergency contact: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      } else {
        throw NetworkException('Network error while removing emergency contact: $e');
      }
    }
  }
}
