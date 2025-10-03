import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/api_models/report_models.dart';
import '../services/token_management_service.dart';

class ReportingService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// Report a user
  static Future<ReportResponse> reportUser(String token, ReportRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/reports'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return ReportResponse.fromJson(data['data']);
    } else {
      throw Exception('Failed to report user: ${response.body}');
    }
  }

  /// Get user's report history
  static Future<List<ReportData>> getReportHistory({required String accessToken}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/reports'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final reports = data['data'] as List;
      return reports.map((report) => ReportData.fromJson(report)).toList();
    } else {
      throw Exception('Failed to get report history: ${response.body}');
    }
  }

  /// Cancel a report
  static Future<void> cancelReport(String accessToken, int reportId) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/reports/$reportId/cancel'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel report: ${response.body}');
    }
  }

  /// Update report status
  static Future<ReportData> updateReportStatus(
    String token, 
    int reportId, 
    String status
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/reports/$reportId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'status': status}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ReportData.fromJson(data['data']);
    } else {
      throw Exception('Failed to update report status: ${response.body}');
    }
  }

  /// Get report details
  static Future<ReportData> getReportDetails(String token, int reportId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/reports/$reportId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ReportData.fromJson(data['data']);
    } else {
      throw Exception('Failed to get report details: ${response.body}');
    }
  }
}
