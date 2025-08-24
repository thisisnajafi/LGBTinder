class UserSettings {
  final int id;
  final int userId;
  final bool showAdultContent;
  final String profileVisibility; // 'public', 'matches_only', 'friends_only'
  final bool showOnlineStatus;
  final bool showLastSeen;
  final bool newMatchesNotification;
  final bool newMessagesNotification;
  final bool likesNotification;
  final bool superlikesNotification;
  final bool storiesFromMatchesNotification;
  final bool feedUpdatesNotification;
  final bool safetyAlertsNotification;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettings({
    required this.id,
    required this.userId,
    this.showAdultContent = false,
    this.profileVisibility = 'public',
    this.showOnlineStatus = true,
    this.showLastSeen = true,
    this.newMatchesNotification = true,
    this.newMessagesNotification = true,
    this.likesNotification = true,
    this.superlikesNotification = true,
    this.storiesFromMatchesNotification = true,
    this.feedUpdatesNotification = true,
    this.safetyAlertsNotification = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'],
      userId: json['user_id'],
      showAdultContent: json['show_adult_content'] ?? false,
      profileVisibility: json['profile_visibility'] ?? 'public',
      showOnlineStatus: json['show_online_status'] ?? true,
      showLastSeen: json['show_last_seen'] ?? true,
      newMatchesNotification: json['new_matches_notification'] ?? true,
      newMessagesNotification: json['new_messages_notification'] ?? true,
      likesNotification: json['likes_notification'] ?? true,
      superlikesNotification: json['superlikes_notification'] ?? true,
      storiesFromMatchesNotification: json['stories_from_matches_notification'] ?? true,
      feedUpdatesNotification: json['feed_updates_notification'] ?? true,
      safetyAlertsNotification: json['safety_alerts_notification'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'show_adult_content': showAdultContent,
      'profile_visibility': profileVisibility,
      'show_online_status': showOnlineStatus,
      'show_last_seen': showLastSeen,
      'new_matches_notification': newMatchesNotification,
      'new_messages_notification': newMessagesNotification,
      'likes_notification': likesNotification,
      'superlikes_notification': superlikesNotification,
      'stories_from_matches_notification': storiesFromMatchesNotification,
      'feed_updates_notification': feedUpdatesNotification,
      'safety_alerts_notification': safetyAlertsNotification,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  UserSettings copyWith({
    int? id,
    int? userId,
    bool? showAdultContent,
    String? profileVisibility,
    bool? showOnlineStatus,
    bool? showLastSeen,
    bool? newMatchesNotification,
    bool? newMessagesNotification,
    bool? likesNotification,
    bool? superlikesNotification,
    bool? storiesFromMatchesNotification,
    bool? feedUpdatesNotification,
    bool? safetyAlertsNotification,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      showAdultContent: showAdultContent ?? this.showAdultContent,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      showLastSeen: showLastSeen ?? this.showLastSeen,
      newMatchesNotification: newMatchesNotification ?? this.newMatchesNotification,
      newMessagesNotification: newMessagesNotification ?? this.newMessagesNotification,
      likesNotification: likesNotification ?? this.likesNotification,
      superlikesNotification: superlikesNotification ?? this.superlikesNotification,
      storiesFromMatchesNotification: storiesFromMatchesNotification ?? this.storiesFromMatchesNotification,
      feedUpdatesNotification: feedUpdatesNotification ?? this.feedUpdatesNotification,
      safetyAlertsNotification: safetyAlertsNotification ?? this.safetyAlertsNotification,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get profile visibility as display text
  String get profileVisibilityText {
    switch (profileVisibility) {
      case 'public': return 'Public (everyone can see)';
      case 'matches_only': return 'Matches Only';
      case 'friends_only': return 'Friends Only';
      default: return 'Public';
    }
  }

  // Get online status text
  String get onlineStatusText => showOnlineStatus ? 'Show when online' : 'Hide online status';

  // Get last seen text
  String get lastSeenText => showLastSeen ? 'Show last seen' : 'Hide last seen';

  @override
  String toString() {
    return 'UserSettings(id: $id, userId: $userId, visibility: $profileVisibility)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettings && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
