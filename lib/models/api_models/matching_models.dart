import 'dart:convert';

/// Matching & Likes API Models
/// 
/// This file contains all data models for matching and likes endpoints
/// including liking users, getting matches, and related functionality.

// ============================================================================
// LIKE MODELS
// ============================================================================

/// Request model for liking a user
class LikeUserRequest {
  final int targetUserId;

  const LikeUserRequest({
    required this.targetUserId,
  });

  factory LikeUserRequest.fromJson(Map<String, dynamic> json) {
    return LikeUserRequest(
      targetUserId: json['target_user_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'target_user_id': targetUserId,
    };
  }
}

/// Like data model
class LikeData {
  final int likeId;
  final int targetUserId;
  final String status;
  final bool isMatch;
  final int? matchId;
  final String createdAt;

  const LikeData({
    required this.likeId,
    required this.targetUserId,
    required this.status,
    required this.isMatch,
    this.matchId,
    required this.createdAt,
  });

  factory LikeData.fromJson(Map<String, dynamic> json) {
    return LikeData(
      likeId: json['like_id'] as int,
      targetUserId: json['target_user_id'] as int,
      status: json['status'] as String,
      isMatch: json['is_match'] as bool,
      matchId: json['match_id'] as int?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'like_id': likeId,
      'target_user_id': targetUserId,
      'status': status,
      'is_match': isMatch,
      if (matchId != null) 'match_id': matchId,
      'created_at': createdAt,
    };
  }
}

/// Like user response model
class LikeUserResponse {
  final bool status;
  final String message;
  final LikeData? data;

  const LikeUserResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory LikeUserResponse.fromJson(Map<String, dynamic> json) {
    return LikeUserResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'] != null 
          ? LikeData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': data!.toJson(),
    };
  }
}

// ============================================================================
// MATCH MODELS
// ============================================================================

/// Match user data model
class MatchUser {
  final int id;
  final String name;
  final int age;
  final String? avatarUrl;
  final String profileBio;
  final String city;

  const MatchUser({
    required this.id,
    required this.name,
    required this.age,
    this.avatarUrl,
    required this.profileBio,
    required this.city,
  });

  factory MatchUser.fromJson(Map<String, dynamic> json) {
    return MatchUser(
      id: json['id'] as int,
      name: json['name'] as String,
      age: json['age'] as int,
      avatarUrl: json['avatar_url'] as String?,
      profileBio: json['profile_bio'] as String,
      city: json['city'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'profile_bio': profileBio,
      'city': city,
    };
  }
}

/// Match last message data model
class MatchLastMessage {
  final int id;
  final String message;
  final String sentAt;
  final bool isRead;

  const MatchLastMessage({
    required this.id,
    required this.message,
    required this.sentAt,
    required this.isRead,
  });

  factory MatchLastMessage.fromJson(Map<String, dynamic> json) {
    return MatchLastMessage(
      id: json['id'] as int,
      message: json['message'] as String,
      sentAt: json['sent_at'] as String,
      isRead: json['is_read'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'sent_at': sentAt,
      'is_read': isRead,
    };
  }
}

/// Match data model
class MatchData {
  final int matchId;
  final MatchUser user;
  final String matchedAt;
  final MatchLastMessage? lastMessage;

  const MatchData({
    required this.matchId,
    required this.user,
    required this.matchedAt,
    this.lastMessage,
  });

  factory MatchData.fromJson(Map<String, dynamic> json) {
    return MatchData(
      matchId: json['match_id'] as int,
      user: MatchUser.fromJson(json['user'] as Map<String, dynamic>),
      matchedAt: json['matched_at'] as String,
      lastMessage: json['last_message'] != null
          ? MatchLastMessage.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'match_id': matchId,
      'user': user.toJson(),
      'matched_at': matchedAt,
      if (lastMessage != null) 'last_message': lastMessage!.toJson(),
    };
  }
}

/// Get matches response model
class GetMatchesResponse {
  final bool status;
  final List<MatchData> data;

