import 'package:flutter/foundation.dart';
import '../services/offline_service.dart';

/// Provider for managing network connectivity state
class ConnectivityProvider extends ChangeNotifier {
  final OfflineService _offlineService = OfflineService();
  
  bool _isOnline = true;
  NetworkStatus _networkStatus = NetworkStatus.unknown;
  bool _isInitialized = false;
  
  /// Whether the device is currently online
  bool get isOnline => _isOnline;
  
  /// Whether the device is currently offline
  bool get isOffline => !_isOnline;
  
  /// Current network status
  NetworkStatus get networkStatus => _networkStatus;
  
  /// Whether the provider has been initialized
  bool get isInitialized => _isInitialized;
  
  /// Initialize the connectivity provider
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize offline service
      await _offlineService.initialize();
      
      // Get initial status
      _networkStatus = await _offlineService.getNetworkStatus();
      _isOnline = _networkStatus.isOnline;
      
      // Listen for connectivity changes
      _offlineService.addConnectivityListener(_onConnectivityChanged);
      
      _isInitialized = true;
      notifyListeners();
      
      if (kDebugMode) {
        print('📱 ConnectivityProvider initialized - Online: $_isOnline, Status: ${_networkStatus.displayName}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize ConnectivityProvider: $e');
      }
    }
  }
  
  /// Handle connectivity changes
  void _onConnectivityChanged() {
    _updateConnectivityStatus();
  }
  
  /// Update connectivity status
  Future<void> _updateConnectivityStatus() async {
    try {
      final newStatus = await _offlineService.getNetworkStatus();
      final newIsOnline = newStatus.isOnline;
      
      if (_networkStatus != newStatus || _isOnline != newIsOnline) {
        _networkStatus = newStatus;
        _isOnline = newIsOnline;
        
        if (kDebugMode) {
          print('📱 Connectivity changed - Online: $_isOnline, Status: ${_networkStatus.displayName}');
        }
        
        notifyListeners();
        
        // Process queued requests when coming back online
        if (_isOnline) {
          await _offlineService.processQueuedRequests();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to update connectivity status: $e');
      }
    }
  }
  
  /// Check if a specific endpoint is reachable
  Future<bool> isEndpointReachable(String endpoint) async {
    try {
      return await _offlineService.isEndpointReachable(endpoint);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to check endpoint reachability: $e');
      }
      return false;
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
      return await _offlineService.executeWithOfflineSupport(
        cacheKey: cacheKey,
        onlineFunction: onlineFunction,
        offlineFunction: offlineFunction,
        cacheExpiry: cacheExpiry,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to execute with offline support: $e');
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
      await _offlineService.queueRequest(
        endpoint: endpoint,
        data: data,
        method: method,
        headers: headers,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to queue request: $e');
      }
    }
  }
  
  /// Get offline data for a specific key
  Future<T?> getOfflineData<T>(String key) async {
    try {
      return await _offlineService.getOfflineData<T>(key);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get offline data: $e');
      }
      return null;
    }
  }
  
  /// Set offline data for a specific key
  Future<void> setOfflineData<T>(String key, T data, {Duration? expiry}) async {
    try {
      await _offlineService.setOfflineData(key, data, expiry: expiry);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to set offline data: $e');
      }
    }
  }
  
  /// Clear all offline data
  Future<void> clearOfflineData() async {
    try {
      await _offlineService.clearOfflineData();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to clear offline data: $e');
      }
    }
  }
  
  /// Force refresh connectivity status
  Future<void> refreshStatus() async {
    await _updateConnectivityStatus();
  }
  
  @override
  void dispose() {
    _offlineService.removeConnectivityListener(_onConnectivityChanged);
    super.dispose();
  }
}
