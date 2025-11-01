import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../auth_service.dart';

/// Group Notifications API Service
/// 
/// Manages notification settings for group chats
/// - Mute/unmute group notifications
/// - Set notification preferences (all, mentions only, none)
/// - Configure notification sound and vibration
/// - Manage notification schedules (Do Not Disturb)
class GroupNotificationsApiService {
  /// Get notification settings for a specific group
  /// 
  /// GET /api/chat/groups/{groupId}/notifications
  Future<GroupNotificationSettings?> getGroupNotificationSettings(
    String groupId,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/chat/groups/$groupId/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GroupNotificationSettings.fromJson(data['data']);
      } else {
        throw Exception('Failed to fetch notification settings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching group notification settings: $e');
      return null;
    }
  }

  /// Update notification settings for a group
  /// 
  /// PUT /api/chat/groups/{groupId}/notifications
  Future<bool> updateGroupNotificationSettings({
    required String groupId,
    required GroupNotificationSettings settings,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/chat/groups/$groupId/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(settings.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update notification settings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating group notification settings: $e');
      return false;
    }
  }

  /// Mute group notifications
  /// 
  /// POST /api/chat/groups/{groupId}/mute
  Future<bool> muteGroup({
    required String groupId,
    Duration? duration,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final body = <String, dynamic>{};
      if (duration != null) {
        body['mute_until'] = DateTime.now()
            .add(duration)
            .toIso8601String();
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chat/groups/$groupId/mute'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error muting group: $e');
      return false;
    }
  }

  /// Unmute group notifications
  /// 
  /// POST /api/chat/groups/{groupId}/unmute
  Future<bool> unmuteGroup(String groupId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chat/groups/$groupId/unmute'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error unmuting group: $e');
      return false;
    }
  }

  /// Get all muted groups
  /// 
  /// GET /api/chat/groups/muted
  Future<List<String>> getMutedGroups() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/chat/groups/muted'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to fetch muted groups: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching muted groups: $e');
      return [];
    }
  }

  /// Set custom notification sound for a group
  /// 
  /// PUT /api/chat/groups/{groupId}/notification-sound
  Future<bool> setNotificationSound({
    required String groupId,
    required String soundId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/chat/groups/$groupId/notification-sound'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'sound_id': soundId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error setting notification sound: $e');
      return false;
    }
  }
}

/// Group Notification Settings Model
class GroupNotificationSettings {
  final String groupId;
  final NotificationPreference preference;
  final bool isMuted;
  final DateTime? mutedUntil;
  final bool showPreviews;
  final bool vibrate;
  final String? notificationSound;
  final bool mentionOnly;
  final bool priorityOnly;

  GroupNotificationSettings({
    required this.groupId,
    this.preference = NotificationPreference.all,
    this.isMuted = false,
    this.mutedUntil,
    this.showPreviews = true,
    this.vibrate = true,
    this.notificationSound,
    this.mentionOnly = false,
    this.priorityOnly = false,
  });

  factory GroupNotificationSettings.fromJson(Map<String, dynamic> json) {
    return GroupNotificationSettings(
      groupId: json['group_id'] as String,
      preference: NotificationPreference.values.firstWhere(
        (e) => e.toString().split('.').last == (json['preference'] as String? ?? 'all'),
        orElse: () => NotificationPreference.all,
      ),
      isMuted: json['is_muted'] as bool? ?? false,
      mutedUntil: json['muted_until'] != null
          ? DateTime.parse(json['muted_until'] as String)
          : null,
      showPreviews: json['show_previews'] as bool? ?? true,
      vibrate: json['vibrate'] as bool? ?? true,
      notificationSound: json['notification_sound'] as String?,
      mentionOnly: json['mention_only'] as bool? ?? false,
      priorityOnly: json['priority_only'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'preference': preference.toString().split('.').last,
      'is_muted': isMuted,
      'muted_until': mutedUntil?.toIso8601String(),
      'show_previews': showPreviews,
      'vibrate': vibrate,
      'notification_sound': notificationSound,
      'mention_only': mentionOnly,
      'priority_only': priorityOnly,
    };
  }

  GroupNotificationSettings copyWith({
    String? groupId,
    NotificationPreference? preference,
    bool? isMuted,
    DateTime? mutedUntil,
    bool? showPreviews,
    bool? vibrate,
    String? notificationSound,
    bool? mentionOnly,
    bool? priorityOnly,
  }) {
    return GroupNotificationSettings(
      groupId: groupId ?? this.groupId,
      preference: preference ?? this.preference,
      isMuted: isMuted ?? this.isMuted,
      mutedUntil: mutedUntil ?? this.mutedUntil,
      showPreviews: showPreviews ?? this.showPreviews,
      vibrate: vibrate ?? this.vibrate,
      notificationSound: notificationSound ?? this.notificationSound,
      mentionOnly: mentionOnly ?? this.mentionOnly,
      priorityOnly: priorityOnly ?? this.priorityOnly,
    );
  }

  bool get isTemporarilyMuted {
    if (!isMuted) return false;
    if (mutedUntil == null) return true; // Permanently muted
    return DateTime.now().isBefore(mutedUntil!);
  }

  String get muteStatusText {
    if (!isMuted) return 'Notifications on';
    if (mutedUntil == null) return 'Muted forever';
    
    final now = DateTime.now();
    if (now.isAfter(mutedUntil!)) return 'Notifications on';
    
    final difference = mutedUntil!.difference(now);
    if (difference.inMinutes < 60) {
      return 'Muted for ${difference.inMinutes} minutes';
    } else if (difference.inHours < 24) {
      return 'Muted for ${difference.inHours} hours';
    } else {
      return 'Muted for ${difference.inDays} days';
    }
  }
}

/// Notification Preference Enum
enum NotificationPreference {
  all,         // All messages
  mentionsOnly, // Only when mentioned
  none,        // No notifications
}

