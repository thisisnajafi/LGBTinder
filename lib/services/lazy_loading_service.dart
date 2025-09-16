import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LazyLoadingService {
  static final LazyLoadingService _instance = LazyLoadingService._internal();
  factory LazyLoadingService() => _instance;
  LazyLoadingService._internal();

  SharedPreferences? _prefs;
  final Map<String, LazyLoadingState> _loadingStates = {};
  final Map<String, List<dynamic>> _loadedData = {};
  final Map<String, DateTime> _loadTimestamps = {};
  
  // Lazy loading configuration
  static const int _defaultBatchSize = 10;
  static const int _maxBatchSize = 50;
  static const int _minBatchSize = 5;
  static const Duration _defaultLoadDelay = Duration(milliseconds: 300);
  static const Duration _cacheExpiry = Duration(minutes: 15);

  /// Initialize lazy loading service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadLoadingStates();
    debugPrint('LazyLoadingService initialized');
  }

  /// Create lazy loading state
  LazyLoadingState createLoadingState({
    required String key,
    int batchSize = _defaultBatchSize,
    Duration loadDelay = _defaultLoadDelay,
    bool enableCaching = true,
    Duration? cacheExpiry,
  }) {
    final state = LazyLoadingState(
      key: key,
      batchSize: batchSize.clamp(_minBatchSize, _maxBatchSize),
      loadDelay: loadDelay,
      enableCaching: enableCaching,
      cacheExpiry: cacheExpiry ?? _cacheExpiry,
    );
    
    _loadingStates[key] = state;
    _saveLoadingStates();
    
    debugPrint('Created lazy loading state for key: $key');
    return state;
  }

  /// Get lazy loading state
  LazyLoadingState? getLoadingState(String key) {
    return _loadingStates[key];
  }

  /// Update lazy loading state
  void updateLoadingState(String key, LazyLoadingState state) {
    _loadingStates[key] = state;
    _saveLoadingStates();
  }

  /// Reset lazy loading state
  void resetLoadingState(String key) {
    final state = _loadingStates[key];
    if (state != null) {
      state.reset();
      _loadedData.remove(key);
      _loadTimestamps.remove(key);
      _saveLoadingStates();
      debugPrint('Reset lazy loading state for key: $key');
    }
  }

  /// Load data lazily
  Future<List<dynamic>> loadData(
    String key,
    Future<List<dynamic>> Function(int offset, int limit) fetchFunction, {
    bool forceRefresh = false,
  }) async {
    final state = _loadingStates[key];
    if (state == null) {
      throw Exception('Lazy loading state not found for key: $key');
    }

    // Check if we have cached data and it's not expired
    if (!forceRefresh && state.enableCaching && _loadedData.containsKey(key)) {
      final cacheTimestamp = _loadTimestamps[key];
      if (cacheTimestamp != null && 
          DateTime.now().difference(cacheTimestamp) < state.cacheExpiry) {
        final cachedData = _loadedData[key]!;
        if (cachedData.length > state.loadedCount) {
          final startIndex = state.loadedCount;
          final endIndex = (state.loadedCount + state.batchSize).clamp(0, cachedData.length);
          final batchData = cachedData.sublist(startIndex, endIndex);
          
          state.loadedCount += batchData.length;
          state.hasMore = endIndex < cachedData.length;
          _saveLoadingStates();
          
          debugPrint('Loaded batch from cache for key: $key (${batchData.length} items)');
          return batchData;
        }
      }
    }

    // Fetch new data
    try {
      final data = await fetchFunction(state.loadedCount, state.batchSize);
      
      if (state.enableCaching) {
        _loadedData[key] ??= [];
        _loadedData[key]!.addAll(data);
        _loadTimestamps[key] = DateTime.now();
      }
      
      state.loadedCount += data.length;
      state.hasMore = data.length == state.batchSize;
      state.totalItems = state.enableCaching ? _loadedData[key]!.length : null;
      _saveLoadingStates();
      
      debugPrint('Loaded batch from API for key: $key (${data.length} items)');
      return data;
    } catch (e) {
      debugPrint('Failed to load data for key $key: $e');
      rethrow;
    }
  }

  /// Load data with delay
  Future<List<dynamic>> loadDataWithDelay(
    String key,
    Future<List<dynamic>> Function(int offset, int limit) fetchFunction, {
    bool forceRefresh = false,
  }) async {
    final state = _loadingStates[key];
    if (state == null) {
      throw Exception('Lazy loading state not found for key: $key');
    }

    // Add delay before loading
    await Future.delayed(state.loadDelay);
    
    return await loadData(key, fetchFunction, forceRefresh: forceRefresh);
  }

  /// Load all remaining data
  Future<List<dynamic>> loadAllRemainingData(
    String key,
    Future<List<dynamic>> Function(int offset, int limit) fetchFunction,
  ) async {
    final state = _loadingStates[key];
    if (state == null) {
      throw Exception('Lazy loading state not found for key: $key');
    }

    final allData = <dynamic>[];
    
    while (state.hasMore) {
      final batchData = await loadData(key, fetchFunction);
      allData.addAll(batchData);
      
      // Add small delay between batches to prevent overwhelming the API
      if (state.hasMore) {
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
    
    debugPrint('Loaded all remaining data for key: $key (${allData.length} items)');
    return allData;
  }

  /// Refresh all data
  Future<List<dynamic>> refreshData(
    String key,
    Future<List<dynamic>> Function(int offset, int limit) fetchFunction,
  ) async {
    final state = _loadingStates[key];
    if (state == null) {
      throw Exception('Lazy loading state not found for key: $key');
    }

    // Clear cache
    _loadedData.remove(key);
    _loadTimestamps.remove(key);
    
    // Reset state
    state.reset();
    
    // Load first batch
    return await loadData(key, fetchFunction);
  }

  /// Get loaded data for key
  List<dynamic>? getLoadedData(String key) {
    return _loadedData[key];
  }

  /// Get loaded count for key
  int getLoadedCount(String key) {
    final state = _loadingStates[key];
    return state?.loadedCount ?? 0;
  }

  /// Check if has more data
  bool hasMoreData(String key) {
    final state = _loadingStates[key];
    return state?.hasMore ?? false;
  }

  /// Get total items
  int? getTotalItems(String key) {
    final state = _loadingStates[key];
    return state?.totalItems;
  }

  /// Clear loaded data for key
  void clearLoadedData(String key) {
    _loadedData.remove(key);
    _loadTimestamps.remove(key);
    debugPrint('Cleared loaded data for key: $key');
  }

  /// Clear all loaded data
  void clearAllLoadedData() {
    _loadedData.clear();
    _loadTimestamps.clear();
    debugPrint('Cleared all loaded data');
  }

  /// Get lazy loading statistics
  Map<String, dynamic> getLazyLoadingStatistics() {
    final stats = <String, dynamic>{
      'total_states': _loadingStates.length,
      'loaded_keys': _loadedData.keys.toList(),
      'total_loaded_items': _loadedData.values.fold(0, (sum, items) => sum + items.length),
    };
    
    final stateInfo = <String, dynamic>{};
    for (final entry in _loadingStates.entries) {
      final key = entry.key;
      final state = entry.value;
      
      stateInfo[key] = {
        'loaded_count': state.loadedCount,
        'batch_size': state.batchSize,
        'has_more': state.hasMore,
        'total_items': state.totalItems,
        'enable_caching': state.enableCaching,
        'loaded_items': _loadedData[key]?.length ?? 0,
      };
    }
    
    stats['state_info'] = stateInfo;
    return stats;
  }

  /// Load loading states from storage
  Future<void> _loadLoadingStates() async {
    if (_prefs == null) return;
    
    try {
      final statesJson = _prefs!.getString('lazy_loading_states');
      if (statesJson != null) {
        final data = jsonDecode(statesJson) as Map<String, dynamic>;
        
        for (final entry in data.entries) {
          final key = entry.key;
          final stateData = entry.value as Map<String, dynamic>;
          _loadingStates[key] = LazyLoadingState.fromJson(stateData);
        }
      }
    } catch (e) {
      debugPrint('Failed to load lazy loading states: $e');
    }
  }

  /// Save loading states to storage
  Future<void> _saveLoadingStates() async {
    if (_prefs == null) return;
    
    try {
      final data = _loadingStates.map((key, state) => MapEntry(key, state.toJson()));
      await _prefs!.setString('lazy_loading_states', jsonEncode(data));
    } catch (e) {
      debugPrint('Failed to save lazy loading states: $e');
    }
  }

  /// Dispose lazy loading service
  void dispose() {
    _loadingStates.clear();
    _loadedData.clear();
    _loadTimestamps.clear();
    debugPrint('LazyLoadingService disposed');
  }
}

/// Lazy loading state
class LazyLoadingState {
  final String key;
  final int batchSize;
  final Duration loadDelay;
  final bool enableCaching;
  final Duration cacheExpiry;
  
  int loadedCount;
  bool hasMore;
  int? totalItems;

  LazyLoadingState({
    required this.key,
    required this.batchSize,
    required this.loadDelay,
    required this.enableCaching,
    required this.cacheExpiry,
    this.loadedCount = 0,
    this.hasMore = true,
    this.totalItems,
  });

  /// Reset lazy loading state
  void reset() {
    loadedCount = 0;
    hasMore = true;
    totalItems = null;
  }

  /// Get current batch number
  int get currentBatch => (loadedCount / batchSize).floor();

  /// Get total batches
  int? get totalBatches {
    if (totalItems == null) return null;
    return (totalItems! / batchSize).ceil();
  }

  /// Check if we're on the first batch
  bool get isFirstBatch => loadedCount == 0;

  /// Check if we're on the last batch
  bool get isLastBatch => !hasMore;

  /// Get loading progress
  double get progress {
    if (totalItems == null || totalItems == 0) return 0.0;
    return loadedCount / totalItems!;
  }

  /// Get loading info
  Map<String, dynamic> getLoadingInfo() {
    return {
      'loaded_count': loadedCount,
      'batch_size': batchSize,
      'current_batch': currentBatch,
      'has_more': hasMore,
      'total_items': totalItems,
      'total_batches': totalBatches,
      'is_first_batch': isFirstBatch,
      'is_last_batch': isLastBatch,
      'progress': progress,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'batch_size': batchSize,
      'load_delay': loadDelay.inMilliseconds,
      'enable_caching': enableCaching,
      'cache_expiry': cacheExpiry.inMilliseconds,
      'loaded_count': loadedCount,
      'has_more': hasMore,
      'total_items': totalItems,
    };
  }

  factory LazyLoadingState.fromJson(Map<String, dynamic> json) {
    return LazyLoadingState(
      key: json['key'],
      batchSize: json['batch_size'],
      loadDelay: Duration(milliseconds: json['load_delay']),
      enableCaching: json['enable_caching'],
      cacheExpiry: Duration(milliseconds: json['cache_expiry']),
      loadedCount: json['loaded_count'],
      hasMore: json['has_more'],
      totalItems: json['total_items'],
    );
  }
}
