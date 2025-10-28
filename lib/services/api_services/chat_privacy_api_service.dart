import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../config/api_config.dart';

/// Chat Privacy API Service
/// 
/// Handles chat privacy settings and backup
class ChatPrivacyApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// Update privacy settings
  static Future<PrivacyResponse> updatePrivacySettings({
    required String token,
    bool? canMessageMe,
    bool? showOnlineStatus,
    bool? showReadReceipts,
    bool? showLastSeen,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (canMessageMe != null) body['can_message_me'] = canMessageMe ? 'everyone' : 'matches_only';
      if (showOnlineStatus != null) body['show_online_status'] = showOnlineStatus;
      if (showReadReceipts != null) body['show_read_receipts'] = showReadReceipts;
      if (showLastSeen != null) body['show_last_seen'] = showLastSeen;

      final response = await http.put(
        Uri.parse('$_baseUrl/settings/privacy'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return PrivacyResponse(
          success: true,
          settings: PrivacySettings.fromJson(data['data'] as Map<String, dynamic>),
          message: data['message'] as String?,
        );
      }

      return PrivacyResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error updating privacy settings: $e');
      return PrivacyResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Get privacy settings
  static Future<PrivacyResponse> getPrivacySettings({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/settings/privacy'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return PrivacyResponse(
          success: true,
          settings: PrivacySettings.fromJson(data['data'] as Map<String, dynamic>),
        );
      }

      return PrivacyResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error getting privacy settings: $e');
      return PrivacyResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Create chat backup
  static Future<BackupResponse> createBackup({
    required String token,
    String? chatId, // If null, backup all chats
  }) async {
    try {
      final body = <String, dynamic>{};
      if (chatId != null) body['chat_id'] = chatId;

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/backup'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return BackupResponse(
          success: true,
          backupId: data['data']['backup_id'] as String?,
          backupUrl: data['data']['backup_url'] as String?,
          message: data['message'] as String?,
        );
      }

      return BackupResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error creating backup: $e');
      return BackupResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Get backup list
  static Future<BackupListResponse> getBackups({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/chat/backups'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        final backups = (data['data'] as List?)
                ?.map((b) => ChatBackup.fromJson(b as Map<String, dynamic>))
                .toList() ??
            [];

        return BackupListResponse(
          success: true,
          backups: backups,
        );
      }

      return BackupListResponse(
        success: false,
        backups: [],
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error getting backups: $e');
      return BackupListResponse(
        success: false,
        backups: [],
        error: e.toString(),
      );
    }
  }

  /// Restore from backup
  static Future<BackupResponse> restoreBackup({
    required String token,
    required String backupId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/backup/$backupId/restore'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return BackupResponse(
          success: true,
          message: data['message'] as String?,
        );
      }

      return BackupResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      return BackupResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Delete backup
  static Future<BackupResponse> deleteBackup({
    required String token,
    required String backupId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/chat/backup/$backupId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return BackupResponse(
          success: true,
          message: data['message'] as String?,
        );
      }

      return BackupResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error deleting backup: $e');
      return BackupResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Export chat as text/PDF
  static Future<ExportResponse> exportChat({
    required String token,
    required String chatId,
    required String format, // 'text' or 'pdf'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/$chatId/export'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'format': format,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return ExportResponse(
          success: true,
          exportUrl: data['data']['export_url'] as String?,
          message: data['message'] as String?,
        );
      }

      return ExportResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error exporting chat: $e');
      return ExportResponse(
        success: false,
        error: e.toString(),
      );
    }
  }
}

/// Privacy Response
class PrivacyResponse {
  final bool success;
  final PrivacySettings? settings;
  final String? message;
  final String? error;

  PrivacyResponse({
    required this.success,
    this.settings,
    this.message,
    this.error,
  });
}

/// Privacy Settings Model
class PrivacySettings {
  final String canMessageMe; // 'everyone' or 'matches_only'
  final bool showOnlineStatus;
  final bool showReadReceipts;
  final bool showLastSeen;

  PrivacySettings({
    required this.canMessageMe,
    required this.showOnlineStatus,
    required this.showReadReceipts,
    required this.showLastSeen,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      canMessageMe: json['can_message_me'] as String? ?? 'everyone',
      showOnlineStatus: json['show_online_status'] as bool? ?? true,
      showReadReceipts: json['show_read_receipts'] as bool? ?? true,
      showLastSeen: json['show_last_seen'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'can_message_me': canMessageMe,
      'show_online_status': showOnlineStatus,
      'show_read_receipts': showReadReceipts,
      'show_last_seen': showLastSeen,
    };
  }
}

/// Backup Response
class BackupResponse {
  final bool success;
  final String? backupId;
  final String? backupUrl;
  final String? message;
  final String? error;

  BackupResponse({
    required this.success,
    this.backupId,
    this.backupUrl,
    this.message,
    this.error,
  });
}

/// Backup List Response
class BackupListResponse {
  final bool success;
  final List<ChatBackup> backups;
  final String? error;

  BackupListResponse({
    required this.success,
    required this.backups,
    this.error,
  });
}

/// Chat Backup Model
class ChatBackup {
  final String id;
  final String? chatId;
  final int messageCount;
  final int fileSize;
  final DateTime createdAt;
  final String? downloadUrl;

  ChatBackup({
    required this.id,
    this.chatId,
    required this.messageCount,
    required this.fileSize,
    required this.createdAt,
    this.downloadUrl,
  });

  factory ChatBackup.fromJson(Map<String, dynamic> json) {
    return ChatBackup(
      id: json['id'].toString(),
      chatId: json['chat_id']?.toString(),
      messageCount: json['message_count'] as int,
      fileSize: json['file_size'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      downloadUrl: json['download_url'] as String?,
    );
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isAllChats => chatId == null;
}

/// Export Response
class ExportResponse {
  final bool success;
  final String? exportUrl;
  final String? message;
  final String? error;

  ExportResponse({
    required this.success,
    this.exportUrl,
    this.message,
    this.error,
  });
}

