import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum AnalyticsEventType {
  profileView,
  profileLike,
  profileSuperLike,
  profilePass,
  profileMessage,
  profileShare,
  profileReport,
  profileBlock,
  profileUnblock,
  profileVisit,
  profileEdit,
  profilePhotoAdd,
  profilePhotoRemove,
  profileBioUpdate,
  profileInterestAdd,
  profileInterestRemove,
  profileLocationUpdate,
  profileVerificationSubmit,
  profileVerificationComplete,
  profileCustomization,
  profilePrivacyChange,
  profileVisibilityChange,
}

class AnalyticsEvent {
  final String id;
  final AnalyticsEventType type;
  final String? targetUserId;
  final String? targetProfileId;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final String? sessionId;
  final String? deviceId;
  final String? location;
  final String? source;

  const AnalyticsEvent({
    required this.id,
    required this.type,
    this.targetUserId,
    this.targetProfileId,
    this.metadata = const {},
    required this.timestamp,
    this.sessionId,
    this.deviceId,
    this.location,
    this.source,
  });

  AnalyticsEvent copyWith({
    String? id,
    AnalyticsEventType? type,
    String? targetUserId,
    String? targetProfileId,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    String? sessionId,
    String? deviceId,
    String? location,
    String? source,
  }) {
    return AnalyticsEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      targetUserId: targetUserId ?? this.targetUserId,
      targetProfileId: targetProfileId ?? this.targetProfileId,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
      deviceId: deviceId ?? this.deviceId,
      location: location ?? this.location,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'targetUserId': targetUserId,
      'targetProfileId': targetProfileId,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'sessionId': sessionId,
      'deviceId': deviceId,
      'location': location,
      'source': source,
    };
  }

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      id: json['id'],
      type: AnalyticsEventType.values.firstWhere((e) => e.name == json['type']),
      targetUserId: json['targetUserId'],
      targetProfileId: json['targetProfileId'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      timestamp: DateTime.parse(json['timestamp']),
      sessionId: json['sessionId'],
      deviceId: json['deviceId'],
      location: json['location'],
      source: json['source'],
    );
  }
}

class ProfileAnalytics {
  final String profileId;
  final int totalViews;
  final int totalLikes;
  final int totalSuperLikes;
  final int totalPasses;
  final int totalMessages;
  final int totalShares;
  final int totalReports;
  final int totalBlocks;
  final int totalVisits;
  final int totalEdits;
  final int totalPhotoAdds;
  final int totalPhotoRemoves;
  final int totalBioUpdates;
  final int totalInterestAdds;
  final int totalInterestRemoves;
  final int totalLocationUpdates;
  final int totalVerificationSubmits;
  final int totalVerificationCompletes;
  final int totalCustomizations;
  final int totalPrivacyChanges;
  final int totalVisibilityChanges;
  final DateTime lastUpdated;
  final Map<String, dynamic> metadata;

  const ProfileAnalytics({
    required this.profileId,
    required this.totalViews,
    required this.totalLikes,
    required this.totalSuperLikes,
    required this.totalPasses,
    required this.totalMessages,
    required this.totalShares,
    required this.totalReports,
    required this.totalBlocks,
    required this.totalVisits,
    required this.totalEdits,
    required this.totalPhotoAdds,
    required this.totalPhotoRemoves,
    required this.totalBioUpdates,
    required this.totalInterestAdds,
    required this.totalInterestRemoves,
    required this.totalLocationUpdates,
    required this.totalVerificationSubmits,
    required this.totalVerificationCompletes,
    required this.totalCustomizations,
    required this.totalPrivacyChanges,
    required this.totalVisibilityChanges,
    required this.lastUpdated,
    this.metadata = const {},
  });

