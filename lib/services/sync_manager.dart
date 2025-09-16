import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/offline_service.dart';
import '../services/connectivity_service.dart';
import '../utils/error_handler.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final OfflineService _offlineService = OfflineService();
  final ConnectivityService _connectivityService = ConnectivityService();
  
  final Map<String, SyncTask> _syncTasks = {};
  final Map<String, DateTime> _lastSyncTimes = {};
  Timer? _syncTimer;
  bool _isSyncing = false;
  
  StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Initialize sync manager
  Future<void> initialize() async {
    await _loadSyncTasks();
    _startSyncTimer();
    _listenToConnectivity();
    debugPrint('SyncManager initialized');
  }

  /// Register a sync task
  void registerSyncTask(SyncTask task) {
    _syncTasks[task.id] = task;
    debugPrint('Registered sync task: ${task.id}');
  }

  /// Unregister a sync task
  void unregisterSyncTask(String taskId) {
    _syncTasks.remove(taskId);
    debugPrint('Unregistered sync task: $taskId');
  }

  /// Start sync timer
  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(Duration(minutes: 5), (timer) async {
      if (_connectivityService.isOnline && !_isSyncing) {
        await performSync();
      }
    });
  }

  /// Listen to connectivity changes
  void _listenToConnectivity() {
    _connectivityService.connectivityStream.listen((isOnline) {
      if (isOnline && !_isSyncing) {
        // Perform sync when connectivity is restored
        Future.delayed(Duration(seconds: 2), () async {
          await performSync();
        });
      }
    });
  }

  /// Perform full sync
  Future<void> performSync() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);
    
    try {
      debugPrint('Starting sync process...');
      
      // Sync queued requests first
      await _offlineService.syncQueuedRequests();
      
      // Execute all sync tasks
      final tasks = List<SyncTask>.from(_syncTasks.values);
      for (final task in tasks) {
        try {
          await _executeSyncTask(task);
        } catch (e) {
          debugPrint('Failed to sync task ${task.id}: $e');
        }
      }
      
      _syncStatusController.add(SyncStatus.completed);
      debugPrint('Sync completed successfully');
      
    } catch (e) {
      _syncStatusController.add(SyncStatus.failed);
      debugPrint('Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Execute a single sync task
  Future<void> _executeSyncTask(SyncTask task) async {
    if (!_connectivityService.isOnline) {
      debugPrint('Skipping sync task ${task.id}: offline');
      return;
    }
    
    final lastSync = _lastSyncTimes[task.id];
    if (lastSync != null && DateTime.now().difference(lastSync) < task.interval) {
      debugPrint('Skipping sync task ${task.id}: too soon');
      return;
    }
    
    try {
      debugPrint('Executing sync task: ${task.id}');
      await task.execute();
      _lastSyncTimes[task.id] = DateTime.now();
      debugPrint('Sync task ${task.id} completed');
    } catch (e) {
      debugPrint('Sync task ${task.id} failed: $e');
      rethrow;
    }
  }

  /// Force sync a specific task
  Future<void> forceSyncTask(String taskId) async {
    final task = _syncTasks[taskId];
    if (task == null) {
      throw Exception('Sync task not found: $taskId');
    }
    
    await _executeSyncTask(task);
  }

  /// Force sync all tasks
  Future<void> forceSyncAll() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);
    
    try {
      final tasks = List<SyncTask>.from(_syncTasks.values);
      for (final task in tasks) {
        await _executeSyncTask(task);
      }
      
      _syncStatusController.add(SyncStatus.completed);
    } catch (e) {
      _syncStatusController.add(SyncStatus.failed);
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  /// Get sync status
  Map<String, dynamic> getSyncStatus() {
    return {
      'is_syncing': _isSyncing,
      'is_online': _connectivityService.isOnline,
      'registered_tasks': _syncTasks.keys.toList(),
      'last_sync_times': _lastSyncTimes.map((key, value) => MapEntry(key, value.toIso8601String())),
      'queued_requests': _offlineService.getCacheStatistics()['queued_requests'],
    };
  }

  /// Get sync task status
  Map<String, dynamic> getSyncTaskStatus(String taskId) {
    final task = _syncTasks[taskId];
    if (task == null) {
      return {'error': 'Task not found'};
    }
    
    final lastSync = _lastSyncTimes[taskId];
    return {
      'id': task.id,
      'name': task.name,
      'interval_minutes': task.interval.inMinutes,
      'last_sync': lastSync?.toIso8601String(),
      'next_sync': lastSync != null 
          ? lastSync.add(task.interval).toIso8601String()
          : 'Immediate',
      'is_due': lastSync == null || DateTime.now().difference(lastSync) >= task.interval,
    };
  }

  /// Load sync tasks from storage
  Future<void> _loadSyncTasks() async {
    // This would typically load from persistent storage
    // For now, we'll just initialize with empty state
    debugPrint('Loaded sync tasks from storage');
  }

  /// Save sync tasks to storage
  Future<void> _saveSyncTasks() async {
    // This would typically save to persistent storage
    debugPrint('Saved sync tasks to storage');
  }

  /// Create a data sync task
  SyncTask createDataSyncTask({
    required String id,
    required String name,
    required String endpoint,
    required String cacheKey,
    required Duration interval,
    Map<String, dynamic>? queryParams,
  }) {
    return SyncTask(
      id: id,
      name: name,
      interval: interval,
      execute: () async {
        try {
          final response = await _offlineService.makeOfflineAwareRequest(
            'GET',
            endpoint,
            cacheResponse: true,
            cacheKey: cacheKey,
          );
          
          if (response.statusCode == 200) {
            await _offlineService.cacheData(cacheKey, response.body);
            debugPrint('Data synced for $id');
          }
        } catch (e) {
          debugPrint('Failed to sync data for $id: $e');
          rethrow;
        }
      },
    );
  }

  /// Create a user data sync task
  SyncTask createUserDataSyncTask({
    required String userId,
    required String dataType,
    required String endpoint,
    required Duration interval,
  }) {
    final id = 'user_${userId}_$dataType';
    final name = 'User $dataType Sync';
    final cacheKey = 'user_${userId}_$dataType';
    
    return createDataSyncTask(
      id: id,
      name: name,
      endpoint: endpoint,
      cacheKey: cacheKey,
      interval: interval,
    );
  }

  /// Create a chat sync task
  SyncTask createChatSyncTask({
    required String userId,
    required String chatId,
    required Duration interval,
  }) {
    final id = 'chat_${userId}_$chatId';
    final name = 'Chat Sync';
    
    return SyncTask(
      id: id,
      name: name,
      interval: interval,
      execute: () async {
        try {
          final response = await _offlineService.makeOfflineAwareRequest(
            'GET',
            'chats/$chatId/messages',
            cacheResponse: true,
            cacheKey: 'chat_messages_$chatId',
          );
          
          if (response.statusCode == 200) {
            await _offlineService.cacheData('chat_messages_$chatId', response.body);
            debugPrint('Chat synced for $chatId');
          }
        } catch (e) {
          debugPrint('Failed to sync chat $chatId: $e');
          rethrow;
        }
      },
    );
  }

  /// Create a profile sync task
  SyncTask createProfileSyncTask({
    required String userId,
    required Duration interval,
  }) {
    final id = 'profile_$userId';
    final name = 'Profile Sync';
    
    return SyncTask(
      id: id,
      name: name,
      interval: interval,
      execute: () async {
        try {
          final response = await _offlineService.makeOfflineAwareRequest(
            'GET',
            'profiles/$userId',
            cacheResponse: true,
            cacheKey: 'user_profile_$userId',
          );
          
          if (response.statusCode == 200) {
            await _offlineService.cacheData('user_profile_$userId', response.body);
            debugPrint('Profile synced for $userId');
          }
        } catch (e) {
          debugPrint('Failed to sync profile $userId: $e');
          rethrow;
        }
      },
    );
  }

  /// Dispose of the sync manager
  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
  }
}

/// Sync task model
class SyncTask {
  final String id;
  final String name;
  final Duration interval;
  final Future<void> Function() execute;

  SyncTask({
    required this.id,
    required this.name,
    required this.interval,
    required this.execute,
  });
}

/// Sync status enum
enum SyncStatus {
  idle,
  syncing,
  completed,
  failed,
}
