import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class RequestCacheService {
  static final RequestCacheService _instance = RequestCacheService._internal();
  factory RequestCacheService() => _instance;
  RequestCacheService._internal();

  SharedPreferences? _prefs;
  final Map<String, CacheEntry> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, Duration> _cacheExpiry = {};
  
  // Cache configuration
  static const Duration _defaultCacheExpiry = Duration(minutes: 5);
  static const int _maxMemoryCacheSize = 100;
  static const int _maxCacheSize = 1024 * 1024; // 1MB

  /// Initialize cache service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadCache();
    debugPrint('RequestCacheService initialized');
  }

  /// Cache HTTP response
  Future<void> cacheResponse(
    String key,
    http.Response response, {
    Duration? expiry,
  }) async {
    try {
      final expiryDuration = expiry ?? _defaultCacheExpiry;
      final expiryTime = DateTime.now().add(expiryDuration);
      
      final entry = CacheEntry(
        key: key,
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        timestamp: DateTime.now(),
        expiry: expiryTime,
      );
      
      // Store in memory cache
      _memoryCache[key] = entry;
      _cacheTimestamps[key] = DateTime.now();
      _cacheExpiry[key] = expiryDuration;
      
      // Store in persistent storage
      if (_prefs != null) {
        await _prefs!.setString('cache_$key', jsonEncode(entry.toJson()));
        await _prefs!.setString('cache_timestamp_$key', expiryTime.toIso8601String());
      }
      
      debugPrint('Cached response for key: $key');
    } catch (e) {
      debugPrint('Failed to cache response for key $key: $e');
    }
  }

  /// Get cached response
  Future<http.Response?> getCachedResponse(String key) async {
    try {
      // Check memory cache first
      if (_memoryCache.containsKey(key)) {
        final entry = _memoryCache[key]!;
        if (DateTime.now().isBefore(entry.expiry)) {
          return _createResponseFromEntry(entry);
        } else {
          // Expired, remove from cache
          _memoryCache.remove(key);
          _cacheTimestamps.remove(key);
          _cacheExpiry.remove(key);
        }
      }
      
      // Check persistent storage
      if (_prefs != null) {
        final cachedData = _prefs!.getString('cache_$key');
        final timestampStr = _prefs!.getString('cache_timestamp_$key');
        
        if (cachedData != null && timestampStr != null) {
          final expiryTime = DateTime.parse(timestampStr);
          if (DateTime.now().isBefore(expiryTime)) {
            final entry = CacheEntry.fromJson(jsonDecode(cachedData));
            // Restore to memory cache
            _memoryCache[key] = entry;
            _cacheTimestamps[key] = entry.timestamp;
            return _createResponseFromEntry(entry);
          } else {
            // Expired, remove from storage
            await _prefs!.remove('cache_$key');
            await _prefs!.remove('cache_timestamp_$key');
          }
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to get cached response for key $key: $e');
      return null;
    }
  }

  /// Create HTTP response from cache entry
  http.Response _createResponseFromEntry(CacheEntry entry) {
    return http.Response(
      entry.body,
      entry.statusCode,
      headers: entry.headers,
    );
  }

  /// Generate cache key from request
  String generateCacheKey(String method, String endpoint, {Map<String, dynamic>? queryParams, Map<String, String>? headers}) {
    final keyParts = <String>[
      method.toUpperCase(),
      endpoint,
    ];
    
    if (queryParams != null && queryParams.isNotEmpty) {
      final sortedParams = Map.fromEntries(
        queryParams.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
      keyParts.add(jsonEncode(sortedParams));
    }
    
    if (headers != null && headers.isNotEmpty) {
      final sortedHeaders = Map.fromEntries(
        headers.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
      keyParts.add(jsonEncode(sortedHeaders));
    }
    
    return keyParts.join('|');
  }

  /// Check if response should be cached
  bool shouldCacheResponse(http.Response response, String endpoint) {
    // Don't cache error responses
    if (response.statusCode >= 400) return false;
    
    // Don't cache certain endpoints
    final noCacheEndpoints = [
      '/auth/login',
      '/auth/logout',
      '/auth/register',
      '/auth/refresh-token',
    ];
    
    if (noCacheEndpoints.any((e) => endpoint.contains(e))) return false;
    
    // Don't cache if response is too large
    if (response.body.length > _maxCacheSize) return false;
    
    // Don't cache if cache-control header says no-cache
    final cacheControl = response.headers['cache-control'];
    if (cacheControl != null && cacheControl.contains('no-cache')) return false;
    
    return true;
  }

  /// Get cache expiry for endpoint
  Duration getCacheExpiryForEndpoint(String endpoint) {
    // Different expiry times for different endpoints
    if (endpoint.contains('/profiles/')) {
      return Duration(minutes: 10); // Profile data changes less frequently
    } else if (endpoint.contains('/matches/')) {
      return Duration(minutes: 2); // Match data changes frequently
    } else if (endpoint.contains('/messages/')) {
      return Duration(minutes: 1); // Messages change very frequently
    } else if (endpoint.contains('/reference-data/')) {
      return Duration(hours: 1); // Reference data rarely changes
    } else if (endpoint.contains('/settings/')) {
      return Duration(minutes: 5); // Settings change occasionally
    } else {
      return _defaultCacheExpiry;
    }
  }

  /// Clear cache for specific key
  Future<void> clearCache(String key) async {
    _memoryCache.remove(key);
    _cacheTimestamps.remove(key);
    _cacheExpiry.remove(key);
    
    if (_prefs != null) {
      await _prefs!.remove('cache_$key');
      await _prefs!.remove('cache_timestamp_$key');
    }
    
    debugPrint('Cleared cache for key: $key');
  }

  /// Clear cache for endpoint pattern
  Future<void> clearCacheForEndpoint(String endpointPattern) async {
    final keysToRemove = <String>[];
    
    // Check memory cache
    for (final key in _memoryCache.keys) {
      if (key.contains(endpointPattern)) {
        keysToRemove.add(key);
      }
    }
    
    // Remove from memory cache
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
      _cacheExpiry.remove(key);
    }
    
    // Remove from persistent storage
    if (_prefs != null) {
      final allKeys = _prefs!.getKeys();
      for (final key in allKeys) {
        if (key.startsWith('cache_') && key.contains(endpointPattern)) {
          await _prefs!.remove(key);
          await _prefs!.remove('cache_timestamp_${key.substring(6)}');
        }
      }
    }
    
    debugPrint('Cleared cache for endpoint pattern: $endpointPattern');
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    _cacheExpiry.clear();
    
    if (_prefs != null) {
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          await _prefs!.remove(key);
        }
      }
    }
    
    debugPrint('Cleared all cache');
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStatistics() {
    final stats = <String, dynamic>{
      'memory_cache_size': _memoryCache.length,
      'memory_cache_keys': _memoryCache.keys.toList(),
      'total_cache_size': _memoryCache.values.fold(0, (sum, entry) => sum + entry.body.length),
    };
    
    final cacheInfo = <String, dynamic>{};
    for (final key in _memoryCache.keys) {
      final entry = _memoryCache[key]!;
      final timestamp = _cacheTimestamps[key];
      final expiry = _cacheExpiry[key];
      
      cacheInfo[key] = {
        'cached_at': timestamp?.toIso8601String(),
        'expires_at': entry.expiry.toIso8601String(),
        'is_expired': DateTime.now().isAfter(entry.expiry),
        'size': entry.body.length,
        'status_code': entry.statusCode,
      };
    }
    
    stats['cache_info'] = cacheInfo;
    return stats;
  }

  /// Clean expired cache entries
  Future<void> cleanExpiredCache() async {
    final expiredKeys = <String>[];
    
    // Check memory cache
    for (final key in _memoryCache.keys) {
      final entry = _memoryCache[key]!;
      if (DateTime.now().isAfter(entry.expiry)) {
        expiredKeys.add(key);
      }
    }
    
    // Remove expired entries from memory cache
    for (final key in expiredKeys) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
      _cacheExpiry.remove(key);
    }
    
    // Check persistent storage
    if (_prefs != null) {
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.startsWith('cache_') && !key.contains('timestamp')) {
          final cacheKey = key.substring(6);
          final timestampStr = _prefs!.getString('cache_timestamp_$cacheKey');
          
          if (timestampStr != null) {
            final expiryTime = DateTime.parse(timestampStr);
            if (DateTime.now().isAfter(expiryTime)) {
              await _prefs!.remove(key);
              await _prefs!.remove('cache_timestamp_$cacheKey');
            }
          }
        }
      }
    }
    
    debugPrint('Cleaned ${expiredKeys.length} expired cache entries');
  }

  /// Load cache from storage
  Future<void> _loadCache() async {
    if (_prefs == null) return;
    
    try {
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.startsWith('cache_') && !key.contains('timestamp')) {
          final cacheKey = key.substring(6);
          final cachedData = _prefs!.getString(key);
          final timestampStr = _prefs!.getString('cache_timestamp_$cacheKey');
          
          if (cachedData != null && timestampStr != null) {
            final expiryTime = DateTime.parse(timestampStr);
            if (DateTime.now().isBefore(expiryTime)) {
              final entry = CacheEntry.fromJson(jsonDecode(cachedData));
              _memoryCache[cacheKey] = entry;
              _cacheTimestamps[cacheKey] = entry.timestamp;
            } else {
              // Remove expired data
              await _prefs!.remove(key);
              await _prefs!.remove('cache_timestamp_$cacheKey');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load cache: $e');
    }
  }

  /// Dispose cache service
  void dispose() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    _cacheExpiry.clear();
    debugPrint('RequestCacheService disposed');
  }
}

/// Cache entry
class CacheEntry {
  final String key;
  final int statusCode;
  final Map<String, String> headers;
  final String body;
  final DateTime timestamp;
  final DateTime expiry;

  CacheEntry({
    required this.key,
    required this.statusCode,
    required this.headers,
    required this.body,
    required this.timestamp,
    required this.expiry,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'status_code': statusCode,
      'headers': headers,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'expiry': expiry.toIso8601String(),
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      key: json['key'],
      statusCode: json['status_code'],
      headers: Map<String, String>.from(json['headers']),
      body: json['body'],
      timestamp: DateTime.parse(json['timestamp']),
      expiry: DateTime.parse(json['expiry']),
    );
  }
}
