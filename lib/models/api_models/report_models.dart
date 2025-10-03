/// Report-related API models

/// Report request model
class ReportRequest {
  final int reportedUserId;
  final String reportType;
  final String? reportReason;
  final String? description;
  final Map<String, dynamic>? evidence;

  const ReportRequest({
    required this.reportedUserId,
    required this.reportType,
    this.reportReason,
    this.description,
    this.evidence,
  });

  factory ReportRequest.fromJson(Map<String, dynamic> json) {
    return ReportRequest(
      reportedUserId: json['reported_user_id'] as int,
      reportType: json['report_type'] as String,
      reportReason: json['report_reason'] as String?,
      description: json['description'] as String?,
      evidence: json['evidence'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reported_user_id': reportedUserId,
      'report_type': reportType,
      'report_reason': reportReason,
      'description': description,
      'evidence': evidence,
    };
  }
}

/// Report response model
class ReportResponse {
  final int reportId;
  final String status;
  final String message;
  final DateTime createdAt;

  const ReportResponse({
    required this.reportId,
    required this.status,
    required this.message,
    required this.createdAt,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      reportId: json['report_id'] as int,
      status: json['status'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'status': status,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Report data model
class ReportData {
  final int id;
  final int reportedUserId;
  final String reportedUserName;
  final String reportType;
  final String? reportReason;
  final String? description;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? evidence;

  const ReportData({
    required this.id,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reportType,
    this.reportReason,
    this.description,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.evidence,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      id: json['id'] as int,
      reportedUserId: json['reported_user_id'] as int,
      reportedUserName: json['reported_user_name'] as String,
      reportType: json['report_type'] as String,
      reportReason: json['report_reason'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      evidence: json['evidence'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reported_user_id': reportedUserId,
      'reported_user_name': reportedUserName,
      'report_type': reportType,
      'report_reason': reportReason,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'evidence': evidence,
    };
  }
}
