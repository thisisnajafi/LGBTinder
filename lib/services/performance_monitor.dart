import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/error_handler.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  SharedPreferences? _prefs;
  final Map<String, PerformanceMetric> _metrics = {};
  final Map<String, List<PerformanceEvent>> _events = {};
  final StreamController<PerformanceEvent> _eventController = StreamController<PerformanceEvent>.broadcast();
  
  Stream<PerformanceEvent> get performanceEvents => _eventController.stream;

  /// Initialize performance monitor
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadMetrics();
    debugPrint('PerformanceMonitor initialized');
  }

  /// Start monitoring a performance metric
  void startMonitoring(String name, String category) {
    _metrics[name] = PerformanceMetric(
      name: name,
      category: category,
      startTime: DateTime.now(),
    );
  }

  /// Stop monitoring a performance metric
  void stopMonitoring(String name) {
    final metric = _metrics[name];
    if (metric != null) {
      metric.endTime = DateTime.now();
      metric.duration = metric.endTime!.difference(metric.startTime);
      
      _addEvent(PerformanceEvent(
        name: name,
        category: metric.category,
        duration: metric.duration,
        timestamp: metric.endTime!,
      ));
      
      _metrics.remove(name);
    }
  }

  /// Record a performance event
  void recordEvent(String name, String category, Duration duration, {Map<String, dynamic>? metadata}) {
    _addEvent(PerformanceEvent(
      name: name,
      category: category,
      duration: duration,
      timestamp: DateTime.now(),
      metadata: metadata,
    ));
  }

  /// Record API call performance
  void recordApiCall(String endpoint, String method, Duration duration, int statusCode, {Map<String, dynamic>? metadata}) {
    recordEvent(
      'api_call',
      'network',
      duration,
      metadata: {
        'endpoint': endpoint,
        'method': method,
        'status_code': statusCode,
        ...?metadata,
      },
    );
  }

  /// Record database operation performance
  void recordDatabaseOperation(String operation, String table, Duration duration, {Map<String, dynamic>? metadata}) {
    recordEvent(
      'database_operation',
      'database',
      duration,
      metadata: {
        'operation': operation,
        'table': table,
        ...?metadata,
      },
    );
  }

  /// Record UI rendering performance
  void recordUIRendering(String screen, Duration duration, {Map<String, dynamic>? metadata}) {
    recordEvent(
      'ui_rendering',
      'ui',
      duration,
      metadata: {
        'screen': screen,
        ...?metadata,
      },
    );
  }

  /// Record image loading performance
  void recordImageLoading(String imageUrl, Duration duration, int imageSize, {Map<String, dynamic>? metadata}) {
    recordEvent(
      'image_loading',
      'media',
      duration,
      metadata: {
        'image_url': imageUrl,
        'image_size': imageSize,
        ...?metadata,
      },
    );
  }

  /// Record memory usage
  void recordMemoryUsage(int memoryUsage, {Map<String, dynamic>? metadata}) {
    recordEvent(
      'memory_usage',
      'system',
      Duration.zero,
      metadata: {
        'memory_usage': memoryUsage,
        ...?metadata,
      },
    );
  }

  /// Record CPU usage
  void recordCpuUsage(double cpuUsage, {Map<String, dynamic>? metadata}) {
    recordEvent(
      'cpu_usage',
      'system',
      Duration.zero,
      metadata: {
        'cpu_usage': cpuUsage,
        ...?metadata,
      },
    );
  }

  /// Record network latency
  void recordNetworkLatency(String endpoint, Duration latency, {Map<String, dynamic>? metadata}) {
    recordEvent(
      'network_latency',
      'network',
      latency,
      metadata: {
        'endpoint': endpoint,
        ...?metadata,
      },
    );
  }

  /// Record cache hit/miss
  void recordCacheEvent(String cacheKey, bool hit, Duration duration, {Map<String, dynamic>? metadata}) {
    recordEvent(
      'cache_${hit ? 'hit' : 'miss'}',
      'cache',
      duration,
      metadata: {
        'cache_key': cacheKey,
        'hit': hit,
        ...?metadata,
      },
    );
  }

  /// Record error performance impact
  void recordErrorImpact(String errorType, Duration impact, {Map<String, dynamic>? metadata}) {
    recordEvent(
      'error_impact',
      'error',
      impact,
      metadata: {
        'error_type': errorType,
        ...?metadata,
      },
    );
  }

  /// Add performance event
  void _addEvent(PerformanceEvent event) {
    final category = event.category;
    _events[category] ??= [];
    _events[category]!.add(event);
    
    // Keep only last 1000 events per category
    if (_events[category]!.length > 1000) {
      _events[category]!.removeAt(0);
    }
    
    _eventController.add(event);
    _saveMetrics();
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats({String? category, Duration? timeRange}) {
    final stats = <String, dynamic>{};
    
    if (category != null) {
      stats[category] = _getCategoryStats(category, timeRange);
    } else {
      for (final cat in _events.keys) {
        stats[cat] = _getCategoryStats(cat, timeRange);
      }
    }
    
    return stats;
  }

  /// Get category statistics
  Map<String, dynamic> _getCategoryStats(String category, Duration? timeRange) {
    final events = _events[category] ?? [];
    final filteredEvents = timeRange != null
        ? events.where((e) => DateTime.now().difference(e.timestamp) <= timeRange).toList()
        : events;
    
    if (filteredEvents.isEmpty) {
      return {
        'count': 0,
        'average_duration': 0,
        'min_duration': 0,
        'max_duration': 0,
        'total_duration': 0,
      };
    }
    
    final durations = filteredEvents.map((e) => e.duration.inMilliseconds).toList();
    final totalDuration = durations.reduce((a, b) => a + b);
    
    return {
      'count': filteredEvents.length,
      'average_duration': totalDuration / filteredEvents.length,
      'min_duration': durations.reduce((a, b) => a < b ? a : b),
      'max_duration': durations.reduce((a, b) => a > b ? a : b),
      'total_duration': totalDuration,
      'events': filteredEvents.map((e) => e.toJson()).toList(),
    };
  }

  /// Get performance trends
  Map<String, dynamic> getPerformanceTrends({String? category, Duration? timeRange}) {
    final trends = <String, dynamic>{};
    
    if (category != null) {
      trends[category] = _getCategoryTrends(category, timeRange);
    } else {
      for (final cat in _events.keys) {
        trends[cat] = _getCategoryTrends(cat, timeRange);
      }
    }
    
    return trends;
  }

  /// Get category trends
  Map<String, dynamic> _getCategoryTrends(String category, Duration? timeRange) {
    final events = _events[category] ?? [];
    final filteredEvents = timeRange != null
        ? events.where((e) => DateTime.now().difference(e.timestamp) <= timeRange).toList()
        : events;
    
    if (filteredEvents.isEmpty) {
      return {
        'trend': 'stable',
        'change_percentage': 0,
        'data_points': [],
      };
    }
    
    // Group events by hour
    final hourlyData = <String, List<PerformanceEvent>>{};
    for (final event in filteredEvents) {
      final hour = event.timestamp.toIso8601String().substring(0, 13);
      hourlyData[hour] ??= [];
      hourlyData[hour]!.add(event);
    }
    
    // Calculate hourly averages
    final hourlyAverages = <String, double>{};
    for (final entry in hourlyData.entries) {
      final avgDuration = entry.value.map((e) => e.duration.inMilliseconds).reduce((a, b) => a + b) / entry.value.length;
      hourlyAverages[entry.key] = avgDuration;
    }
    
    // Calculate trend
    final sortedHours = hourlyAverages.keys.toList()..sort();
    if (sortedHours.length < 2) {
      return {
        'trend': 'stable',
        'change_percentage': 0,
        'data_points': hourlyAverages.entries.map((e) => {'hour': e.key, 'average': e.value}).toList(),
      };
    }
    
    final firstHour = sortedHours.first;
    final lastHour = sortedHours.last;
    final firstAvg = hourlyAverages[firstHour]!;
    final lastAvg = hourlyAverages[lastHour]!;
    final changePercentage = ((lastAvg - firstAvg) / firstAvg) * 100;
    
    String trend;
    if (changePercentage > 10) {
      trend = 'improving';
    } else if (changePercentage < -10) {
      trend = 'degrading';
    } else {
      trend = 'stable';
    }
    
    return {
      'trend': trend,
      'change_percentage': changePercentage,
      'data_points': hourlyAverages.entries.map((e) => {'hour': e.key, 'average': e.value}).toList(),
    };
  }

  /// Get performance alerts
  List<PerformanceAlert> getPerformanceAlerts() {
    final alerts = <PerformanceAlert>[];
    
    for (final category in _events.keys) {
      final stats = _getCategoryStats(category, null);
      final count = stats['count'] as int;
      final avgDuration = stats['average_duration'] as double;
      
      // Check for high frequency
      if (count > 1000) {
        alerts.add(PerformanceAlert(
          type: 'high_frequency',
          category: category,
          message: 'High frequency of $category events: $count',
          severity: 'warning',
        ));
      }
      
      // Check for slow performance
      if (avgDuration > 5000) { // 5 seconds
        alerts.add(PerformanceAlert(
          type: 'slow_performance',
          category: category,
          message: 'Slow $category performance: ${avgDuration.toStringAsFixed(2)}ms average',
          severity: 'error',
        ));
      }
    }
    
    return alerts;
  }

  /// Clear performance data
  Future<void> clearPerformanceData() async {
    _metrics.clear();
    _events.clear();
    await _saveMetrics();
    debugPrint('Performance data cleared');
  }

  /// Load metrics from storage
  Future<void> _loadMetrics() async {
    if (_prefs == null) return;
    
    try {
      final metricsJson = _prefs!.getString('performance_metrics');
      if (metricsJson != null) {
        final data = jsonDecode(metricsJson) as Map<String, dynamic>;
        
        // Load events
        final eventsData = data['events'] as Map<String, dynamic>?;
        if (eventsData != null) {
          for (final entry in eventsData.entries) {
            final category = entry.key;
            final eventsList = entry.value as List<dynamic>;
            _events[category] = eventsList.map((e) => PerformanceEvent.fromJson(e)).toList();
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load performance metrics: $e');
    }
  }

  /// Save metrics to storage
  Future<void> _saveMetrics() async {
    if (_prefs == null) return;
    
    try {
      final data = {
        'events': _events.map((key, value) => MapEntry(key, value.map((e) => e.toJson()).toList())),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _prefs!.setString('performance_metrics', jsonEncode(data));
    } catch (e) {
      debugPrint('Failed to save performance metrics: $e');
    }
  }

  /// Dispose performance monitor
  void dispose() {
    _eventController.close();
    debugPrint('PerformanceMonitor disposed');
  }
}

/// Performance metric
class PerformanceMetric {
  final String name;
  final String category;
  final DateTime startTime;
  DateTime? endTime;
  Duration? duration;

  PerformanceMetric({
    required this.name,
    required this.category,
    required this.startTime,
    this.endTime,
    this.duration,
  });
}

/// Performance event
class PerformanceEvent {
  final String name;
  final String category;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  PerformanceEvent({
    required this.name,
    required this.category,
    required this.duration,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'duration': duration.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory PerformanceEvent.fromJson(Map<String, dynamic> json) {
    return PerformanceEvent(
      name: json['name'],
      category: json['category'],
      duration: Duration(milliseconds: json['duration']),
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Performance alert
class PerformanceAlert {
  final String type;
  final String category;
  final String message;
  final String severity; // 'info', 'warning', 'error'

  PerformanceAlert({
    required this.type,
    required this.category,
    required this.message,
    required this.severity,
  });
}
