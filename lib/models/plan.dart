import 'package:flutter/foundation.dart';

class Plan {
  final int id;
  final String title;
  final String description;
  final PlanFeatures features;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Plan({
    required this.id,
    required this.title,
    required this.description,
    required this.features,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      features: PlanFeatures.fromJson(json['features'] as Map<String, dynamic>),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'features': features.toJson(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Plan copyWith({
    int? id,
    String? title,
    String? description,
    PlanFeatures? features,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Plan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      features: features ?? this.features,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Plan &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.features == features &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, description, features, status);
  }

  @override
  String toString() {
    return 'Plan(id: $id, title: $title, status: $status)';
  }
}

class PlanFeatures {
  final int dailyProfileViews;
  final int superlikeLimit;
  final int unlimitedRewinds;
  final int profileBoost;
  final bool readReceipts;
  final bool seeAllLikes;
  final bool travelMode;
  final bool incognitoMode;
  final bool priorityMatching;
  final bool advancedFilters;
  final bool aiMatchSuggestions;
  final bool profileInsights;
  final bool vipSupport;
  final bool exclusiveEvents;

  const PlanFeatures({
    required this.dailyProfileViews,
    required this.superlikeLimit,
    required this.unlimitedRewinds,
    required this.profileBoost,
    required this.readReceipts,
    required this.seeAllLikes,
    required this.travelMode,
    required this.incognitoMode,
    required this.priorityMatching,
    required this.advancedFilters,
    required this.aiMatchSuggestions,
    required this.profileInsights,
    required this.vipSupport,
    required this.exclusiveEvents,
  });

  factory PlanFeatures.fromJson(Map<String, dynamic> json) {
    return PlanFeatures(
      dailyProfileViews: json['daily_profile_views'] as int? ?? 0,
      superlikeLimit: json['superlike_limit'] as int? ?? 0,
      unlimitedRewinds: json['unlimited_rewinds'] as int? ?? 0,
      profileBoost: json['profile_boost'] as int? ?? 0,
      readReceipts: json['read_receipts'] as bool? ?? false,
      seeAllLikes: json['see_all_likes'] as bool? ?? false,
      travelMode: json['travel_mode'] as bool? ?? false,
      incognitoMode: json['incognito_mode'] as bool? ?? false,
      priorityMatching: json['priority_matching'] as bool? ?? false,
      advancedFilters: json['advanced_filters'] as bool? ?? false,
      aiMatchSuggestions: json['ai_match_suggestions'] as bool? ?? false,
      profileInsights: json['profile_insights'] as bool? ?? false,
      vipSupport: json['vip_support'] as bool? ?? false,
      exclusiveEvents: json['exclusive_events'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_profile_views': dailyProfileViews,
      'superlike_limit': superlikeLimit,
      'unlimited_rewinds': unlimitedRewinds,
      'profile_boost': profileBoost,
      'read_receipts': readReceipts,
      'see_all_likes': seeAllLikes,
      'travel_mode': travelMode,
      'incognito_mode': incognitoMode,
      'priority_matching': priorityMatching,
      'advanced_filters': advancedFilters,
      'ai_match_suggestions': aiMatchSuggestions,
      'profile_insights': profileInsights,
      'vip_support': vipSupport,
      'exclusive_events': exclusiveEvents,
    };
  }

  PlanFeatures copyWith({
    int? dailyProfileViews,
    int? superlikeLimit,
    int? unlimitedRewinds,
    int? profileBoost,
    bool? readReceipts,
    bool? seeAllLikes,
    bool? travelMode,
    bool? incognitoMode,
    bool? priorityMatching,
    bool? advancedFilters,
    bool? aiMatchSuggestions,
    bool? profileInsights,
    bool? vipSupport,
    bool? exclusiveEvents,
  }) {
    return PlanFeatures(
      dailyProfileViews: dailyProfileViews ?? this.dailyProfileViews,
      superlikeLimit: superlikeLimit ?? this.superlikeLimit,
      unlimitedRewinds: unlimitedRewinds ?? this.unlimitedRewinds,
      profileBoost: profileBoost ?? this.profileBoost,
      readReceipts: readReceipts ?? this.readReceipts,
      seeAllLikes: seeAllLikes ?? this.seeAllLikes,
      travelMode: travelMode ?? this.travelMode,
      incognitoMode: incognitoMode ?? this.incognitoMode,
      priorityMatching: priorityMatching ?? this.priorityMatching,
      advancedFilters: advancedFilters ?? this.advancedFilters,
      aiMatchSuggestions: aiMatchSuggestions ?? this.aiMatchSuggestions,
      profileInsights: profileInsights ?? this.profileInsights,
      vipSupport: vipSupport ?? this.vipSupport,
      exclusiveEvents: exclusiveEvents ?? this.exclusiveEvents,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlanFeatures &&
        other.dailyProfileViews == dailyProfileViews &&
        other.superlikeLimit == superlikeLimit &&
        other.unlimitedRewinds == unlimitedRewinds &&
        other.profileBoost == profileBoost &&
        other.readReceipts == readReceipts &&
        other.seeAllLikes == seeAllLikes &&
        other.travelMode == travelMode &&
        other.incognitoMode == incognitoMode &&
        other.priorityMatching == priorityMatching &&
        other.advancedFilters == advancedFilters &&
        other.aiMatchSuggestions == aiMatchSuggestions &&
        other.profileInsights == profileInsights &&
        other.vipSupport == vipSupport &&
        other.exclusiveEvents == exclusiveEvents;
  }

  @override
  int get hashCode {
    return Object.hash(
      dailyProfileViews,
      superlikeLimit,
      unlimitedRewinds,
      profileBoost,
      readReceipts,
      seeAllLikes,
      travelMode,
      incognitoMode,
      priorityMatching,
      advancedFilters,
      aiMatchSuggestions,
      profileInsights,
      vipSupport,
      exclusiveEvents,
    );
  }

  @override
  String toString() {
    return 'PlanFeatures(dailyProfileViews: $dailyProfileViews, superlikeLimit: $superlikeLimit)';
  }
}
