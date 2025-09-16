import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PaginationService {
  static final PaginationService _instance = PaginationService._internal();
  factory PaginationService() => _instance;
  PaginationService._internal();

  SharedPreferences? _prefs;
  final Map<String, PaginationState> _paginationStates = {};
  final Map<String, List<dynamic>> _cachedPages = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Pagination configuration
  static const int _defaultPageSize = 20;
  static const int _maxPageSize = 100;
  static const int _minPageSize = 5;
  static const Duration _cacheExpiry = Duration(minutes: 10);

  /// Initialize pagination service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadPaginationStates();
    debugPrint('PaginationService initialized');
  }

  /// Create pagination state
  PaginationState createPaginationState({
    required String key,
    int pageSize = _defaultPageSize,
    bool enableCaching = true,
    Duration? cacheExpiry,
  }) {
    final state = PaginationState(
      key: key,
      pageSize: pageSize.clamp(_minPageSize, _maxPageSize),
      enableCaching: enableCaching,
      cacheExpiry: cacheExpiry ?? _cacheExpiry,
    );
    
    _paginationStates[key] = state;
    _savePaginationStates();
    
    debugPrint('Created pagination state for key: $key');
    return state;
  }

  /// Get pagination state
  PaginationState? getPaginationState(String key) {
    return _paginationStates[key];
  }

  /// Update pagination state
  void updatePaginationState(String key, PaginationState state) {
    _paginationStates[key] = state;
    _savePaginationStates();
  }

  /// Reset pagination state
  void resetPaginationState(String key) {
    final state = _paginationStates[key];
    if (state != null) {
      state.reset();
      _cachedPages.remove(key);
      _cacheTimestamps.remove(key);
      _savePaginationStates();
      debugPrint('Reset pagination state for key: $key');
    }
  }

  /// Load next page
  Future<List<dynamic>> loadNextPage(
    String key,
    Future<List<dynamic>> Function(int page, int pageSize) fetchFunction,
  ) async {
    final state = _paginationStates[key];
    if (state == null) {
      throw Exception('Pagination state not found for key: $key');
    }

    // Check if we have cached data
    if (state.enableCaching && _cachedPages.containsKey(key)) {
      final cacheTimestamp = _cacheTimestamps[key];
      if (cacheTimestamp != null && 
          DateTime.now().difference(cacheTimestamp) < state.cacheExpiry) {
        final cachedData = _cachedPages[key]!;
        if (cachedData.length > state.currentPage * state.pageSize) {
          final startIndex = state.currentPage * state.pageSize;
          final endIndex = (state.currentPage + 1) * state.pageSize;
          final pageData = cachedData.sublist(
            startIndex,
            endIndex > cachedData.length ? cachedData.length : endIndex,
          );
          
          state.currentPage++;
          state.hasMore = endIndex < cachedData.length;
          _savePaginationStates();
          
          debugPrint('Loaded page ${state.currentPage} from cache for key: $key');
          return pageData;
        }
      }
    }

    // Fetch new data
    try {
      final data = await fetchFunction(state.currentPage, state.pageSize);
      
      if (state.enableCaching) {
        _cachedPages[key] ??= [];
        _cachedPages[key]!.addAll(data);
        _cacheTimestamps[key] = DateTime.now();
      }
      
      state.currentPage++;
      state.hasMore = data.length == state.pageSize;
      state.totalItems = state.enableCaching ? _cachedPages[key]!.length : null;
      _savePaginationStates();
      
      debugPrint('Loaded page ${state.currentPage} from API for key: $key');
      return data;
    } catch (e) {
      debugPrint('Failed to load page for key $key: $e');
      rethrow;
    }
  }

  /// Load previous page
  Future<List<dynamic>> loadPreviousPage(String key) async {
    final state = _paginationStates[key];
    if (state == null) {
      throw Exception('Pagination state not found for key: $key');
    }

    if (state.currentPage <= 0) {
      return [];
    }

    state.currentPage--;
    
    if (state.enableCaching && _cachedPages.containsKey(key)) {
      final cachedData = _cachedPages[key]!;
      final startIndex = state.currentPage * state.pageSize;
      final endIndex = (state.currentPage + 1) * state.pageSize;
      final pageData = cachedData.sublist(
        startIndex,
        endIndex > cachedData.length ? cachedData.length : endIndex,
      );
      
      state.hasMore = endIndex < cachedData.length;
      _savePaginationStates();
      
      debugPrint('Loaded previous page ${state.currentPage} from cache for key: $key');
      return pageData;
    }

    _savePaginationStates();
    return [];
  }

  /// Load specific page
  Future<List<dynamic>> loadPage(
    String key,
    int page,
    Future<List<dynamic>> Function(int page, int pageSize) fetchFunction,
  ) async {
    final state = _paginationStates[key];
    if (state == null) {
      throw Exception('Pagination state not found for key: $key');
    }

    // Check if we have cached data
    if (state.enableCaching && _cachedPages.containsKey(key)) {
      final cacheTimestamp = _cacheTimestamps[key];
      if (cacheTimestamp != null && 
          DateTime.now().difference(cacheTimestamp) < state.cacheExpiry) {
        final cachedData = _cachedPages[key]!;
        final startIndex = page * state.pageSize;
        final endIndex = (page + 1) * state.pageSize;
        
        if (startIndex < cachedData.length) {
          final pageData = cachedData.sublist(
            startIndex,
            endIndex > cachedData.length ? cachedData.length : endIndex,
          );
          
          state.currentPage = page;
          state.hasMore = endIndex < cachedData.length;
          _savePaginationStates();
          
          debugPrint('Loaded page $page from cache for key: $key');
          return pageData;
        }
      }
    }

    // Fetch new data
    try {
      final data = await fetchFunction(page, state.pageSize);
      
      if (state.enableCaching) {
        _cachedPages[key] ??= [];
        // Ensure we have enough space in the cache
        while (_cachedPages[key]!.length <= page * state.pageSize) {
          _cachedPages[key]!.add(null);
        }
        
        // Insert data at the correct position
        final startIndex = page * state.pageSize;
        for (int i = 0; i < data.length; i++) {
          if (startIndex + i < _cachedPages[key]!.length) {
            _cachedPages[key]![startIndex + i] = data[i];
          } else {
            _cachedPages[key]!.add(data[i]);
          }
        }
        
        _cacheTimestamps[key] = DateTime.now();
      }
      
      state.currentPage = page;
      state.hasMore = data.length == state.pageSize;
      state.totalItems = state.enableCaching ? _cachedPages[key]!.length : null;
      _savePaginationStates();
      
      debugPrint('Loaded page $page from API for key: $key');
      return data;
    } catch (e) {
      debugPrint('Failed to load page $page for key $key: $e');
      rethrow;
    }
  }

  /// Refresh pagination data
  Future<List<dynamic>> refresh(
    String key,
    Future<List<dynamic>> Function(int page, int pageSize) fetchFunction,
  ) async {
    final state = _paginationStates[key];
    if (state == null) {
      throw Exception('Pagination state not found for key: $key');
    }

    // Clear cache
    _cachedPages.remove(key);
    _cacheTimestamps.remove(key);
    
    // Reset state
    state.reset();
    
    // Load first page
    return await loadNextPage(key, fetchFunction);
  }

  /// Get cached data for key
  List<dynamic>? getCachedData(String key) {
    return _cachedPages[key];
  }

  /// Clear cache for key
  void clearCache(String key) {
    _cachedPages.remove(key);
    _cacheTimestamps.remove(key);
    debugPrint('Cleared cache for key: $key');
  }

  /// Clear all cache
  void clearAllCache() {
    _cachedPages.clear();
    _cacheTimestamps.clear();
    debugPrint('Cleared all cache');
  }

  /// Get pagination statistics
  Map<String, dynamic> getPaginationStatistics() {
    final stats = <String, dynamic>{
      'total_states': _paginationStates.length,
      'cached_keys': _cachedPages.keys.toList(),
      'total_cached_items': _cachedPages.values.fold(0, (sum, items) => sum + items.length),
    };
    
    final stateInfo = <String, dynamic>{};
    for (final entry in _paginationStates.entries) {
      final key = entry.key;
      final state = entry.value;
      
      stateInfo[key] = {
        'current_page': state.currentPage,
        'page_size': state.pageSize,
        'has_more': state.hasMore,
        'total_items': state.totalItems,
        'enable_caching': state.enableCaching,
        'cached_items': _cachedPages[key]?.length ?? 0,
      };
    }
    
    stats['state_info'] = stateInfo;
    return stats;
  }

  /// Load pagination states from storage
  Future<void> _loadPaginationStates() async {
    if (_prefs == null) return;
    
    try {
      final statesJson = _prefs!.getString('pagination_states');
      if (statesJson != null) {
        final data = jsonDecode(statesJson) as Map<String, dynamic>;
        
        for (final entry in data.entries) {
          final key = entry.key;
          final stateData = entry.value as Map<String, dynamic>;
          _paginationStates[key] = PaginationState.fromJson(stateData);
        }
      }
    } catch (e) {
      debugPrint('Failed to load pagination states: $e');
    }
  }

  /// Save pagination states to storage
  Future<void> _savePaginationStates() async {
    if (_prefs == null) return;
    
    try {
      final data = _paginationStates.map((key, state) => MapEntry(key, state.toJson()));
      await _prefs!.setString('pagination_states', jsonEncode(data));
    } catch (e) {
      debugPrint('Failed to save pagination states: $e');
    }
  }

  /// Dispose pagination service
  void dispose() {
    _paginationStates.clear();
    _cachedPages.clear();
    _cacheTimestamps.clear();
    debugPrint('PaginationService disposed');
  }
}

