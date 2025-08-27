import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'api_service.dart';

class CallService {
  final ApiService _apiService;

  CallService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Initiate a call
  Future<Call> initiateCall(
    String receiverId,
    CallType type, {
    String? receiverName,
    String? receiverAvatar,
  }) async {
    try {
      final data = <String, dynamic>{
        'receiverId': receiverId,
        'type': type.toString().split('.').last,
      };

      if (receiverName != null) {
        data['receiverName'] = receiverName;
      }
      if (receiverAvatar != null) {
        data['receiverAvatar'] = receiverAvatar;
      }

      final response = await _apiService.post('/calls', data);
      return Call.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error initiating call to $receiverId: $e');
      }
      rethrow;
    }
  }

  /// Accept a call
  Future<Call> acceptCall(String callId) async {
    try {
      final response = await _apiService.put('/calls/$callId/accept', {});
      return Call.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error accepting call $callId: $e');
      }
      rethrow;
    }
  }

  /// Reject a call
  Future<Call> rejectCall(String callId, {String? reason}) async {
    try {
      final data = <String, dynamic>{};
      if (reason != null) {
        data['reason'] = reason;
      }

      final response = await _apiService.put('/calls/$callId/reject', data);
      return Call.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error rejecting call $callId: $e');
      }
      rethrow;
    }
  }

  /// End a call
  Future<Call> endCall(String callId) async {
    try {
      final response = await _apiService.put('/calls/$callId/end', {});
      return Call.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error ending call $callId: $e');
      }
      rethrow;
    }
  }

  /// Get call by ID
  Future<Call> getCall(String callId) async {
    try {
      final response = await _apiService.get('/calls/$callId');
      return Call.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching call $callId: $e');
      }
      rethrow;
    }
  }

  /// Get call history
  Future<List<Call>> getCallHistory({
    int page = 1,
    int limit = 20,
    String? userId,
    CallType? type,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (userId != null) {
        queryParams['userId'] = userId;
      }
      if (type != null) {
        queryParams['type'] = type.toString().split('.').last;
      }

      final response = await _apiService.get('/calls/history', queryParameters: queryParams);
      
      final List<dynamic> callsData = response['calls'] ?? [];
      return callsData.map((json) => Call.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching call history: $e');
      }
      rethrow;
    }
  }

  /// Get active calls
  Future<List<Call>> getActiveCalls() async {
    try {
      final response = await _apiService.get('/calls/active');
      
      final List<dynamic> callsData = response['calls'] ?? [];
      return callsData.map((json) => Call.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching active calls: $e');
      }
      rethrow;
    }
  }

  /// Update call status
  Future<Call> updateCallStatus(String callId, CallStatus status) async {
    try {
      final response = await _apiService.put('/calls/$callId/status', {
        'status': status.toString().split('.').last,
      });
      return Call.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating call status for $callId: $e');
      }
      rethrow;
    }
  }

  /// Toggle call recording
  Future<Call> toggleCallRecording(String callId) async {
    try {
      final response = await _apiService.put('/calls/$callId/recording', {});
      return Call.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling call recording for $callId: $e');
      }
      rethrow;
    }
  }

  /// Toggle screen sharing
  Future<Call> toggleScreenSharing(String callId) async {
    try {
      final response = await _apiService.put('/calls/$callId/screen-sharing', {});
      return Call.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling screen sharing for $callId: $e');
      }
      rethrow;
    }
  }

  /// Mute/unmute call
  Future<void> toggleMute(String callId, bool isMuted) async {
    try {
      await _apiService.put('/calls/$callId/mute', {
        'isMuted': isMuted,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling mute for call $callId: $e');
      }
      rethrow;
    }
  }

  /// Switch camera (for video calls)
  Future<void> switchCamera(String callId) async {
    try {
      await _apiService.put('/calls/$callId/camera', {});
    } catch (e) {
      if (kDebugMode) {
        print('Error switching camera for call $callId: $e');
      }
      rethrow;
    }
  }

  /// Enable/disable video (for video calls)
  Future<void> toggleVideo(String callId, bool isVideoEnabled) async {
    try {
      await _apiService.put('/calls/$callId/video', {
        'isVideoEnabled': isVideoEnabled,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling video for call $callId: $e');
      }
      rethrow;
    }
  }

  /// Hold/unhold call
  Future<void> toggleHold(String callId, bool isOnHold) async {
    try {
      await _apiService.put('/calls/$callId/hold', {
        'isOnHold': isOnHold,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling hold for call $callId: $e');
      }
      rethrow;
    }
  }

  /// Transfer call to another user
  Future<Call> transferCall(String callId, String targetUserId) async {
    try {
      final response = await _apiService.put('/calls/$callId/transfer', {
        'targetUserId': targetUserId,
      });
      return Call.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error transferring call $callId to $targetUserId: $e');
      }
      rethrow;
    }
  }

  /// Add participant to call (for group calls)
  Future<Call> addParticipant(String callId, String userId) async {
    try {
      final response = await _apiService.post('/calls/$callId/participants', {
        'userId': userId,
      });
      return Call.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding participant to call $callId: $e');
      }
      rethrow;
    }
  }

  /// Remove participant from call
  Future<Call> removeParticipant(String callId, String userId) async {
    try {
      final response = await _apiService.post('/calls/$callId/participants/remove', {
        'userId': userId,
      });
      return Call.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error removing participant from call $callId: $e');
      }
      rethrow;
    }
  }

  /// Get call statistics
  Future<Map<String, dynamic>> getCallStats(String callId) async {
    try {
      final response = await _apiService.get('/calls/$callId/stats');
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching call stats for $callId: $e');
      }
      rethrow;
    }
  }

  /// Get call quality metrics
  Future<Map<String, dynamic>> getCallQuality(String callId) async {
    try {
      final response = await _apiService.get('/calls/$callId/quality');
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching call quality for $callId: $e');
      }
      rethrow;
    }
  }

  /// Send call signal (for WebRTC)
  Future<void> sendCallSignal(String callId, Map<String, dynamic> signal) async {
    try {
      await _apiService.post('/calls/$callId/signals', signal);
    } catch (e) {
      if (kDebugMode) {
        print('Error sending call signal for $callId: $e');
      }
      rethrow;
    }
  }

  /// Get call signals (for WebRTC)
  Future<List<Map<String, dynamic>>> getCallSignals(String callId) async {
    try {
      final response = await _apiService.get('/calls/$callId/signals');
      final List<dynamic> signalsData = response['signals'] ?? [];
      return signalsData.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching call signals for $callId: $e');
      }
      rethrow;
    }
  }

  /// Block a user from calling
  Future<void> blockUser(String userId) async {
    try {
      await _apiService.post('/calls/block', {
        'userId': userId,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error blocking user $userId: $e');
      }
      rethrow;
    }
  }

  /// Unblock a user from calling
  Future<void> unblockUser(String userId) async {
    try {
      await _apiService.post('/calls/unblock', {
        'userId': userId,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error unblocking user $userId: $e');
      }
      rethrow;
    }
  }

  /// Get blocked users
  Future<List<String>> getBlockedUsers() async {
    try {
      final response = await _apiService.get('/calls/blocked');
      final List<dynamic> blockedData = response['blockedUsers'] ?? [];
      return blockedData.cast<String>();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching blocked users: $e');
      }
      rethrow;
    }
  }

  /// Report a call
  Future<void> reportCall(String callId, String reason) async {
    try {
      await _apiService.post('/calls/$callId/report', {
        'reason': reason,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error reporting call $callId: $e');
      }
      rethrow;
    }
  }
}
