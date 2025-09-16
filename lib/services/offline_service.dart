import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';
import 'package:flutter/foundation.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  SharedPreferences? _prefs;
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, Duration> _cacheExpiry = {};
  final List<QueuedRequest> _requestQueue = [];
  bool _isOnline = true;
  Timer? _syncTimer;

  // Cache expiry durations
  static const Map<String, Duration> _defaultCacheExpiry = {
    'user_profile': Duration(hours: 1),
    'matches': Duration(minutes: 30),
    'chat_messages': Duration(minutes: 15),
    'stories': Duration(minutes: 30),
    'feeds': Duration(minutes: 20),
    'notifications': Duration(minutes: 10),
    'reference_data': Duration(hours: 24),
    'settings': Duration(hours: 12),
    'analytics': Duration(minutes: 5),
  };

  /// Initialize the offline service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadCachedData();
    await _loadQueuedRequests();
    _startSyncTimer();
    debugPrint('OfflineService initialized');
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      return _isOnline;
    } catch (e) {
      _isOnline = false;
      return false;
    }
  }

  /// Cache data with automatic expiry
  Future<void> cacheData(String key, dynamic data, {Duration? expiry}) async {
    try {
      final expiryDuration = expiry ?? _defaultCacheExpiry[key] ?? Duration(hours: 1);
      final expiryTime = DateTime.now().add(expiryDuration);
      
      // Store in memory cache
      _memoryCache[key] = data;
      _cacheTimestamps[key] = DateTime.now();
      _cacheExpiry[key] = expiryDuration;
      
      // Store in persistent storage
      if (_prefs != null) {
        await _prefs!.setString('cache_$key', jsonEncode(data));
        await _prefs!.setString('cache_timestamp_$key', expiryTime.toIso8601String());
      }
      
      debugPrint('Cached data for key: $key');
    } catch (e) {
      debugPrint('Failed to cache data for key $key: $e');
    }
  }

  /// Get cached data
  Future<T?> getCachedData<T>(String key) async {
    try {
      // Check memory cache first
      if (_memoryCache.containsKey(key)) {
        final timestamp = _cacheTimestamps[key];
        final expiry = _cacheExpiry[key];
        
        if (timestamp != null && expiry != null) {
          if (DateTime.now().isBefore(timestamp.add(expiry))) {
            return _memoryCache[key] as T?;
          } else {
            // Expired, remove from cache
            _memoryCache.remove(key);
            _cacheTimestamps.remove(key);
            _cacheExpiry.remove(key);
          }
        }
      }
      
      // Check persistent storage
      if (_prefs != null) {
        final cachedData = _prefs!.getString('cache_$key');
        final timestampStr = _prefs!.getString('cache_timestamp_$key');
        
        if (cachedData != null && timestampStr != null) {
          final timestamp = DateTime.parse(timestampStr);
          if (DateTime.now().isBefore(timestamp)) {
            final data = jsonDecode(cachedData) as T;
            // Restore to memory cache
            _memoryCache[key] = data;
            _cacheTimestamps[key] = timestamp;
            return data;
          } else {
            // Expired, remove from storage
            await _prefs!.remove('cache_$key');
            await _prefs!.remove('cache_timestamp_$key');
          }
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to get cached data for key $key: $e');
      return null;
    }
  }

  /// Queue a request for later execution when online
  Future<void> queueRequest(QueuedRequest request) async {
    _requestQueue.add(request);
    await _saveQueuedRequests();
    debugPrint('Queued request: ${request.method} ${request.endpoint}');
  }

  /// Execute queued requests when online
  Future<void> syncQueuedRequests() async {
    if (!await isOnline() || _requestQueue.isEmpty) {
      return;
    }
    
    debugPrint('Syncing ${_requestQueue.length} queued requests');
    
    final requestsToProcess = List<QueuedRequest>.from(_requestQueue);
    _requestQueue.clear();
    
    for (final request in requestsToProcess) {
      try {
        await _executeQueuedRequest(request);
      } catch (e) {
        debugPrint('Failed to execute queued request: $e');
        // Re-queue failed requests
        _requestQueue.add(request);
      }
    }
    
    await _saveQueuedRequests();
  }

  /// Execute a single queued request
  Future<void> _executeQueuedRequest(QueuedRequest request) async {
    final uri = Uri.parse(ApiConfig.getUrl(request.endpoint));
    
    http.Response response;
    switch (request.method.toLowerCase()) {
      case 'get':
        response = await http.get(uri, headers: request.headers);
        break;
      case 'post':
        response = await http.post(
          uri,
          headers: request.headers,
          body: request.body,
        );
        break;
      case 'put':
        response = await http.put(
          uri,
          headers: request.headers,
          body: request.body,
        );
        break;
      case 'delete':
        response = await http.delete(uri, headers: request.headers);
        break;
      case 'patch':
        response = await http.patch(
          uri,
          headers: request.headers,
          body: request.body,
        );
        break;
      default:
        throw Exception('Unsupported HTTP method: ${request.method}');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint('Successfully executed queued request: ${request.method} ${request.endpoint}');
    } else {
      throw Exception('Request failed with status ${response.statusCode}');
    }
  }

  /// Make a request with offline support
  Future<http.Response> makeOfflineAwareRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool cacheResponse = false,
    String? cacheKey,
    Duration? cacheExpiry,
  }) async {
    try {
      // Try to make the request
      final response = await _makeHttpRequest(method, endpoint, headers: headers, body: body);
      
      // Cache response if requested
      if (cacheResponse && response.statusCode == 200) {
        final key = cacheKey ?? endpoint;
        await cacheData(key, response.body, expiry: cacheExpiry);
      }
      
      return response;
    } catch (e) {
      // If offline, try to get cached data
      if (!await isOnline()) {
        final cachedData = await getCachedData<String>(cacheKey ?? endpoint);
        if (cachedData != null) {
          // Return cached response
          return http.Response(cachedData, 200);
        }
        
        // Queue the request for later
        await queueRequest(QueuedRequest(
          method: method,
          endpoint: endpoint,
          headers: headers ?? {},
          body: body != null ? jsonEncode(body) : null,
          timestamp: DateTime.now(),
        ));
        
        throw NetworkException('Offline: Request queued for later execution');
      }
      
      rethrow;
    }
  }

  /// Make HTTP request
  Future<http.Response> _makeHttpRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(ApiConfig.getUrl(endpoint));
    final requestHeaders = headers ?? {};
    requestHeaders['Accept'] = 'application/json';
    
    switch (method.toLowerCase()) {
      case 'get':
        return await http.get(uri, headers: requestHeaders);
      case 'post':
        return await http.post(
          uri,
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'put':
        return await http.put(
          uri,
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'delete':
        return await http.delete(uri, headers: requestHeaders);
      case 'patch':
        return await http.patch(
          uri,
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  /// Clear cache for a specific key
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

  /// Clear all cached data
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
    
    debugPrint('Cleared all cached data');
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStatistics() {
    final stats = <String, dynamic>{
      'memory_cache_size': _memoryCache.length,
      'queued_requests': _requestQueue.length,
      'is_online': _isOnline,
    };
    
    final cacheInfo = <String, dynamic>{};
    for (final key in _memoryCache.keys) {
      final timestamp = _cacheTimestamps[key];
      final expiry = _cacheExpiry[key];
      
      cacheInfo[key] = {
        'cached_at': timestamp?.toIso8601String(),
        'expires_at': timestamp?.add(expiry ?? Duration.zero).toIso8601String(),
        'is_expired': timestamp != null && expiry != null 
            ? DateTime.now().isAfter(timestamp.add(expiry))
            : false,
      };
    }
    
    stats['cache_info'] = cacheInfo;
    return stats;
  }

  /// Start sync timer
  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(Duration(minutes: 5), (timer) async {
      await syncQueuedRequests();
    });
  }

  /// Load cached data from storage
  Future<void> _loadCachedData() async {
    if (_prefs == null) return;
    
    final keys = _prefs!.getKeys();
    for (final key in keys) {
      if (key.startsWith('cache_') && !key.contains('timestamp')) {
        final cacheKey = key.substring(6); // Remove 'cache_' prefix
        final cachedData = _prefs!.getString(key);
        final timestampStr = _prefs!.getString('cache_timestamp_$cacheKey');
        
        if (cachedData != null && timestampStr != null) {
          final timestamp = DateTime.parse(timestampStr);
          if (DateTime.now().isBefore(timestamp)) {
            _memoryCache[cacheKey] = jsonDecode(cachedData);
            _cacheTimestamps[cacheKey] = timestamp;
          } else {
            // Remove expired data
            await _prefs!.remove(key);
            await _prefs!.remove('cache_timestamp_$cacheKey');
          }
        }
      }
    }
  }

  /// Load queued requests from storage
  Future<void> _loadQueuedRequests() async {
    if (_prefs == null) return;
    
    final queuedRequestsStr = _prefs!.getString('queued_requests');
    if (queuedRequestsStr != null) {
      try {
        final List<dynamic> requestsJson = jsonDecode(queuedRequestsStr);
        _requestQueue.clear();
        for (final requestJson in requestsJson) {
          _requestQueue.add(QueuedRequest.fromJson(requestJson));
        }
      } catch (e) {
        debugPrint('Failed to load queued requests: $e');
      }
    }
  }

  /// Save queued requests to storage
  Future<void> _saveQueuedRequests() async {
    if (_prefs == null) return;
    
    try {
      final requestsJson = _requestQueue.map((request) => request.toJson()).toList();
      await _prefs!.setString('queued_requests', jsonEncode(requestsJson));
    } catch (e) {
      debugPrint('Failed to save queued requests: $e');
    }
  }

  /// Store data securely
  Future<void> storeSecureData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Get data securely
  Future<String?> getSecureData(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// Delete secure data
  Future<void> deleteSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Clear all secure data
  Future<void> clearAllSecureData() async {
    await _secureStorage.deleteAll();
  }

  /// Store file locally
  Future<String> storeFileLocally(String fileName, List<int> data) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(data);
    return file.path;
  }

  /// Get local file path
  Future<String?> getLocalFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    return file.existsSync() ? file.path : null;
  }

  /// Delete local file
  Future<void> deleteLocalFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// Get local storage size
  Future<int> getLocalStorageSize() async {
    final directory = await getApplicationDocumentsDirectory();
    int totalSize = 0;
    
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    
    return totalSize;
  }

  /// Dispose of the service
  void dispose() {
    _syncTimer?.cancel();
    _memoryCache.clear();
    _cacheTimestamps.clear();
    _cacheExpiry.clear();
    _requestQueue.clear();
  }
}

/// Queued request model
class QueuedRequest {
  final String method;
  final String endpoint;
  final Map<String, String> headers;
  final String? body;
  final DateTime timestamp;

  QueuedRequest({
    required this.method,
    required this.endpoint,
    required this.headers,
    this.body,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'endpoint': endpoint,
      'headers': headers,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory QueuedRequest.fromJson(Map<String, dynamic> json) {
    return QueuedRequest(
      method: json['method'],
      endpoint: json['endpoint'],
      headers: Map<String, String>.from(json['headers']),
      body: json['body'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
