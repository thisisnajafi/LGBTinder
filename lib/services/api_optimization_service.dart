import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

class ApiOptimizationService {
  // Request deduplication
  static final Map<String, Completer<dynamic>> _pendingRequests = {};
  static final Map<String, DateTime> _lastRequestTimes = {};
  static final Map<String, int> _requestCounts = {};
  
  // Debounce timers
  static final Map<String, Timer> _debounceTimers = {};
  
  // Request batching
  static final Map<String, List<Completer<dynamic>>> _batchRequests = {};
  static Timer? _batchTimer;
  static const Duration _batchDelay = Duration(milliseconds: 100);
  
  // Request priorities
  static const int _highPriority = 1;
  static const int _mediumPriority = 2;
  static const int _lowPriority = 3;
  
  // Request queue
  static final Queue<_QueuedRequest> _requestQueue = Queue<_QueuedRequest>();
  static bool _isProcessingQueue = false;
  static const int _maxConcurrentRequests = 3;
  static int _currentConcurrentRequests = 0;

  // Deduplicate requests - if the same request is made multiple times quickly, return the same result
  static Future<T> deduplicateRequest<T>(
    String requestKey,
    Future<T> Function() requestFunction,
  ) async {
    // Check if request is already pending
    if (_pendingRequests.containsKey(requestKey)) {
      return await _pendingRequests[requestKey]!.future as T;
    }

    // Create new completer
    final completer = Completer<T>();
    _pendingRequests[requestKey] = completer;

    try {
      final result = await requestFunction();
      completer.complete(result);
      return result;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _pendingRequests.remove(requestKey);
    }
  }

  // Debounce requests - delay execution until no new requests come in
  static void debounceRequest(
    String requestKey,
    Duration delay,
    Future<void> Function() requestFunction,
  ) {
    // Cancel existing timer
    _debounceTimers[requestKey]?.cancel();
    
    // Set new timer
    _debounceTimers[requestKey] = Timer(delay, () async {
      try {
        await requestFunction();
      } catch (e) {
        if (kDebugMode) {
          print('Debounced request error: $e');
        }
      } finally {
        _debounceTimers.remove(requestKey);
      }
    });
  }

  // Throttle requests - limit frequency of requests
  static Future<T?> throttleRequest<T>(
    String requestKey,
    Duration minInterval,
    Future<T> Function() requestFunction,
  ) async {
    final now = DateTime.now();
    final lastRequestTime = _lastRequestTimes[requestKey];
    
    if (lastRequestTime != null && 
        now.difference(lastRequestTime) < minInterval) {
      return null; // Request throttled
    }
    
    _lastRequestTimes[requestKey] = now;
    return await requestFunction();
  }

  // Batch requests - combine multiple requests into one
  static Future<T> batchRequest<T>(
    String batchKey,
    Future<T> Function() requestFunction,
  ) async {
    // Create completer for this request
    final completer = Completer<T>();
    
    // Add to batch
    _batchRequests.putIfAbsent(batchKey, () => []).add(completer);
    
    // Start batch timer if not already running
    if (_batchTimer == null) {
      _batchTimer = Timer(_batchDelay, () {
        _processBatch(batchKey, requestFunction);
      });
    }
    
    return await completer.future;
  }

  // Process batch of requests
  static Future<void> _processBatch<T>(
    String batchKey,
    Future<T> Function() requestFunction,
  ) async {
    final completers = _batchRequests.remove(batchKey);
    if (completers == null || completers.isEmpty) return;
    
    try {
      final result = await requestFunction();
      
      // Complete all requests with the same result
      for (final completer in completers) {
        completer.complete(result);
      }
    } catch (e) {
      // Complete all requests with error
      for (final completer in completers) {
        completer.completeError(e);
      }
    }
    
    // Reset batch timer
    _batchTimer = null;
  }

  // Queue request with priority
  static Future<T> queueRequest<T>(
    String requestKey,
    int priority,
    Future<T> Function() requestFunction,
  ) async {
    final completer = Completer<T>();
    final queuedRequest = _QueuedRequest(
      key: requestKey,
      priority: priority,
      completer: completer,
      requestFunction: requestFunction,
    );
    
    _requestQueue.add(queuedRequest);
    _requestQueue.toList().sort((a, b) => a.priority.compareTo(b.priority));
    
    _processQueue();
    
    return await completer.future;
  }

