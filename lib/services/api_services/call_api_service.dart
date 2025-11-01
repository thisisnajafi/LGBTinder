import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../auth_service.dart';

/// Call API Service
/// 
/// Handles all API calls related to voice and video calling:
/// - Initiate calls
/// - Get call history
/// - Get call details
/// - Block calls from users
/// - Report call issues
class CallApiService {
  /// Initiate a call
  /// 
  /// POST /api/calls/initiate
  Future<CallInitiationResponse?> initiateCall({
    required String toUserId,
    required bool isVideo,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/calls/initiate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'to_user_id': toUserId,
          'is_video': isVideo,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return CallInitiationResponse.fromJson(data['data']);
      } else {
        throw Exception('Failed to initiate call: ${response.statusCode}');
      }
    } catch (e) {
      print('Error initiating call: $e');
      return null;
    }
  }

  /// Get call history
  /// 
  /// GET /api/calls/history
  Future<List<CallHistoryItem>> getCallHistory({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/calls/history?page=$page&per_page=$perPage'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> calls = data['data'] ?? [];
        return calls.map((call) => CallHistoryItem.fromJson(call)).toList();
      } else {
        throw Exception('Failed to fetch call history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching call history: $e');
      return [];
    }
  }

  /// Get call details
  /// 
  /// GET /api/calls/{callId}
  Future<CallDetails?> getCallDetails(String callId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/calls/$callId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CallDetails.fromJson(data['data']);
      } else {
        throw Exception('Failed to fetch call details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching call details: $e');
      return null;
    }
  }

  /// End a call
  /// 
  /// POST /api/calls/{callId}/end
  Future<bool> endCall(String callId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/calls/$callId/end'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'ended_at': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error ending call: $e');
      return false;
    }
  }

  /// Block calls from a user
  /// 
  /// POST /api/calls/block
  Future<bool> blockCallsFrom(String userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/calls/block'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error blocking calls: $e');
      return false;
    }
  }

  /// Unblock calls from a user
  /// 
  /// POST /api/calls/unblock
  Future<bool> unblockCallsFrom(String userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/calls/unblock'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error unblocking calls: $e');
      return false;
    }
  }

  /// Report a call issue
  /// 
  /// POST /api/calls/{callId}/report
  Future<bool> reportCall({
    required String callId,
    required String reason,
    String? description,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/calls/$callId/report'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'reason': reason,
          'description': description,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error reporting call: $e');
      return false;
    }
  }

  /// Delete call from history
  /// 
  /// DELETE /api/calls/{callId}
  Future<bool> deleteCallFromHistory(String callId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/calls/$callId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting call: $e');
      return false;
    }
  }
}

/// Call Initiation Response Model
class CallInitiationResponse {
  final String callId;
  final String toUserId;
  final String status;
  final DateTime initiatedAt;

  CallInitiationResponse({
    required this.callId,
    required this.toUserId,
    required this.status,
    required this.initiatedAt,
  });

  factory CallInitiationResponse.fromJson(Map<String, dynamic> json) {
    return CallInitiationResponse(
      callId: json['call_id'] as String,
      toUserId: json['to_user_id'] as String,
      status: json['status'] as String,
      initiatedAt: DateTime.parse(json['initiated_at'] as String),
    );
  }
}

/// Call History Item Model
class CallHistoryItem {
  final String callId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final bool isVideo;
  final CallDirection direction;
  final CallStatus status;
  final int? duration; // in seconds
  final DateTime createdAt;
  final bool isMissed;

  CallHistoryItem({
    required this.callId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.isVideo,
    required this.direction,
    required this.status,
    this.duration,
    required this.createdAt,
    this.isMissed = false,
  });

  factory CallHistoryItem.fromJson(Map<String, dynamic> json) {
    return CallHistoryItem(
      callId: json['call_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userAvatar: json['user_avatar'] as String?,
      isVideo: json['is_video'] as bool? ?? false,
      direction: json['direction'] == 'incoming'
          ? CallDirection.incoming
          : CallDirection.outgoing,
      status: _parseCallStatus(json['status'] as String),
      duration: json['duration'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isMissed: json['is_missed'] as bool? ?? false,
    );
  }

  static CallStatus _parseCallStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return CallStatus.completed;
      case 'missed':
        return CallStatus.missed;
      case 'rejected':
        return CallStatus.rejected;
      case 'cancelled':
        return CallStatus.cancelled;
      case 'failed':
        return CallStatus.failed;
      default:
        return CallStatus.completed;
    }
  }

  String get formattedDuration {
    if (duration == null || duration == 0) return '--:--';
    
    final minutes = (duration! / 60).floor();
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}

/// Call Details Model
class CallDetails {
  final String callId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final bool isVideo;
  final CallDirection direction;
  final CallStatus status;
  final int? duration;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? endReason;

  CallDetails({
    required this.callId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.isVideo,
    required this.direction,
    required this.status,
    this.duration,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.endReason,
  });

  factory CallDetails.fromJson(Map<String, dynamic> json) {
    return CallDetails(
      callId: json['call_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userAvatar: json['user_avatar'] as String?,
      isVideo: json['is_video'] as bool? ?? false,
      direction: json['direction'] == 'incoming'
          ? CallDirection.incoming
          : CallDirection.outgoing,
      status: CallHistoryItem._parseCallStatus(json['status'] as String),
      duration: json['duration'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      endReason: json['end_reason'] as String?,
    );
  }
}

/// Call Direction Enum
enum CallDirection {
  incoming,
  outgoing,
}

/// Call Status Enum
enum CallStatus {
  completed,
  missed,
  rejected,
  cancelled,
  failed,
}

