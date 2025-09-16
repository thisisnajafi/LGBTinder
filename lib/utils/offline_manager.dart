import 'package:flutter/material.dart';
import '../services/offline_service.dart';
import '../services/connectivity_service.dart';
import '../services/sync_manager.dart';
import 'error_handler.dart';

class OfflineManager {
  static final OfflineManager _instance = OfflineManager._internal();
  factory OfflineManager() => _instance;
  OfflineManager._internal();

  final OfflineService _offlineService = OfflineService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final SyncManager _syncManager = SyncManager();

  /// Initialize offline manager
  Future<void> initialize() async {
    await _offlineService.initialize();
    _connectivityService.initialize();
    await _syncManager.initialize();
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    return await _connectivityService.isOnline();
  }

  /// Show offline indicator
  void showOfflineIndicator(BuildContext context) {
    ErrorHandler.showOfflineIndicator(context);
  }

  /// Show connection restored indicator
  void showConnectionRestoredIndicator(BuildContext context) {
    ErrorHandler.showConnectionRestoredIndicator(context);
  }

  /// Show offline status dialog
  Future<void> showOfflineStatusDialog(BuildContext context) async {
    final isOnline = await _connectivityService.isOnline();
    final stats = _connectivityService.getConnectivityStatistics();
    final syncStats = _syncManager.getSyncStatus();
    final cacheStats = _offlineService.getCacheStatistics();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isOnline ? 'Online Status' : 'Offline Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${isOnline ? 'Online' : 'Offline'}'),
            const SizedBox(height: 8),
            if (stats['last_online_time'] != null)
              Text('Last Online: ${stats['last_online_time']}'),
            if (stats['last_offline_time'] != null)
              Text('Last Offline: ${stats['last_offline_time']}'),
            const SizedBox(height: 8),
            Text('Cached Items: ${cacheStats['memory_cache_size']}'),
            Text('Queued Requests: ${cacheStats['queued_requests']}'),
            const SizedBox(height: 8),
            Text('Sync Status: ${syncStats['is_syncing'] ? 'Syncing' : 'Idle'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!isOnline)
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _syncManager.forceSyncAll();
              },
              child: const Text('Force Sync'),
            ),
        ],
      ),
    );
  }

  /// Show sync status bottom sheet
  void showSyncStatusSheet(BuildContext context) {
    final syncStats = _syncManager.getSyncStatus();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SyncStatusSheet(
        syncStats: syncStats,
        onForceSync: () async {
          Navigator.of(context).pop();
          await _syncManager.forceSyncAll();
        },
        onClearCache: () async {
          Navigator.of(context).pop();
          await _offlineService.clearAllCache();
        },
      ),
    );
  }

  /// Create offline-aware future builder
  Widget createOfflineAwareFutureBuilder<T>({
    required String cacheKey,
    required Future<T> Function() onlineFunction,
    required Widget Function(BuildContext, T) builder,
    required Widget Function(BuildContext) loadingBuilder,
    required Widget Function(BuildContext, dynamic) errorBuilder,
    Duration? cacheExpiry,
  }) {
    return FutureBuilder<T>(
      future: _getDataWithOfflineSupport(cacheKey, onlineFunction, cacheExpiry),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder(context);
        } else if (snapshot.hasError) {
          return errorBuilder(context, snapshot.error);
        } else if (snapshot.hasData) {
          return builder(context, snapshot.data!);
        } else {
          return loadingBuilder(context);
        }
      },
    );
  }

  /// Get data with offline support
  Future<T> _getDataWithOfflineSupport<T>(
    String cacheKey,
    Future<T> Function() onlineFunction,
    Duration? cacheExpiry,
  ) async {
    try {
      // Try to get cached data first
      final cachedData = await _offlineService.getCachedData<T>(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }

      // If online, fetch fresh data
      if (await _connectivityService.isOnline()) {
        final data = await onlineFunction();
        await _offlineService.cacheData(cacheKey, data, expiry: cacheExpiry);
        return data;
      } else {
        throw NetworkException('Offline: No cached data available');
      }
    } catch (e) {
      // Try to get cached data as fallback
      final cachedData = await _offlineService.getCachedData<T>(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }
      rethrow;
    }
  }

  /// Execute action with offline support
  Future<T?> executeWithOfflineSupport<T>(
    String endpoint,
    String method,
    Future<T> Function() action, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    String? cacheKey,
    Duration? cacheExpiry,
  }) async {
    try {
      if (await _connectivityService.isOnline()) {
        final result = await action();
        
        // Cache result if cache key provided
        if (cacheKey != null) {
          await _offlineService.cacheData(cacheKey, result, expiry: cacheExpiry);
        }
        
        return result;
      } else {
        // Queue request for later
        await _offlineService.queueRequest(QueuedRequest(
          method: method,
          endpoint: endpoint,
          headers: headers ?? {},
          body: body != null ? jsonEncode(body) : null,
          timestamp: DateTime.now(),
        ));
        
        throw NetworkException('Offline: Action queued for later execution');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStatistics() {
    return _offlineService.getCacheStatistics();
  }

  /// Get connectivity statistics
  Map<String, dynamic> getConnectivityStatistics() {
    return _connectivityService.getConnectivityStatistics();
  }

  /// Get sync statistics
  Map<String, dynamic> getSyncStatistics() {
    return _syncManager.getSyncStatus();
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    await _offlineService.clearAllCache();
  }

  /// Clear specific cache
  Future<void> clearCache(String key) async {
    await _offlineService.clearCache(key);
  }

  /// Force sync all data
  Future<void> forceSyncAll() async {
    await _syncManager.forceSyncAll();
  }

  /// Force sync specific task
  Future<void> forceSyncTask(String taskId) async {
    await _syncManager.forceSyncTask(taskId);
  }

  /// Register sync task
  void registerSyncTask(SyncTask task) {
    _syncManager.registerSyncTask(task);
  }

  /// Unregister sync task
  void unregisterSyncTask(String taskId) {
    _syncManager.unregisterSyncTask(taskId);
  }

  /// Listen to connectivity changes
  Stream<bool> get connectivityStream => _connectivityService.connectivityStream;

  /// Listen to sync status changes
  Stream<SyncStatus> get syncStatusStream => _syncManager.syncStatusStream;

  /// Check if device has been offline for duration
  bool hasBeenOfflineFor(Duration duration) {
    return _connectivityService.hasBeenOfflineFor(duration);
  }

  /// Check if device has been online for duration
  bool hasBeenOnlineFor(Duration duration) {
    return _connectivityService.hasBeenOnlineFor(duration);
  }

  /// Get offline duration
  Duration? getOfflineDuration() {
    return _connectivityService.getOfflineDuration();
  }

  /// Get online duration
  Duration? getOnlineDuration() {
    return _connectivityService.getOnlineDuration();
  }

  /// Wait for connectivity
  Future<void> waitForConnectivity({Duration? timeout}) async {
    await _connectivityService.waitForConnectivity(timeout: timeout);
  }

  /// Dispose of the manager
  void dispose() {
    _offlineService.dispose();
    _connectivityService.dispose();
    _syncManager.dispose();
  }
}

/// Sync status sheet widget
class SyncStatusSheet extends StatelessWidget {
  final Map<String, dynamic> syncStats;
  final VoidCallback onForceSync;
  final VoidCallback onClearCache;

  const SyncStatusSheet({
    Key? key,
    required this.syncStats,
    required this.onForceSync,
    required this.onClearCache,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sync Status',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildStatusRow('Status', syncStats['is_syncing'] ? 'Syncing' : 'Idle'),
          _buildStatusRow('Online', syncStats['is_online'] ? 'Yes' : 'No'),
          _buildStatusRow('Queued Requests', syncStats['queued_requests'].toString()),
          _buildStatusRow('Registered Tasks', syncStats['registered_tasks'].length.toString()),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onForceSync();
                },
                child: const Text('Force Sync'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onClearCache();
                },
                child: const Text('Clear Cache'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }
}
