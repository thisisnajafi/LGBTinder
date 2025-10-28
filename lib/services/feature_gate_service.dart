import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_management_service.dart';
import 'cache_service.dart';

/// Feature Gate Service
/// 
/// Manages feature access based on subscription tier
/// Tracks daily usage limits for free users
class FeatureGateService {
  static final FeatureGateService _instance = FeatureGateService._internal();
  factory FeatureGateService() => _instance;
  FeatureGateService._internal();

  static const String _baseUrl = ApiConfig.baseUrl;
  
  // Cache keys
  static const String _featurePermissionsKey = 'feature_permissions';
  static const String _usageTrackingKey = 'usage_tracking';
  
  // Daily limits for free users
  static const int freeLikesPerDay = 10;
  static const int freeRewindsPerDay = 3;
  
  Map<String, dynamic>? _cachedPermissions;
  Map<String, int>? _usageCounters;
  DateTime? _lastResetDate;

  /// Initialize feature gates
  Future<void> initialize() async {
    await _loadCachedPermissions();
    await _loadUsageCounters();
    await refreshPermissions();
  }

  /// Refresh feature permissions from backend
  Future<void> refreshPermissions() async {
    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$_baseUrl/user/permissions'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        _cachedPermissions = data['data'] as Map<String, dynamic>;
        await CacheService.setData(
          key: _featurePermissionsKey,
          value: _cachedPermissions,
          expiryMinutes: 60,
        );
        debugPrint('Feature permissions refreshed');
      }
    } catch (e) {
      debugPrint('Error refreshing permissions: $e');
    }
  }

  /// Load cached permissions
  Future<void> _loadCachedPermissions() async {
    final cached = await CacheService.getData(_featurePermissionsKey);
    if (cached != null && cached is Map<String, dynamic>) {
      _cachedPermissions = cached;
    }
  }

  /// Load usage counters
  Future<void> _loadUsageCounters() async {
    final cached = await CacheService.getData(_usageTrackingKey);
    if (cached != null && cached is Map<String, dynamic>) {
      _usageCounters = Map<String, int>.from(cached);
      
      // Check if we need to reset counters (new day)
      final lastReset = cached['last_reset'] as String?;
      if (lastReset != null) {
        _lastResetDate = DateTime.parse(lastReset);
        if (!_isSameDay(_lastResetDate!, DateTime.now())) {
          await _resetDailyCounters();
        }
      }
    } else {
      _usageCounters = {};
      await _resetDailyCounters();
    }
  }

  /// Reset daily usage counters
  Future<void> _resetDailyCounters() async {
    _usageCounters = {
      'likes': 0,
      'superlikes': 0,
      'rewinds': 0,
      'boosts': 0,
    };
    _lastResetDate = DateTime.now();
    
    await _saveUsageCounters();
    debugPrint('Daily usage counters reset');
  }

  /// Save usage counters to cache
  Future<void> _saveUsageCounters() async {
    await CacheService.setData(
      key: _usageTrackingKey,
      value: {
        ..._usageCounters!,
        'last_reset': _lastResetDate!.toIso8601String(),
      },
    );
  }

  /// Check if user has access to a feature
  bool canAccessFeature(String featureName) {
    if (_cachedPermissions == null) return false;
    return _cachedPermissions!['features']?[featureName] as bool? ?? false;
  }

  /// Check if user can perform an action (with usage tracking)
  Future<FeatureAccessResult> canPerformAction(String actionName) async {
    // Check if subscription includes unlimited access
    if (canAccessFeature('unlimited_$actionName')) {
      return FeatureAccessResult(
        allowed: true,
        reason: 'Unlimited with premium',
      );
    }

    // Check daily limit for free users
    final currentUsage = _usageCounters![actionName] ?? 0;
    int dailyLimit;

    switch (actionName) {
      case 'likes':
        dailyLimit = freeLikesPerDay;
        break;
      case 'rewinds':
        dailyLimit = freeRewindsPerDay;
        break;
      default:
        // Premium-only features
        return FeatureAccessResult(
          allowed: false,
          reason: 'Premium feature',
          requiresUpgrade: true,
        );
    }

    if (currentUsage >= dailyLimit) {
      return FeatureAccessResult(
        allowed: false,
        reason: 'Daily limit reached ($dailyLimit)',
        remainingCount: 0,
        requiresUpgrade: true,
      );
    }

    return FeatureAccessResult(
      allowed: true,
      remainingCount: dailyLimit - currentUsage,
    );
  }

  /// Track feature usage
  Future<void> trackUsage(String actionName) async {
    final token = await TokenManagementService.getAccessToken();
    if (token == null) return;

    // Increment local counter
    _usageCounters![actionName] = (_usageCounters![actionName] ?? 0) + 1;
    await _saveUsageCounters();

    // Send to backend (fire and forget)
    try {
      http.post(
        Uri.parse('$_baseUrl/usage/track'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'action': actionName,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      debugPrint('Error tracking usage: $e');
    }
  }

  /// Get remaining count for an action
  int getRemainingCount(String actionName) {
    if (canAccessFeature('unlimited_$actionName')) {
      return -1; // Unlimited
    }

    final currentUsage = _usageCounters![actionName] ?? 0;
    int dailyLimit;

    switch (actionName) {
      case 'likes':
        dailyLimit = freeLikesPerDay;
        break;
      case 'rewinds':
        dailyLimit = freeRewindsPerDay;
        break;
      default:
        return 0;
    }

    return (dailyLimit - currentUsage).clamp(0, dailyLimit);
  }

  /// Get user's subscription tier
  String getSubscriptionTier() {
    return _cachedPermissions?['tier'] as String? ?? 'free';
  }

  /// Check if user is premium
  bool isPremium() {
    final tier = getSubscriptionTier();
    return tier != 'free';
  }

  /// Get feature benefits for upgrade prompt
  List<String> getFeatureBenefits(String featureName) {
    switch (featureName) {
      case 'unlimited_likes':
        return [
          'Unlimited likes per day',
          'Like as many profiles as you want',
          'No daily restrictions',
        ];
      case 'see_who_liked':
        return [
          'See everyone who liked you',
          'Match instantly',
          'Never miss a connection',
        ];
      case 'advanced_filters':
        return [
          'Filter by education, job, height',
          'Find exactly what you\'re looking for',
          'Save time with precise matching',
        ];
      case 'unlimited_rewinds':
        return [
          'Undo unlimited swipes',
          'Never lose a potential match',
          'Take your time deciding',
        ];
      case 'boost_profile':
        return [
          'Get 10x more profile views',
          'Be the top profile in your area',
          'Boost lasts 30 minutes',
        ];
      case 'read_receipts':
        return [
          'Know when messages are read',
          'Better communication',
          'Peace of mind',
        ];
      case 'priority_likes':
        return [
          'Your likes are shown first',
          'Higher chance of matches',
          'Stand out from the crowd',
        ];
      case 'ad_free':
        return [
          'No ads or interruptions',
          'Seamless experience',
          'Focus on finding love',
        ];
      default:
        return ['Unlock premium features'];
    }
  }

  /// Check if same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

/// Feature Access Result
class FeatureAccessResult {
  final bool allowed;
  final String? reason;
  final int? remainingCount;
  final bool requiresUpgrade;

  FeatureAccessResult({
    required this.allowed,
    this.reason,
    this.remainingCount,
    this.requiresUpgrade = false,
  });
}
