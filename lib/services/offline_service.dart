import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'cache_service.dart';
import 'error_monitoring_service.dart';

/// Service for handling offline functionality and network connectivity
class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final Connectivity _connectivity = Connectivity();
  final CacheService _cacheService = CacheService();
  
  bool _isOnline = true;
  final List<VoidCallback> _connectivityListeners = [];
  
  /// Initialize the offline service
  Future<void> initialize() async {
    // Check initial connectivity
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
    
    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      
      if (wasOnline != _isOnline) {
        _notifyConnectivityListeners();
      }
    });
  }
  
  /// Check if device is currently online
  bool get isOnline => _isOnline;
  
  /// Check if device is currently offline
  bool get isOffline => !_isOnline;
  
  /// Add a listener for connectivity changes
  void addConnectivityListener(VoidCallback listener) {
    _connectivityListeners.add(listener);
  }
  
  /// Remove a connectivity listener
  void removeConnectivityListener(VoidCallback listener) {
    _connectivityListeners.remove(listener);
  }
  
  /// Notify all connectivity listeners
  void _notifyConnectivityListeners() {
    for (final listener in _connectivityListeners) {
      try {
        listener();
      } catch (e) {
        ErrorMonitoringService.logError(
          message: e.toString(),
          context: {'operation': 'OfflineService._notifyConnectivityListeners'},
        );
      }
    }
  }
  
  /// Execute a function with offline support
  Future<T> executeWithOfflineSupport<T>({
    required String cacheKey,
    required Future<T> Function() onlineFunction,
    required T Function() offlineFunction,
    Duration? cacheExpiry,
    bool forceRefresh = false,
  }) async {
    try {
      if (_isOnline && !forceRefresh) {
        // Try to get from cache first
        final cachedData = await _cacheService.get<T>(cacheKey);
        if (cachedData != null) {
          return cachedData;
        }
        
        // Fetch from online source
        final result = await onlineFunction();
        
        // Cache the result
        await _cacheService.set(cacheKey, result, expiry: cacheExpiry);
        
        return result;
      } else {
        // Use offline function or cached data
        final cachedData = await _cacheService.get<T>(cacheKey);
        if (cachedData != null) {
          return cachedData;
        }
        
        return offlineFunction();
      }
    } catch (e) {
      // Fallback to cached data or offline function
      final cachedData = await _cacheService.get<T>(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }
      
      return offlineFunction();
    }
  }
  
  /// Queue a request for when the device comes back online
  Future<void> queueRequest({
    required String endpoint,
    required Map<String, dynamic> data,
    required String method,
    Map<String, String>? headers,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueKey = 'offline_queue';
      
      // Get existing queue
      final queueJson = prefs.getString(queueKey) ?? '[]';
      final List<dynamic> queue = json.decode(queueJson);
      
      // Add new request to queue
      queue.add({
        'endpoint': endpoint,
        'data': data,
        'method': method,
        'headers': headers ?? {},
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      // Save updated queue
      await prefs.setString(queueKey, json.encode(queue));
      
      if (kDebugMode) {
        print('📱 Queued offline request: $method $endpoint');
      }
    } catch (e) {
      ErrorMonitoringService.logError(
        message: e.toString(),
        context: {'operation': 'OfflineService.queueRequest'},
      );
    }
  }
  
  /// Process queued requests when device comes back online
  Future<void> processQueuedRequests() async {
    if (!_isOnline) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueKey = 'offline_queue';
      
      // Get queued requests
      final queueJson = prefs.getString(queueKey) ?? '[]';
      final List<dynamic> queue = json.decode(queueJson);
      
      if (queue.isEmpty) return;
      
      if (kDebugMode) {
        print('📱 Processing ${queue.length} queued requests');
      }
      
      // Process requests in order
      for (final request in queue) {
        try {
          // Here you would implement the actual HTTP request
          // For now, we'll just log it
          if (kDebugMode) {
            print('📱 Processing queued request: ${request['method']} ${request['endpoint']}');
          }
          
          // Simulate processing delay
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          ErrorMonitoringService.logError(
            message: e.toString(),
            context: 'OfflineService.processQueuedRequest',
          );
        }
      }
      
      // Clear the queue after processing
      await prefs.remove(queueKey);
      
      if (kDebugMode) {
        print('📱 Finished processing queued requests');
      }
    } catch (e) {
      ErrorMonitoringService.logError(
        message: e.toString(),
        context: 'OfflineService.processQueuedRequests',
      );
    }
  }
  
  /// Get offline data for a specific key
  Future<T?> getOfflineData<T>(String key) async {
    try {
      return await _cacheService.get<T>(key);
    } catch (e) {
      ErrorMonitoringService.logError(
        message: e.toString(),
        context: 'OfflineService.getOfflineData',
      );
      return null;
    }
  }
  
  /// Set offline data for a specific key
  Future<void> setOfflineData<T>(String key, T data, {Duration? expiry}) async {
    try {
      await _cacheService.set(key, data, expiry: expiry);
    } catch (e) {
      ErrorMonitoringService.logError(
        message: e.toString(),
        context: 'OfflineService.setOfflineData',
      );
    }
  }
  
  /// Clear all offline data
  Future<void> clearOfflineData() async {
    try {
      await _cacheService.clear();
      
      // Also clear queued requests
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('offline_queue');
    } catch (e) {
      ErrorMonitoringService.logError(
        message: e.toString(),
        context: 'OfflineService.clearOfflineData',
      );
    }
  }
  
  /// Get network status information
  Future<NetworkStatus> getNetworkStatus() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      
      switch (connectivityResult) {
        case ConnectivityResult.wifi:
          return NetworkStatus.wifi;
        case ConnectivityResult.mobile:
          return NetworkStatus.mobile;
        case ConnectivityResult.ethernet:
          return NetworkStatus.ethernet;
        case ConnectivityResult.none:
          return NetworkStatus.offline;
        default:
          return NetworkStatus.unknown;
      }
    } catch (e) {
      ErrorMonitoringService.logError(
        message: e.toString(),
        context: 'OfflineService.getNetworkStatus',
      );
      return NetworkStatus.unknown;
    }
  }
  
  /// Check if a specific endpoint is reachable
  Future<bool> isEndpointReachable(String endpoint) async {
    if (!_isOnline) return false;
    
    try {
      final uri = Uri.parse(endpoint);
      final result = await InternetAddress.lookup(uri.host);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// Network status enumeration
enum NetworkStatus {
  wifi,
  mobile,
  ethernet,
  offline,
  unknown,
}

/// Extension for NetworkStatus
extension NetworkStatusExtension on NetworkStatus {
  String get displayName {
    switch (this) {
      case NetworkStatus.wifi:
        return 'Wi-Fi';
      case NetworkStatus.mobile:
        return 'Mobile Data';
      case NetworkStatus.ethernet:
        return 'Ethernet';
      case NetworkStatus.offline:
        return 'Offline';
      case NetworkStatus.unknown:
        return 'Unknown';
    }
  }
  
  bool get isOnline {
    return this != NetworkStatus.offline && this != NetworkStatus.unknown;
  }
}