  // Process request queue
  static Future<void> _processQueue() async {
    if (_isProcessingQueue || _requestQueue.isEmpty) return;
    
    _isProcessingQueue = true;
    
    while (_requestQueue.isNotEmpty && _currentConcurrentRequests < _maxConcurrentRequests) {
      final request = _requestQueue.removeFirst();
      _currentConcurrentRequests++;
      
      _executeRequest(request).then((_) {
        _currentConcurrentRequests--;
        _processQueue();
      });
    }
    
    _isProcessingQueue = false;
  }

  // Execute individual request
  static Future<void> _executeRequest(_QueuedRequest request) async {
    try {
      final result = await request.requestFunction();
      request.completer.complete(result);
    } catch (e) {
      request.completer.completeError(e);
    }
  }

  // Smart refresh - only refresh if data is stale
  static Future<T?> smartRefresh<T>(
    String cacheKey,
    Duration maxAge,
    Future<T> Function() refreshFunction,
  ) async {
    final now = DateTime.now();
    final lastRefresh = _lastRequestTimes[cacheKey];
    
    if (lastRefresh != null && now.difference(lastRefresh) < maxAge) {
      return null; // Data is still fresh
    }
    
    _lastRequestTimes[cacheKey] = now;
    return await refreshFunction();
  }

  // Preload data in background
  static void preloadData(String key, Future<void> Function() preloadFunction) {
    // Execute in background without blocking UI
    Future.microtask(() async {
      try {
        await preloadFunction();
      } catch (e) {
        if (kDebugMode) {
          print('Preload error for $key: $e');
        }
      }
    });
  }

  // Cancel pending requests
  static void cancelRequest(String requestKey) {
    _pendingRequests[requestKey]?.completeError('Request cancelled');
    _pendingRequests.remove(requestKey);
    
    _debounceTimers[requestKey]?.cancel();
    _debounceTimers.remove(requestKey);
  }

  // Cancel all pending requests
  static void cancelAllRequests() {
    // Cancel pending requests
    for (final completer in _pendingRequests.values) {
      completer.completeError('All requests cancelled');
    }
    _pendingRequests.clear();
    
    // Cancel debounce timers
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    
    // Cancel batch timer
    _batchTimer?.cancel();
    _batchTimer = null;
    
    // Clear batch requests
    for (final completers in _batchRequests.values) {
      for (final completer in completers) {
        completer.completeError('All requests cancelled');
      }
    }
    _batchRequests.clear();
    
    // Clear request queue
    for (final request in _requestQueue) {
      request.completer.completeError('All requests cancelled');
    }
    _requestQueue.clear();
  }

  // Get optimization statistics
  static Map<String, dynamic> getOptimizationStats() {
    return {
      'pendingRequests': _pendingRequests.length,
      'debounceTimers': _debounceTimers.length,
      'batchRequests': _batchRequests.length,
      'queuedRequests': _requestQueue.length,
      'currentConcurrentRequests': _currentConcurrentRequests,
      'maxConcurrentRequests': _maxConcurrentRequests,
      'lastRequestTimes': _lastRequestTimes.length,
      'requestCounts': _requestCounts.length,
    };
  }

  // Clear optimization data
  static void clearOptimizationData() {
    _lastRequestTimes.clear();
    _requestCounts.clear();
  }

  // Set max concurrent requests
  static void setMaxConcurrentRequests(int max) {
    // This would typically be called based on device capabilities
    // For now, we'll keep it static
  }

  // Check if request should be optimized
  static bool shouldOptimizeRequest(String requestKey, RequestType type) {
    switch (type) {
      case RequestType.referenceData:
        return true; // Always optimize reference data
      case RequestType.userProfile:
        return true; // Always optimize user profile
      case RequestType.matches:
        return true; // Always optimize matches
      case RequestType.chatHistory:
        return false; // Don't optimize chat history (needs real-time data)
      case RequestType.likeUser:
        return false; // Don't optimize likes (user action)
      case RequestType.sendMessage:
        return false; // Don't optimize messages (user action)
      case RequestType.uploadImage:
        return false; // Don't optimize uploads (user action)
      default:
        return true; // Default to optimizing
    }
  }
}

// Request types for optimization decisions
enum RequestType {
  referenceData,
  userProfile,
  matches,
  chatHistory,
  likeUser,
  sendMessage,
  uploadImage,
}

// Queued request class
class _QueuedRequest {
  final String key;
  final int priority;
  final Completer<dynamic> completer;
  final Future<dynamic> Function() requestFunction;

  _QueuedRequest({
    required this.key,
    required this.priority,
    required this.completer,
    required this.requestFunction,
  });
}
