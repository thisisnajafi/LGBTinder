import 'package:flutter/foundation.dart';

class ChatParticipant {
  final String userId;
  final String name;
  final String? avatar;
  final bool isOnline;
  final DateTime? lastSeen;
  final bool isTyping;
  final DateTime? typingStartedAt;
  final String? role; // For group chats: admin, member, etc.
  final DateTime joinedAt;
  final bool isMuted;
  final DateTime? mutedUntil;

  const ChatParticipant({
    required this.userId,
    required this.name,
    this.avatar,
    this.isOnline = false,
    this.lastSeen,
    this.isTyping = false,
    this.typingStartedAt,
    this.role,
    required this.joinedAt,
    this.isMuted = false,
    this.mutedUntil,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      userId: json['userId'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
      isTyping: json['isTyping'] as bool? ?? false,
      typingStartedAt: json['typingStartedAt'] != null
          ? DateTime.parse(json['typingStartedAt'] as String)
          : null,
      role: json['role'] as String?,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isMuted: json['isMuted'] as bool? ?? false,
      mutedUntil: json['mutedUntil'] != null
          ? DateTime.parse(json['mutedUntil'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'avatar': avatar,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'isTyping': isTyping,
      'typingStartedAt': typingStartedAt?.toIso8601String(),
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
      'isMuted': isMuted,
      'mutedUntil': mutedUntil?.toIso8601String(),
    };
  }

  ChatParticipant copyWith({
    String? userId,
    String? name,
    String? avatar,
    bool? isOnline,
    DateTime? lastSeen,
    bool? isTyping,
    DateTime? typingStartedAt,
    String? role,
    DateTime? joinedAt,
    bool? isMuted,
    DateTime? mutedUntil,
  }) {
    return ChatParticipant(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      isTyping: isTyping ?? this.isTyping,
      typingStartedAt: typingStartedAt ?? this.typingStartedAt,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      isMuted: isMuted ?? this.isMuted,
      mutedUntil: mutedUntil ?? this.mutedUntil,
    );
  }

  // Helper methods
  String get statusText {
    if (isOnline) return 'Online';
    if (lastSeen != null) {
      final now = DateTime.now();
      final difference = now.difference(lastSeen!);
      
      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inHours < 1) return '${difference.inMinutes}m ago';
      if (difference.inDays < 1) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return 'Last seen ${lastSeen!.day}/${lastSeen!.month}/${lastSeen!.year}';
    }
    return 'Offline';
  }

  bool get isCurrentlyTyping => isTyping && typingStartedAt != null;
  bool get isCurrentlyMuted => isMuted && (mutedUntil == null || mutedUntil!.isAfter(DateTime.now()));
  bool get isAdmin => role == 'admin';
  bool get isModerator => role == 'moderator';

  String get displayName {
    if (isCurrentlyTyping) return '$name (typing...)';
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatParticipant && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'ChatParticipant(userId: $userId, name: $name, isOnline: $isOnline)';
  }
}
