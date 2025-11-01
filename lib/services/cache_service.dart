import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class CacheService {
  static const String _cachePrefix = 'lgbtinder_cache_';
  static const String _cacheTimestampPrefix = 'lgbtinder_timestamp_';
  static const String _cacheVersionPrefix = 'lgbtinder_version_';
  
  // Cache durations
  static const Duration _referenceDataCacheDuration = Duration(hours: 24);
  static const Duration _userProfileCacheDuration = Duration(minutes: 30);
  static const Duration _matchesCacheDuration = Duration(minutes: 15);
  static const Duration _chatHistoryCacheDuration = Duration(minutes: 5);
  static const Duration _countriesCacheDuration = Duration(days: 7);
  static const Duration _citiesCacheDuration = Duration(days: 1);
  
  // Cache version for invalidation
  static const String _cacheVersion = '1.0.0';

  // Generic get method for compatibility
  static Future<T?> get<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_cacheTimestampPrefix$key';
      final versionKey = '$_cacheVersionPrefix$key';

      // Check if cache exists
      if (!prefs.containsKey(cacheKey)) {
        return null;
      }

      // Check cache version
      final cachedVersion = prefs.getString(versionKey);
      if (cachedVersion != _cacheVersion) {
        await _clearCacheForKey(key);
        return null;
      }

      // Check cache expiration
      final timestamp = prefs.getInt(timestampKey);
      if (timestamp == null) {
        await _clearCacheForKey(key);
        return null;
      }

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      // Default to 1 hour expiration for generic cache
      if (now.difference(cacheTime) > Duration(hours: 1)) {
        await _clearCacheForKey(key);
        return null;
      }

      // Get cached data
      final cachedDataString = prefs.getString(cacheKey);
      if (cachedDataString == null) {
        await _clearCacheForKey(key);
        return null;
      }

      final cachedData = json.decode(cachedDataString);
      return cachedData as T?;
    } catch (e) {
      debugPrint('Cache get error for key $key: $e');
      return null;
    }
  }

  // Generic set method for compatibility
  static Future<void> set(String key, dynamic data, {Duration? expiry}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_cacheTimestampPrefix$key';
      final versionKey = '$_cacheVersionPrefix$key';

      final dataString = json.encode(data);
      final now = DateTime.now().millisecondsSinceEpoch;

      await prefs.setString(cacheKey, dataString);
      await prefs.setInt(timestampKey, now);
      await prefs.setString(versionKey, _cacheVersion);
    } catch (e) {
      debugPrint('Cache set error for key $key: $e');
    }
  }

  // Alias methods for compatibility
  static Future<T?> getData<T>(String key) async {
    return await get<T>(key);
  }

  static Future<void> setData(String key, dynamic data, {Duration? expiry}) async {
    return await set(key, data, expiry: expiry);
  }

  static Future<void> removeData(String key) async {
    return await _clearCacheForKey(key);
  }

  // Generic clear method for compatibility
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_cachePrefix) || 
            key.startsWith(_cacheTimestampPrefix) || 
            key.startsWith(_cacheVersionPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('Cache clear error: $e');
    }
  }

  // Get cached data
  static Future<T?> getCachedData<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_cacheTimestampPrefix$key';
      final versionKey = '$_cacheVersionPrefix$key';

      // Check if cache exists
      if (!prefs.containsKey(cacheKey)) {
        return null;
      }

      // Check cache version
      final cachedVersion = prefs.getString(versionKey);
      if (cachedVersion != _cacheVersion) {
        await _clearCacheForKey(key);
        return null;
      }

      // Check cache expiration
      final timestamp = prefs.getInt(timestampKey);
      if (timestamp == null) {
        await _clearCacheForKey(key);
        return null;
      }

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final cacheDuration = _getCacheDuration(key);

      if (now.difference(cacheTime) > cacheDuration) {
        await _clearCacheForKey(key);
        return null;
      }

      // Get cached data
      final cachedData = prefs.getString(cacheKey);
      if (cachedData == null) {
        return null;
      }

      final jsonData = jsonDecode(cachedData) as Map<String, dynamic>;
      return fromJson(jsonData);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cached data for key $key: $e');
      }
      return null;
    }
  }

  // Set cached data
  static Future<void> setCachedData<T>(String key, T data, Map<String, dynamic> Function(T) toJson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_cacheTimestampPrefix$key';
      final versionKey = '$_cacheVersionPrefix$key';

      final jsonData = toJson(data);
      final jsonString = jsonEncode(jsonData);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await prefs.setString(cacheKey, jsonString);
      await prefs.setInt(timestampKey, timestamp);
      await prefs.setString(versionKey, _cacheVersion);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting cached data for key $key: $e');
      }
    }
  }

  // Get cached list data
  static Future<List<T>?> getCachedListData<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_cacheTimestampPrefix$key';
      final versionKey = '$_cacheVersionPrefix$key';

      // Check if cache exists
      if (!prefs.containsKey(cacheKey)) {
        return null;
      }

      // Check cache version
      final cachedVersion = prefs.getString(versionKey);
      if (cachedVersion != _cacheVersion) {
        await _clearCacheForKey(key);
        return null;
      }

      // Check cache expiration
      final timestamp = prefs.getInt(timestampKey);
      if (timestamp == null) {
        await _clearCacheForKey(key);
        return null;
      }

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final cacheDuration = _getCacheDuration(key);

      if (now.difference(cacheTime) > cacheDuration) {
        await _clearCacheForKey(key);
        return null;
      }

      // Get cached data
      final cachedData = prefs.getString(cacheKey);
      if (cachedData == null) {
        return null;
      }

      final jsonData = jsonDecode(cachedData) as List<dynamic>;
      return jsonData.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cached list data for key $key: $e');
      }
      return null;
    }
  }

  // Set cached list data
  static Future<void> setCachedListData<T>(String key, List<T> data, Map<String, dynamic> Function(T) toJson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_cacheTimestampPrefix$key';
      final versionKey = '$_cacheVersionPrefix$key';

      final jsonData = data.map((item) => toJson(item)).toList();
      final jsonString = jsonEncode(jsonData);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await prefs.setString(cacheKey, jsonString);
      await prefs.setInt(timestampKey, timestamp);
      await prefs.setString(versionKey, _cacheVersion);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting cached list data for key $key: $e');
      }
    }
  }

  // Clear cache for specific key
  static Future<void> _clearCacheForKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_cacheTimestampPrefix$key';
      final versionKey = '$_cacheVersionPrefix$key';

      await prefs.remove(cacheKey);
      await prefs.remove(timestampKey);
      await prefs.remove(versionKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cache for key $key: $e');
      }
    }
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (String key in keys) {
        if (key.startsWith(_cachePrefix) || 
            key.startsWith(_cacheTimestampPrefix) || 
            key.startsWith(_cacheVersionPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all cache: $e');
      }
    }
  }

  // Clear cache by pattern
  static Future<void> clearCacheByPattern(String pattern) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (String key in keys) {
        if (key.contains(pattern)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cache by pattern $pattern: $e');
      }
    }
  }

  // Get cache duration for specific key
  static Duration _getCacheDuration(String key) {
    if (key.contains('countries')) {
      return _countriesCacheDuration;
    } else if (key.contains('cities')) {
      return _citiesCacheDuration;
    } else if (key.contains('genders') || 
               key.contains('jobs') || 
               key.contains('education') || 
               key.contains('interests') || 
               key.contains('languages') || 
               key.contains('music_genres') || 
               key.contains('relation_goals') || 
               key.contains('preferred_genders')) {
      return _referenceDataCacheDuration;
    } else if (key.contains('user_profile')) {
      return _userProfileCacheDuration;
    } else if (key.contains('matches')) {
      return _matchesCacheDuration;
    } else if (key.contains('chat_history')) {
      return _chatHistoryCacheDuration;
    } else {
      return Duration(minutes: 15); // Default cache duration
    }
  }

  // Check if cache is valid
  static Future<bool> isCacheValid(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampKey = '$_cacheTimestampPrefix$key';
      final versionKey = '$_cacheVersionPrefix$key';

      // Check if cache exists
      if (!prefs.containsKey(timestampKey)) {
        return false;
      }

      // Check cache version
      final cachedVersion = prefs.getString(versionKey);
      if (cachedVersion != _cacheVersion) {
        return false;
      }

      // Check cache expiration
      final timestamp = prefs.getInt(timestampKey);
      if (timestamp == null) {
        return false;
      }

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final cacheDuration = _getCacheDuration(key);

      return now.difference(cacheTime) <= cacheDuration;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking cache validity for key $key: $e');
      }
      return false;
    }
  }

  // Get cache size
  static Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int size = 0;
      
      for (String key in keys) {
        if (key.startsWith(_cachePrefix)) {
          final value = prefs.getString(key);
          if (value != null) {
            size += value.length;
          }
        }
      }
      
      return size;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cache size: $e');
      }
      return 0;
    }
  }

  // Get cache info
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((key) => key.startsWith(_cachePrefix)).toList();
      
      Map<String, dynamic> info = {
        'totalKeys': cacheKeys.length,
        'size': await getCacheSize(),
        'version': _cacheVersion,
        'keys': cacheKeys.map((key) => key.replaceFirst(_cachePrefix, '')).toList(),
      };
      
      return info;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cache info: $e');
      }
      return {};
    }
  }

  // Preload cache with data
  static Future<void> preloadCache<T>(String key, T data, Map<String, dynamic> Function(T) toJson) async {
    await setCachedData(key, data, toJson);
  }

  // Preload cache with list data
  static Future<void> preloadListCache<T>(String key, List<T> data, Map<String, dynamic> Function(T) toJson) async {
    await setCachedListData(key, data, toJson);
  }

  // Invalidate cache for specific key
  static Future<void> invalidateCache(String key) async {
    await _clearCacheForKey(key);
  }

  // Invalidate cache by pattern
  static Future<void> invalidateCacheByPattern(String pattern) async {
    await clearCacheByPattern(pattern);
  }

  // Update cache version (forces all cache to be invalidated)
  static Future<void> updateCacheVersion(String newVersion) async {
    // This would typically be called when the app version changes
    // For now, we'll just clear all cache
    await clearAllCache();
  }
}