/// Pagination state
class PaginationState {
  final String key;
  final int pageSize;
  final bool enableCaching;
  final Duration cacheExpiry;
  
  int currentPage;
  bool hasMore;
  int? totalItems;

  PaginationState({
    required this.key,
    required this.pageSize,
    required this.enableCaching,
    required this.cacheExpiry,
    this.currentPage = 0,
    this.hasMore = true,
    this.totalItems,
  });

  /// Reset pagination state
  void reset() {
    currentPage = 0;
    hasMore = true;
    totalItems = null;
  }

  /// Get current page number (1-based)
  int get pageNumber => currentPage + 1;

  /// Get total pages
  int? get totalPages {
    if (totalItems == null) return null;
    return (totalItems! / pageSize).ceil();
  }

  /// Check if we're on the first page
  bool get isFirstPage => currentPage == 0;

  /// Check if we're on the last page
  bool get isLastPage => !hasMore;

  /// Get pagination info
  Map<String, dynamic> getPaginationInfo() {
    return {
      'current_page': pageNumber,
      'page_size': pageSize,
      'has_more': hasMore,
      'total_items': totalItems,
      'total_pages': totalPages,
      'is_first_page': isFirstPage,
      'is_last_page': isLastPage,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'page_size': pageSize,
      'enable_caching': enableCaching,
      'cache_expiry': cacheExpiry.inMilliseconds,
      'current_page': currentPage,
      'has_more': hasMore,
      'total_items': totalItems,
    };
  }

  factory PaginationState.fromJson(Map<String, dynamic> json) {
    return PaginationState(
      key: json['key'],
      pageSize: json['page_size'],
      enableCaching: json['enable_caching'],
      cacheExpiry: Duration(milliseconds: json['cache_expiry']),
      currentPage: json['current_page'],
      hasMore: json['has_more'],
      totalItems: json['total_items'],
    );
  }
}
