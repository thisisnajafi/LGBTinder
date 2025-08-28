import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class ReportsService {
  /// Get reports (for admin/moderator users)
  static Future<List<Map<String, dynamic>>> getReports({
    String? accessToken,
    int? page,
    int? limit,
    String? status,
    String? category,
    String? sortBy,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.reports));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      
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
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else {
        throw ApiException('Failed to fetch reports: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching reports: $e');
    }
  }

  /// Create a new report
  static Future<Map<String, dynamic>> createReport({
    required String reportedUserId,
    required String category,
    required String reason,
    String? accessToken,
    String? description,
    List<String>? evidenceUrls,
    File? evidenceFile,
    String? reportedContentId,
    String? reportedContentType, // 'profile', 'message', 'feed', 'story', etc.
  }) async {
    try {
      if (evidenceFile != null) {
        // Create report with evidence file
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(ApiConfig.getUrl(ApiConfig.reports)),
        );

        request.headers.addAll({
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        });

        request.fields.addAll({
          'reported_user_id': reportedUserId,
          'category': category,
          'reason': reason,
          if (description != null) 'description': description,
          if (evidenceUrls != null) 'evidence_urls': jsonEncode(evidenceUrls),
          if (reportedContentId != null) 'reported_content_id': reportedContentId,
          if (reportedContentType != null) 'reported_content_type': reportedContentType,
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
        } else if (response.statusCode == 404) {
          throw ApiException('Reported user not found');
        } else {
          throw ApiException('Failed to create report: ${response.statusCode}');
        }
      } else {
        // Create report without evidence file
        final requestBody = {
          'reported_user_id': reportedUserId,
          'category': category,
          'reason': reason,
        };

        if (description != null) requestBody['description'] = description;
        if (evidenceUrls != null) requestBody['evidence_urls'] = evidenceUrls;
        if (reportedContentId != null) requestBody['reported_content_id'] = reportedContentId;
        if (reportedContentType != null) requestBody['reported_content_type'] = reportedContentType;

        final response = await http.post(
          Uri.parse(ApiConfig.getUrl(ApiConfig.reports)),
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
        } else if (response.statusCode == 404) {
          throw ApiException('Reported user not found');
        } else {
          throw ApiException('Failed to create report: ${response.statusCode}');
        }
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while creating report: $e');
    }
  }

  /// Get report by ID
  static Future<Map<String, dynamic>> getReport(String reportId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.reportsById, {'id': reportId})),
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
        throw ApiException('Report not found');
      } else {
        throw ApiException('Failed to fetch report: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching report: $e');
    }
  }

  /// Update report status (for admin/moderator users)
  static Future<Map<String, dynamic>> updateReportStatus(String reportId, {
    required String status,
    String? accessToken,
    String? moderatorNotes,
    String? resolution,
    Map<String, dynamic>? actionTaken,
  }) async {
    try {
      final requestBody = {'status': status};
      
      if (moderatorNotes != null) requestBody['moderator_notes'] = moderatorNotes;
      if (resolution != null) requestBody['resolution'] = resolution;
      if (actionTaken != null) requestBody['action_taken'] = actionTaken;

      final response = await http.put(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.reportsById, {'id': reportId})),
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
        throw ApiException('Report not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update report status: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating report status: $e');
    }
  }

  /// Delete report (for admin users)
  static Future<bool> deleteReport(String reportId, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.reportsById, {'id': reportId})),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException('Report not found');
      } else {
        throw ApiException('Failed to delete report: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while deleting report: $e');
    }
  }

  /// Get report categories
  static Future<List<Map<String, dynamic>>> getReportCategories({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.reports) + '/categories'),
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
        throw ApiException('Failed to fetch report categories: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching report categories: $e');
    }
  }

  /// Get user's submitted reports
  static Future<List<Map<String, dynamic>>> getUserReports({
    String? accessToken,
    int? page,
    int? limit,
    String? status,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.reports) + '/my');
      
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
        throw ApiException('Failed to fetch user reports: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching user reports: $e');
    }
  }

  /// Get report statistics (for admin/moderator users)
  static Future<Map<String, dynamic>> getReportStatistics({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.reports) + '/statistics'),
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
        throw ApiException('Failed to fetch report statistics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching report statistics: $e');
    }
  }

  /// Assign report to moderator (for admin users)
  static Future<Map<String, dynamic>> assignReport(String reportId, String moderatorId, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.reportsById, {'id': reportId}) + '/assign'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'moderator_id': moderatorId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException('Report or moderator not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid moderator assignment',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to assign report: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while assigning report: $e');
    }
  }

  /// Add note to report (for admin/moderator users)
  static Future<Map<String, dynamic>> addReportNote(String reportId, String note, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.reportsById, {'id': reportId}) + '/notes'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'note': note,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied - insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException('Report not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid note',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to add report note: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while adding report note: $e');
    }
  }

  /// Get report template for specific category
  static Future<Map<String, dynamic>> getReportTemplate(String category, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.reports) + '/template?category=$category'),
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
        throw ApiException('Report template not found for this category');
      } else {
        throw ApiException('Failed to fetch report template: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching report template: $e');
    }
  }
}
