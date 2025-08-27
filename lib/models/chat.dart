import 'package:flutter/foundation.dart';
import 'message.dart';
import 'chat_participant.dart';

class Chat {
  final String id;
  final List<ChatParticipant> participants;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime lastActivity;
  final bool isGroup;
  final String? groupName;
  final String? groupAvatar;
  final Map<String, dynamic>? metadata;
  final bool isArchived;
  final bool isPinned;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Chat({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    required this.lastActivity,
    this.isGroup = false,
    this.groupName,
    this.groupAvatar,
    this.metadata,
    this.isArchived = false,
    this.isPinned = false,
    this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => ChatParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      isGroup: json['isGroup'] as bool? ?? false,
      groupName: json['groupName'] as String?,
      groupAvatar: json['groupAvatar'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isArchived: json['isArchived'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      archivedAt: json['archivedAt'] != null
          ? DateTime.parse(json['archivedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants.map((e) => e.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'lastActivity': lastActivity.toIso8601String(),
      'isGroup': isGroup,
      'groupName': groupName,
      'groupAvatar': groupAvatar,
      'metadata': metadata,
      'isArchived': isArchived,
      'isPinned': isPinned,
      'archivedAt': archivedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Chat copyWith({
    String? id,
    List<ChatParticipant>? participants,
    Message? lastMessage,
    int? unreadCount,
    DateTime? lastActivity,
    bool? isGroup,
    String? groupName,
    String? groupAvatar,
    Map<String, dynamic>? metadata,
    bool? isArchived,
    bool? isPinned,
    DateTime? archivedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Chat(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      lastActivity: lastActivity ?? this.lastActivity,
      isGroup: isGroup ?? this.isGroup,
      groupName: groupName ?? this.groupName,
      groupAvatar: groupAvatar ?? this.groupAvatar,
      metadata: metadata ?? this.metadata,
      isArchived: isArchived ?? this.isArchived,
      isPinned: isPinned ?? this.isPinned,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  String get displayName {
    if (isGroup) {
      return groupName ?? 'Group Chat';
    }
    if (participants.isNotEmpty) {
      return participants.first.name;
    }
    return 'Unknown';
  }

  String? get displayAvatar {
    if (isGroup) {
      return groupAvatar;
    }
    if (participants.isNotEmpty) {
      return participants.first.avatar;
    }
    return null;
  }

  bool get hasUnreadMessages => unreadCount > 0;
  bool get isActive => !isArchived;
  bool get isRecent => DateTime.now().difference(lastActivity).inDays < 7;

  String get lastMessagePreview {
    if (lastMessage == null) return 'No messages yet';
    
    switch (lastMessage!.type) {
      case MessageType.text:
        return lastMessage!.content;
      case MessageType.image:
        return '📷 Image';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.audio:
      case MessageType.voice:
        return '🎵 Audio';
      case MessageType.file:
        return '📎 File';
      case MessageType.location:
        return '📍 Location';
      case MessageType.contact:
        return '👤 Contact';
      case MessageType.sticker:
        return '😀 Sticker';
      case MessageType.gif:
        return 'GIF';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

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
    return other is Chat && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Chat(id: $id, displayName: $displayName, unreadCount: $unreadCount, isGroup: $isGroup)';
  }
}