  const GetMatchesResponse({
    required this.status,
    required this.data,
  });

  factory GetMatchesResponse.fromJson(Map<String, dynamic> json) {
    return GetMatchesResponse(
      status: json['status'] as bool,
      data: (json['data'] as List).map((item) => MatchData.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((match) => match.toJson()).toList(),
    };
  }
}

// ============================================================================
// MATCHING UTILITIES
// ============================================================================

/// Like status enumeration
enum LikeStatus {
  pending,
  matched,
  rejected,
}

/// Match status enumeration
enum MatchStatus {
  active,
  blocked,
  unmatched,
}

/// Like status extension
extension LikeStatusExtension on LikeStatus {
  String get value {
    switch (this) {
      case LikeStatus.pending:
        return 'pending';
      case LikeStatus.matched:
        return 'matched';
      case LikeStatus.rejected:
        return 'rejected';
    }
  }

  static LikeStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return LikeStatus.pending;
      case 'matched':
        return LikeStatus.matched;
      case 'rejected':
        return LikeStatus.rejected;
      default:
        return LikeStatus.pending;
    }
  }
}

/// Match status extension
extension MatchStatusExtension on MatchStatus {
  String get value {
    switch (this) {
      case MatchStatus.active:
        return 'active';
      case MatchStatus.blocked:
        return 'blocked';
      case MatchStatus.unmatched:
        return 'unmatched';
    }
  }

  static MatchStatus fromString(String value) {
    switch (value) {
      case 'active':
        return MatchStatus.active;
      case 'blocked':
        return MatchStatus.blocked;
      case 'unmatched':
        return MatchStatus.unmatched;
      default:
        return MatchStatus.active;
    }
  }
}

// ============================================================================
// MATCHING HELPER METHODS
// ============================================================================

/// Matching helper class
class MatchingHelper {
  /// Check if like resulted in a match
  static bool isMatch(LikeData likeData) {
    return likeData.isMatch && likeData.status == 'matched';
  }

  /// Check if like is pending
  static bool isLikePending(LikeData likeData) {
    return likeData.status == 'pending' && !likeData.isMatch;
  }

  /// Get match date from like data
  static DateTime? getMatchDate(LikeData likeData) {
    if (isMatch(likeData)) {
      return DateTime.parse(likeData.createdAt);
    }
    return null;
  }

  /// Get time since match
  static Duration getTimeSinceMatch(MatchData matchData) {
    final matchDate = DateTime.parse(matchData.matchedAt);
    return DateTime.now().difference(matchDate);
  }

  /// Get time since last message
  static Duration? getTimeSinceLastMessage(MatchData matchData) {
    if (matchData.lastMessage != null) {
      final messageDate = DateTime.parse(matchData.lastMessage!.sentAt);
      return DateTime.now().difference(messageDate);
    }
    return null;
  }

  /// Check if match has unread messages
  static bool hasUnreadMessages(MatchData matchData) {
    return matchData.lastMessage != null && !matchData.lastMessage!.isRead;
  }

  /// Get match display name
  static String getMatchDisplayName(MatchData matchData) {
    return matchData.user.name;
  }

  /// Get match location
  static String getMatchLocation(MatchData matchData) {
    return matchData.user.city;
  }

  /// Get match age
  static int getMatchAge(MatchData matchData) {
    return matchData.user.age;
  }

  /// Get match bio
  static String getMatchBio(MatchData matchData) {
    return matchData.user.profileBio;
  }

  /// Get match avatar URL
  static String? getMatchAvatarUrl(MatchData matchData) {
    return matchData.user.avatarUrl;
  }

  /// Format time since match
  static String formatTimeSinceMatch(MatchData matchData) {
    final duration = getTimeSinceMatch(matchData);
    
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'} ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'} ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Format time since last message
  static String formatTimeSinceLastMessage(MatchData matchData) {
    final duration = getTimeSinceLastMessage(matchData);
    
    if (duration == null) {
      return 'No messages';
    }
    
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'} ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'} ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
