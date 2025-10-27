import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Feature Gate Service
/// 
/// Manages feature access based on subscription tier and usage limits:
/// - Check feature availability
/// - Track daily usage
/// - Enforce limits for free users
/// - Reset counters at midnight
class FeatureGateService {
  static final FeatureGateService _instance = FeatureGateService._internal();
  factory FeatureGateService() => _instance;
  FeatureGateService._internal();

  // Feature limits for free users
  static const int FREE_DAILY_LIKES = 10;
  static const int FREE_DAILY_SUPERLIKES = 1;
  static const int FREE_DAILY_REWINDS = 3;

  // Cache for feature permissions
  Map<String, bool> _featureCache = {};
  DateTime? _lastResetDate;

  /// Initialize service and load cached data
  Future<void> initialize() async {
    await _loadCachedData();
    await _checkAndResetDaily();
  }

  /// Check if user can access a feature
  /// 
  /// [feature] - Feature identifier
  /// [user] - Current user
  /// Returns true if user can access the feature
  Future<bool> canAccessFeature({
    required PremiumFeature feature,
    required User? user,
  }) async {
    if (user == null) return false;

    // Check subscription status
    if (_isPremiumUser(user)) {
      return true; // Premium users have access to all features
    }

    // Check feature-specific logic for free users
    switch (feature) {
      case PremiumFeature.unlimitedLikes:
        return await getRemainingLikes() > 0;
      
      case PremiumFeature.unlimitedSuperlikes:
        return await getRemainingSuperlikes() > 0;
      
      case PremiumFeature.unlimitedRewinds:
        return await getRemainingRewinds() > 0;
      
      case PremiumFeature.seeWhoLikedYou:
      case PremiumFeature.advancedFilters:
      case PremiumFeature.boostProfile:
      case PremiumFeature.readReceipts:
      case PremiumFeature.priorityLikes:
      case PremiumFeature.adFree:
      case PremiumFeature.profileInsights:
      case PremiumFeature.incognitoMode:
        return false; // Premium only features
      
      default:
        return true; // Unknown feature, allow by default
    }
  }

  /// Get remaining likes for today
  Future<int> getRemainingLikes() async {
    await _checkAndResetDaily();
    final used = await _getDailyUsage('likes');
    return (FREE_DAILY_LIKES - used).clamp(0, FREE_DAILY_LIKES);
  }

  /// Get remaining superlikes for today
  Future<int> getRemainingSuperlikes() async {
    await _checkAndResetDaily();
    final used = await _getDailyUsage('superlikes');
    return (FREE_DAILY_SUPERLIKES - used).clamp(0, FREE_DAILY_SUPERLIKES);
  }

  /// Get remaining rewinds for today
  Future<int> getRemainingRewinds() async {
    await _checkAndResetDaily();
    final used = await _getDailyUsage('rewinds');
    return (FREE_DAILY_REWINDS - used).clamp(0, FREE_DAILY_REWINDS);
  }

  /// Track a like action
  Future<bool> trackLike(User? user) async {
    if (_isPremiumUser(user)) return true; // No tracking for premium users

    await _checkAndResetDaily();
    final remaining = await getRemainingLikes();
    
    if (remaining > 0) {
      await _incrementUsage('likes');
      return true;
    }
    
    return false;
  }

  /// Track a superlike action
  Future<bool> trackSuperlike(User? user) async {
    if (_isPremiumUser(user)) return true; // No tracking for premium users

    await _checkAndResetDaily();
    final remaining = await getRemainingSuperlikes();
    
    if (remaining > 0) {
      await _incrementUsage('superlikes');
      return true;
    }
    
    return false;
  }

  /// Track a rewind action
  Future<bool> trackRewind(User? user) async {
    if (_isPremiumUser(user)) return true; // No tracking for premium users

    await _checkAndResetDaily();
    final remaining = await getRemainingRewinds();
    
    if (remaining > 0) {
      await _incrementUsage('rewinds');
      return true;
    }
    
    return false;
  }