  ProfileAnalytics copyWith({
    String? profileId,
    int? totalViews,
    int? totalLikes,
    int? totalSuperLikes,
    int? totalPasses,
    int? totalMessages,
    int? totalShares,
    int? totalReports,
    int? totalBlocks,
    int? totalVisits,
    int? totalEdits,
    int? totalPhotoAdds,
    int? totalPhotoRemoves,
    int? totalBioUpdates,
    int? totalInterestAdds,
    int? totalInterestRemoves,
    int? totalLocationUpdates,
    int? totalVerificationSubmits,
    int? totalVerificationCompletes,
    int? totalCustomizations,
    int? totalPrivacyChanges,
    int? totalVisibilityChanges,
    DateTime? lastUpdated,
    Map<String, dynamic>? metadata,
  }) {
    return ProfileAnalytics(
      profileId: profileId ?? this.profileId,
      totalViews: totalViews ?? this.totalViews,
      totalLikes: totalLikes ?? this.totalLikes,
      totalSuperLikes: totalSuperLikes ?? this.totalSuperLikes,
      totalPasses: totalPasses ?? this.totalPasses,
      totalMessages: totalMessages ?? this.totalMessages,
      totalShares: totalShares ?? this.totalShares,
      totalReports: totalReports ?? this.totalReports,
      totalBlocks: totalBlocks ?? this.totalBlocks,
      totalVisits: totalVisits ?? this.totalVisits,
      totalEdits: totalEdits ?? this.totalEdits,
      totalPhotoAdds: totalPhotoAdds ?? this.totalPhotoAdds,
      totalPhotoRemoves: totalPhotoRemoves ?? this.totalPhotoRemoves,
      totalBioUpdates: totalBioUpdates ?? this.totalBioUpdates,
      totalInterestAdds: totalInterestAdds ?? this.totalInterestAdds,
      totalInterestRemoves: totalInterestRemoves ?? this.totalInterestRemoves,
      totalLocationUpdates: totalLocationUpdates ?? this.totalLocationUpdates,
      totalVerificationSubmits: totalVerificationSubmits ?? this.totalVerificationSubmits,
      totalVerificationCompletes: totalVerificationCompletes ?? this.totalVerificationCompletes,
      totalCustomizations: totalCustomizations ?? this.totalCustomizations,
      totalPrivacyChanges: totalPrivacyChanges ?? this.totalPrivacyChanges,
      totalVisibilityChanges: totalVisibilityChanges ?? this.totalVisibilityChanges,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'totalViews': totalViews,
      'totalLikes': totalLikes,
      'totalSuperLikes': totalSuperLikes,
      'totalPasses': totalPasses,
      'totalMessages': totalMessages,
      'totalShares': totalShares,
      'totalReports': totalReports,
      'totalBlocks': totalBlocks,
      'totalVisits': totalVisits,
      'totalEdits': totalEdits,
      'totalPhotoAdds': totalPhotoAdds,
      'totalPhotoRemoves': totalPhotoRemoves,
      'totalBioUpdates': totalBioUpdates,
      'totalInterestAdds': totalInterestAdds,
      'totalInterestRemoves': totalInterestRemoves,
      'totalLocationUpdates': totalLocationUpdates,
      'totalVerificationSubmits': totalVerificationSubmits,
      'totalVerificationCompletes': totalVerificationCompletes,
      'totalCustomizations': totalCustomizations,
      'totalPrivacyChanges': totalPrivacyChanges,
      'totalVisibilityChanges': totalVisibilityChanges,
      'lastUpdated': lastUpdated.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ProfileAnalytics.fromJson(Map<String, dynamic> json) {
    return ProfileAnalytics(
      profileId: json['profileId'],
      totalViews: json['totalViews'],
      totalLikes: json['totalLikes'],
      totalSuperLikes: json['totalSuperLikes'],
      totalPasses: json['totalPasses'],
      totalMessages: json['totalMessages'],
      totalShares: json['totalShares'],
      totalReports: json['totalReports'],
      totalBlocks: json['totalBlocks'],
      totalVisits: json['totalVisits'],
      totalEdits: json['totalEdits'],
      totalPhotoAdds: json['totalPhotoAdds'],
      totalPhotoRemoves: json['totalPhotoRemoves'],
      totalBioUpdates: json['totalBioUpdates'],
      totalInterestAdds: json['totalInterestAdds'],
      totalInterestRemoves: json['totalInterestRemoves'],
      totalLocationUpdates: json['totalLocationUpdates'],
      totalVerificationSubmits: json['totalVerificationSubmits'],
      totalVerificationCompletes: json['totalVerificationCompletes'],
      totalCustomizations: json['totalCustomizations'],
      totalPrivacyChanges: json['totalPrivacyChanges'],
      totalVisibilityChanges: json['totalVisibilityChanges'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class ProfileAnalyticsService {
  static const String _analyticsEventsKey = 'profile_analytics_events';
  static const String _profileAnalyticsKey = 'profile_analytics';
  static const String _sessionIdKey = 'analytics_session_id';
  static const String _deviceIdKey = 'analytics_device_id';
  
  static ProfileAnalyticsService? _instance;
  static ProfileAnalyticsService get instance {
    _instance ??= ProfileAnalyticsService._();
    return _instance!;
  }

  ProfileAnalyticsService._();

  /// Track an analytics event
  Future<void> trackEvent({
    required AnalyticsEventType type,
    String? targetUserId,
    String? targetProfileId,
    Map<String, dynamic>? metadata,
    String? location,
    String? source,
  }) async {
    final event = AnalyticsEvent(
      id: _generateEventId(),
      type: type,
      targetUserId: targetUserId,
      targetProfileId: targetProfileId,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
      sessionId: await _getSessionId(),
      deviceId: await _getDeviceId(),
      location: location,
      source: source,
    );

    await _saveEvent(event);
    await _updateProfileAnalytics(event);
  }

  /// Get profile analytics
  Future<ProfileAnalytics> getProfileAnalytics(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final analyticsJson = prefs.getString('${_profileAnalyticsKey}_$profileId');
    
    if (analyticsJson != null) {
      try {
        final analyticsMap = json.decode(analyticsJson);
        return ProfileAnalytics.fromJson(analyticsMap);
      } catch (e) {
        return _getDefaultProfileAnalytics(profileId);
      }
    }
    
    return _getDefaultProfileAnalytics(profileId);
  }

  /// Get analytics events
  Future<List<AnalyticsEvent>> getAnalyticsEvents({
    AnalyticsEventType? type,
    String? targetUserId,
    String? targetProfileId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString(_analyticsEventsKey);
    
    if (eventsJson != null) {
      try {
        final eventsList = json.decode(eventsJson) as List;
        var events = eventsList.map((item) => AnalyticsEvent.fromJson(item)).toList();
        
        // Apply filters
        if (type != null) {
          events = events.where((e) => e.type == type).toList();
        }
        
        if (targetUserId != null) {
          events = events.where((e) => e.targetUserId == targetUserId).toList();
        }
        
        if (targetProfileId != null) {
          events = events.where((e) => e.targetProfileId == targetProfileId).toList();
        }
        
        if (startDate != null) {
          events = events.where((e) => e.timestamp.isAfter(startDate)).toList();
        }
        
        if (endDate != null) {
          events = events.where((e) => e.timestamp.isBefore(endDate)).toList();
        }
        
        // Sort by timestamp (newest first)
        events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        // Apply limit
        if (limit != null && limit > 0) {
          events = events.take(limit).toList();
        }
        
        return events;
      } catch (e) {
        return [];
      }
    }
    
    return [];
  }

  /// Get analytics summary
  Future<Map<String, dynamic>> getAnalyticsSummary(String profileId) async {
    final analytics = await getProfileAnalytics(profileId);
    final events = await getAnalyticsEvents(targetProfileId: profileId);
    
    // Calculate engagement rate
    final totalInteractions = analytics.totalLikes + analytics.totalSuperLikes + analytics.totalMessages;
    final engagementRate = analytics.totalViews > 0 
        ? (totalInteractions / analytics.totalViews) * 100 
        : 0.0;
    
    // Calculate like rate
    final likeRate = analytics.totalViews > 0 
        ? ((analytics.totalLikes + analytics.totalSuperLikes) / analytics.totalViews) * 100 
        : 0.0;
    
    // Calculate message rate
    final messageRate = analytics.totalLikes > 0 
        ? (analytics.totalMessages / analytics.totalLikes) * 100 
        : 0.0;
    
    // Calculate pass rate
    final passRate = analytics.totalViews > 0 
        ? (analytics.totalPasses / analytics.totalViews) * 100 
        : 0.0;
    
    // Get recent activity (last 7 days)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentEvents = events.where((e) => e.timestamp.isAfter(sevenDaysAgo)).toList();
    
    // Get top interaction types
    final interactionCounts = <AnalyticsEventType, int>{};
    for (final event in events) {
      interactionCounts[event.type] = (interactionCounts[event.type] ?? 0) + 1;
    }
    
    final topInteractions = interactionCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(5);
    
    return {
      'profileId': profileId,
      'totalViews': analytics.totalViews,
      'totalLikes': analytics.totalLikes,
      'totalSuperLikes': analytics.totalSuperLikes,
      'totalPasses': analytics.totalPasses,
      'totalMessages': analytics.totalMessages,
      'totalShares': analytics.totalShares,
      'totalReports': analytics.totalReports,
      'totalBlocks': analytics.totalBlocks,
      'totalVisits': analytics.totalVisits,
      'totalEdits': analytics.totalEdits,
      'engagementRate': engagementRate,
      'likeRate': likeRate,
      'messageRate': messageRate,
      'passRate': passRate,
      'recentActivity': recentEvents.length,
      'topInteractions': topInteractions.map((e) => {
        'type': e.key.name,
        'count': e.value,
      }).toList(),
      'lastUpdated': analytics.lastUpdated.toIso8601String(),
    };
  }

  /// Get analytics trends
  Future<Map<String, dynamic>> getAnalyticsTrends(String profileId, {int days = 30}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    final events = await getAnalyticsEvents(
      targetProfileId: profileId,
      startDate: startDate,
      endDate: endDate,
    );
    
    // Group events by day
    final dailyEvents = <String, List<AnalyticsEvent>>{};
    for (final event in events) {
      final dayKey = '${event.timestamp.year}-${event.timestamp.month.toString().padLeft(2, '0')}-${event.timestamp.day.toString().padLeft(2, '0')}';
      dailyEvents[dayKey] = (dailyEvents[dayKey] ?? [])..add(event);
    }
    
    // Calculate daily metrics
    final dailyMetrics = <String, Map<String, int>>{};
    for (final entry in dailyEvents.entries) {
      final dayEvents = entry.value;
      dailyMetrics[entry.key] = {
        'views': dayEvents.where((e) => e.type == AnalyticsEventType.profileView).length,
        'likes': dayEvents.where((e) => e.type == AnalyticsEventType.profileLike).length,
        'superLikes': dayEvents.where((e) => e.type == AnalyticsEventType.profileSuperLike).length,
        'passes': dayEvents.where((e) => e.type == AnalyticsEventType.profilePass).length,
        'messages': dayEvents.where((e) => e.type == AnalyticsEventType.profileMessage).length,
        'shares': dayEvents.where((e) => e.type == AnalyticsEventType.profileShare).length,
        'reports': dayEvents.where((e) => e.type == AnalyticsEventType.profileReport).length,
        'blocks': dayEvents.where((e) => e.type == AnalyticsEventType.profileBlock).length,
        'visits': dayEvents.where((e) => e.type == AnalyticsEventType.profileVisit).length,
        'edits': dayEvents.where((e) => e.type == AnalyticsEventType.profileEdit).length,
      };
    }
    
    // Calculate trends
    final totalViews = events.where((e) => e.type == AnalyticsEventType.profileView).length;
    final totalLikes = events.where((e) => e.type == AnalyticsEventType.profileLike).length;
    final totalSuperLikes = events.where((e) => e.type == AnalyticsEventType.profileSuperLike).length;
    final totalPasses = events.where((e) => e.type == AnalyticsEventType.profilePass).length;
    final totalMessages = events.where((e) => e.type == AnalyticsEventType.profileMessage).length;
    
    return {
      'period': '${days} days',
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalViews': totalViews,
      'totalLikes': totalLikes,
      'totalSuperLikes': totalSuperLikes,
      'totalPasses': totalPasses,
      'totalMessages': totalMessages,
      'dailyMetrics': dailyMetrics,
      'averageViewsPerDay': totalViews / days,
      'averageLikesPerDay': totalLikes / days,
      'averagePassesPerDay': totalPasses / days,
      'averageMessagesPerDay': totalMessages / days,
    };
  }

  /// Clear analytics data
  Future<void> clearAnalyticsData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_analyticsEventsKey);
    await prefs.remove(_profileAnalyticsKey);
  }

  /// Export analytics data
  Future<Map<String, dynamic>> exportAnalyticsData(String profileId) async {
    final analytics = await getProfileAnalytics(profileId);
    final events = await getAnalyticsEvents(targetProfileId: profileId);
    final summary = await getAnalyticsSummary(profileId);
    final trends = await getAnalyticsTrends(profileId);
    
    return {
      'profileId': profileId,
      'exportDate': DateTime.now().toIso8601String(),
      'analytics': analytics.toJson(),
      'events': events.map((e) => e.toJson()).toList(),
      'summary': summary,
      'trends': trends,
    };
  }

  /// Private helper methods
  String _generateEventId() {
    return 'event_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  Future<String> _getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString(_sessionIdKey);
    
    if (sessionId == null) {
      sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_sessionIdKey, sessionId);
    }
    
    return sessionId;
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);
    
    if (deviceId == null) {
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_deviceIdKey, deviceId);
    }
    
    return deviceId;
  }

  Future<void> _saveEvent(AnalyticsEvent event) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString(_analyticsEventsKey);
    
    List<AnalyticsEvent> events = [];
    if (eventsJson != null) {
      try {
        final eventsList = json.decode(eventsJson) as List;
        events = eventsList.map((item) => AnalyticsEvent.fromJson(item)).toList();
      } catch (e) {
        events = [];
      }
    }
    
    events.add(event);
    
    // Keep only last 1000 events to prevent storage bloat
    if (events.length > 1000) {
      events = events.skip(events.length - 1000).toList();
    }
    
    await prefs.setString(
      _analyticsEventsKey,
      json.encode(events.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _updateProfileAnalytics(AnalyticsEvent event) async {
    if (event.targetProfileId == null) return;
    
    final profileId = event.targetProfileId!;
    final analytics = await getProfileAnalytics(profileId);
    
    ProfileAnalytics updatedAnalytics = analytics;
    
    switch (event.type) {
      case AnalyticsEventType.profileView:
        updatedAnalytics = analytics.copyWith(
          totalViews: analytics.totalViews + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileLike:
        updatedAnalytics = analytics.copyWith(
          totalLikes: analytics.totalLikes + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileSuperLike:
        updatedAnalytics = analytics.copyWith(
          totalSuperLikes: analytics.totalSuperLikes + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profilePass:
        updatedAnalytics = analytics.copyWith(
          totalPasses: analytics.totalPasses + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileMessage:
        updatedAnalytics = analytics.copyWith(
          totalMessages: analytics.totalMessages + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileShare:
        updatedAnalytics = analytics.copyWith(
          totalShares: analytics.totalShares + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileReport:
        updatedAnalytics = analytics.copyWith(
          totalReports: analytics.totalReports + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileBlock:
        updatedAnalytics = analytics.copyWith(
          totalBlocks: analytics.totalBlocks + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileUnblock:
        updatedAnalytics = analytics.copyWith(
          totalBlocks: analytics.totalBlocks - 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileVisit:
        updatedAnalytics = analytics.copyWith(
          totalVisits: analytics.totalVisits + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileEdit:
        updatedAnalytics = analytics.copyWith(
          totalEdits: analytics.totalEdits + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profilePhotoAdd:
        updatedAnalytics = analytics.copyWith(
          totalPhotoAdds: analytics.totalPhotoAdds + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profilePhotoRemove:
        updatedAnalytics = analytics.copyWith(
          totalPhotoRemoves: analytics.totalPhotoRemoves + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileBioUpdate:
        updatedAnalytics = analytics.copyWith(
          totalBioUpdates: analytics.totalBioUpdates + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileInterestAdd:
        updatedAnalytics = analytics.copyWith(
          totalInterestAdds: analytics.totalInterestAdds + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileInterestRemove:
        updatedAnalytics = analytics.copyWith(
          totalInterestRemoves: analytics.totalInterestRemoves + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileLocationUpdate:
        updatedAnalytics = analytics.copyWith(
          totalLocationUpdates: analytics.totalLocationUpdates + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileVerificationSubmit:
        updatedAnalytics = analytics.copyWith(
          totalVerificationSubmits: analytics.totalVerificationSubmits + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileVerificationComplete:
        updatedAnalytics = analytics.copyWith(
          totalVerificationCompletes: analytics.totalVerificationCompletes + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileCustomization:
        updatedAnalytics = analytics.copyWith(
          totalCustomizations: analytics.totalCustomizations + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profilePrivacyChange:
        updatedAnalytics = analytics.copyWith(
          totalPrivacyChanges: analytics.totalPrivacyChanges + 1,
          lastUpdated: DateTime.now(),
        );
        break;
      case AnalyticsEventType.profileVisibilityChange:
        updatedAnalytics = analytics.copyWith(
          totalVisibilityChanges: analytics.totalVisibilityChanges + 1,
          lastUpdated: DateTime.now(),
        );
        break;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_profileAnalyticsKey}_$profileId',
      json.encode(updatedAnalytics.toJson()),
    );
  }

  ProfileAnalytics _getDefaultProfileAnalytics(String profileId) {
    return ProfileAnalytics(
      profileId: profileId,
      totalViews: 0,
      totalLikes: 0,
      totalSuperLikes: 0,
      totalPasses: 0,
      totalMessages: 0,
      totalShares: 0,
      totalReports: 0,
      totalBlocks: 0,
      totalVisits: 0,
      totalEdits: 0,
      totalPhotoAdds: 0,
      totalPhotoRemoves: 0,
      totalBioUpdates: 0,
      totalInterestAdds: 0,
      totalInterestRemoves: 0,
      totalLocationUpdates: 0,
      totalVerificationSubmits: 0,
      totalVerificationCompletes: 0,
      totalCustomizations: 0,
      totalPrivacyChanges: 0,
      totalVisibilityChanges: 0,
      lastUpdated: DateTime.now(),
    );
  }
}
