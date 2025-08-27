import 'package:flutter/foundation.dart';

enum CallType {
  voice,
  video,
}

enum CallStatus {
  incoming,
  outgoing,
  connecting,
  connected,
  ended,
  missed,
  rejected,
  busy,
  failed,
}

class Call {
  final String id;
  final String callerId;
  final String receiverId;
  final CallType type;
  final CallStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final String? callerName;
  final String? receiverName;
  final String? callerAvatar;
  final String? receiverAvatar;
  final Map<String, dynamic>? metadata;
  final bool isRecording;
  final bool isScreenSharing;
  final String? recordingUrl;
  final String? failureReason;

  const Call({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    this.duration,
    this.callerName,
    this.receiverName,
    this.callerAvatar,
    this.receiverAvatar,
    this.metadata,
    this.isRecording = false,
    this.isScreenSharing = false,
    this.recordingUrl,
    this.failureReason,
  });

  factory Call.fromJson(Map<String, dynamic> json) {
    return Call(
      id: json['id'] as String,
      callerId: json['callerId'] as String,
      receiverId: json['receiverId'] as String,
      type: CallType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => CallType.voice,
      ),
      status: CallStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => CallStatus.ended,
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      callerName: json['callerName'] as String?,
      receiverName: json['receiverName'] as String?,
      callerAvatar: json['callerAvatar'] as String?,
      receiverAvatar: json['receiverAvatar'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRecording: json['isRecording'] as bool? ?? false,
      isScreenSharing: json['isScreenSharing'] as bool? ?? false,
      recordingUrl: json['recordingUrl'] as String?,
      failureReason: json['failureReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'callerId': callerId,
      'receiverId': receiverId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration?.inMilliseconds,
      'callerName': callerName,
      'receiverName': receiverName,
      'callerAvatar': callerAvatar,
      'receiverAvatar': receiverAvatar,
      'metadata': metadata,
      'isRecording': isRecording,
      'isScreenSharing': isScreenSharing,
      'recordingUrl': recordingUrl,
      'failureReason': failureReason,
    };
  }

  Call copyWith({
    String? id,
    String? callerId,
    String? receiverId,
    CallType? type,
    CallStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    String? callerName,
    String? receiverName,
    String? callerAvatar,
    String? receiverAvatar,
    Map<String, dynamic>? metadata,
    bool? isRecording,
    bool? isScreenSharing,
    String? recordingUrl,
    String? failureReason,
  }) {
    return Call(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      callerName: callerName ?? this.callerName,
      receiverName: receiverName ?? this.receiverName,
      callerAvatar: callerAvatar ?? this.callerAvatar,
      receiverAvatar: receiverAvatar ?? this.receiverAvatar,
      metadata: metadata ?? this.metadata,
      isRecording: isRecording ?? this.isRecording,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  // Helper methods
  bool get isActive => status == CallStatus.connecting || status == CallStatus.connected;
  bool get isIncoming => status == CallStatus.incoming;
  bool get isOutgoing => status == CallStatus.outgoing;
  bool get isEnded => status == CallStatus.ended || status == CallStatus.missed || status == CallStatus.rejected;
  bool get isVideoCall => type == CallType.video;
  bool get isVoiceCall => type == CallType.voice;

  String get displayName {
    if (isIncoming) {
      return callerName ?? 'Unknown Caller';
    }
    return receiverName ?? 'Unknown Receiver';
  }

  String? get displayAvatar {
    if (isIncoming) {
      return callerAvatar;
    }
    return receiverAvatar;
  }

  String get callTypeText {
    return isVideoCall ? 'Video Call' : 'Voice Call';
  }

  String get statusText {
    switch (status) {
      case CallStatus.incoming:
        return 'Incoming call';
      case CallStatus.outgoing:
        return 'Calling...';
      case CallStatus.connecting:
        return 'Connecting...';
      case CallStatus.connected:
        return 'Connected';
      case CallStatus.ended:
        return 'Call ended';
      case CallStatus.missed:
        return 'Missed call';
      case CallStatus.rejected:
        return 'Call rejected';
      case CallStatus.busy:
        return 'Busy';
      case CallStatus.failed:
        return 'Call failed';
    }
  }

  String get durationText {
    if (duration == null) return '';
    
    final minutes = duration!.inMinutes;
    final seconds = duration!.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(startTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Call && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Call(id: $id, type: $type, status: $status, duration: $durationText)';
  }
}