  /// Get feature description
  String getFeatureDescription(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.unlimitedLikes:
        return 'Like as many profiles as you want without daily limits';
      case PremiumFeature.seeWhoLikedYou:
        return 'See everyone who has liked your profile instantly';
      case PremiumFeature.advancedFilters:
        return 'Use detailed filters to find your perfect match';
      case PremiumFeature.unlimitedRewinds:
        return 'Go back on any profile you accidentally passed';
      case PremiumFeature.unlimitedSuperlikes:
        return 'Send unlimited superlikes to stand out';
      case PremiumFeature.boostProfile:
        return 'Boost your profile for 10x more visibility';
      case PremiumFeature.readReceipts:
        return 'See when your messages have been read';
      case PremiumFeature.priorityLikes:
        return 'Your likes appear first to others';
      case PremiumFeature.adFree:
        return 'Enjoy an ad-free experience';
      case PremiumFeature.profileInsights:
        return 'Get detailed insights about your profile performance';
      case PremiumFeature.incognitoMode:
        return 'Browse profiles privately';
      default:
        return 'Premium feature';
    }
  }

  /// Get upgrade message for feature
  String getUpgradeMessage(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.unlimitedLikes:
        return 'You\'ve reached your daily like limit. Upgrade to Premium for unlimited likes!';
      case PremiumFeature.unlimitedSuperlikes:
        return 'You\'ve used your daily superlike. Upgrade to Premium for unlimited superlikes!';
      case PremiumFeature.unlimitedRewinds:
        return 'You\'ve used your daily rewinds. Upgrade to Premium for unlimited rewinds!';
      default:
        return 'Upgrade to Premium to unlock ${_getFeatureName(feature)}!';
    }
  }

  /// Check if user is premium
  bool _isPremiumUser(User? user) {
    if (user == null) return false;
    
    // Check subscription status
    // This would typically check user.subscription?.status == 'active'
    // For now, we'll check if user has any subscription tier
    return user.premiumStatus == 'active' || 
           user.subscriptionTier != null && user.subscriptionTier != 'free';
  }

  /// Get daily usage for a specific action
  Future<int> _getDailyUsage(String action) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'usage_$action';
    return prefs.getInt(key) ?? 0;
  }

  /// Increment usage counter
  Future<void> _incrementUsage(String action) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'usage_$action';
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
    
    debugPrint('Incremented $action usage to ${current + 1}');
  }

  /// Check and reset daily counters if needed
  Future<void> _checkAndResetDaily() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastResetDate == null || _lastResetDate!.isBefore(today)) {
      await _resetDailyCounters();
      _lastResetDate = today;
      
      // Save reset date
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_reset_date', today.toIso8601String());
      
      debugPrint('Daily usage counters reset');
    }
  }

  /// Reset all daily counters
  Future<void> _resetDailyCounters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('usage_likes', 0);
    await prefs.setInt('usage_superlikes', 0);
    await prefs.setInt('usage_rewinds', 0);
  }

  /// Load cached data
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load last reset date
      final resetDateStr = prefs.getString('last_reset_date');
      if (resetDateStr != null) {
        _lastResetDate = DateTime.parse(resetDateStr);
      }
      
      // Load feature cache
      final cacheStr = prefs.getString('feature_cache');
      if (cacheStr != null) {
        final decoded = jsonDecode(cacheStr) as Map<String, dynamic>;
        _featureCache = decoded.map((key, value) => MapEntry(key, value as bool));
      }
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  /// Save feature cache
  Future<void> _saveFeatureCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('feature_cache', jsonEncode(_featureCache));
    } catch (e) {
      debugPrint('Error saving feature cache: $e');
    }
  }

  /// Refresh feature permissions from backend
  Future<void> refreshPermissions(User user) async {
    // In a real app, this would fetch from the backend
    // For now, we'll just clear the cache
    _featureCache.clear();
    await _saveFeatureCache();
  }

  /// Clear all data (for logout)
  Future<void> clearData() async {
    _featureCache.clear();
    _lastResetDate = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usage_likes');
    await prefs.remove('usage_superlikes');
    await prefs.remove('usage_rewinds');
    await prefs.remove('last_reset_date');
    await prefs.remove('feature_cache');
  }

  /// Get feature name
  String _getFeatureName(PremiumFeature feature) {
    return feature.toString().split('.').last.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).trim();
  }
}

/// Premium Features Enum
enum PremiumFeature {
  unlimitedLikes,
  seeWhoLikedYou,
  advancedFilters,
  unlimitedRewinds,
  unlimitedSuperlikes,
  boostProfile,
  readReceipts,
  priorityLikes,
  adFree,
  profileInsights,
  incognitoMode,
}

