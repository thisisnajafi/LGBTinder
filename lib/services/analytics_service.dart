import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment_config.dart';

class AnalyticsService {
  static const String _analyticsKey = 'analytics_events';
  static const String _userPropertiesKey = 'user_properties';
  static const String _sessionKey = 'analytics_session';
  static const int _maxEvents = 1000;
  static const Duration _sessionTimeout = Duration(minutes: 30);

  // Analytics data
  static final List<AnalyticsEvent> _events = [];
  static final Map<String, dynamic> _userProperties = {};
  static String? _currentSessionId;
  static DateTime? _sessionStartTime;
  static String? _userId;

  // Initialize analytics
  static Future<void> initialize() async {
    if (EnvironmentConfig.enableAnalytics) {
      await _loadStoredEvents();
      await _loadUserProperties();
      _startNewSession();
    }
  }

  // Track API call
  static Future<void> trackApiCall({
    required String endpoint,
    required String method,
    required int statusCode,
    required Duration duration,
    required String requestId,
    Map<String, dynamic>? parameters,
  }) async {
    if (!EnvironmentConfig.enableAnalytics) return;

    final event = AnalyticsEvent(
      name: 'api_call',
      category: 'api',
      action: method,
      label: endpoint,
      value: statusCode,
      parameters: {
        'endpoint': endpoint,
        'method': method,
        'status_code': statusCode,
        'duration_ms': duration.inMilliseconds,
        'request_id': requestId,
        'session_id': _currentSessionId,
        'user_id': _userId,
        ...?parameters,
      },
      timestamp: DateTime.now(),
    );

    await _trackEvent(event);
  }

  // Track authentication event
  static Future<void> trackAuthEvent({
    required String action,
    required bool success,
    String? errorType,
    Map<String, dynamic>? parameters,
  }) async {
    if (!EnvironmentConfig.enableAnalytics) return;

    final event = AnalyticsEvent(
      name: 'auth_event',
      category: 'authentication',
      action: action,
      label: success ? 'success' : 'failure',
      value: success ? 1 : 0,
      parameters: {
        'action': action,
        'success': success,
        'error_type': errorType,
        'session_id': _currentSessionId,
        'user_id': _userId,
        ...?parameters,
      },
      timestamp: DateTime.now(),
    );

    await _trackEvent(event);
  }

  // Track user action
  static Future<void> trackUserAction({
    required String action,
    required String screen,
    Map<String, dynamic>? parameters,
  }) async {
    if (!EnvironmentConfig.enableAnalytics) return;

    final event = AnalyticsEvent(
      name: 'user_action',
      category: 'user_interaction',
      action: action,
      label: screen,
      parameters: {
        'action': action,
        'screen': screen,
        'session_id': _currentSessionId,
        'user_id': _userId,
        ...?parameters,
      },
      timestamp: DateTime.now(),
    );

    await _trackEvent(event);
  }

  // Track screen view
  static Future<void> trackScreenView({
    required String screenName,
    String? previousScreen,
    Map<String, dynamic>? parameters,
  }) async {
    if (!EnvironmentConfig.enableAnalytics) return;

    final event = AnalyticsEvent(
      name: 'screen_view',
      category: 'navigation',
      action: 'view',
      label: screenName,
      parameters: {
        'screen_name': screenName,
        'previous_screen': previousScreen,
        'session_id': _currentSessionId,
        'user_id': _userId,
        ...?parameters,
      },
      timestamp: DateTime.now(),
    );

    await _trackEvent(event);
  }

  // Track matching event
  static Future<void> trackMatchingEvent({
    required String action,
    required String targetUserId,
    bool? isMatch,
    Map<String, dynamic>? parameters,
  }) async {
    if (!EnvironmentConfig.enableAnalytics) return;

    final event = AnalyticsEvent(
      name: 'matching_event',
      category: 'matching',
      action: action,
      label: targetUserId,
      value: isMatch == true ? 1 : 0,
      parameters: {
        'action': action,
        'target_user_id': targetUserId,
        'is_match': isMatch,
        'session_id': _currentSessionId,
        'user_id': _userId,
        ...?parameters,
      },
      timestamp: DateTime.now(),
    );

    await _trackEvent(event);
  }

  // Track chat event
  static Future<void> trackChatEvent({
    required String action,
    required String targetUserId,
    String? messageType,
    Map<String, dynamic>? parameters,
  }) async {
    if (!EnvironmentConfig.enableAnalytics) return;

    final event = AnalyticsEvent(
      name: 'chat_event',
      category: 'chat',
      action: action,
      label: targetUserId,
      parameters: {
        'action': action,
        'target_user_id': targetUserId,
        'message_type': messageType,
        'session_id': _currentSessionId,
        'user_id': _userId,
        ...?parameters,
      },
      timestamp: DateTime.now(),
    );

    await _trackEvent(event);
  }

  // Track profile event
  static Future<void> trackProfileEvent({
    required String action,
    String? field,
    Map<String, dynamic>? parameters,
  }) async {
    if (!EnvironmentConfig.enableAnalytics) return;

    final event = AnalyticsEvent(
      name: 'profile_event',
      category: 'profile',
      action: action,
      label: field,
      parameters: {
        'action': action,
        'field': field,
        'session_id': _currentSessionId,
        'user_id': _userId,
        ...?parameters,
      },
      timestamp: DateTime.now(),
    );

    await _trackEvent(event);
  }

  // Track performance event
  static Future<void> trackPerformanceEvent({
    required String operation,
    required Duration duration,
    String? threshold,
    Map<String, dynamic>? parameters,
  }) async {
    if (!EnvironmentConfig.enableAnalytics) return;

    final event = AnalyticsEvent(
      name: 'performance_event',
      category: 'performance',
      action: operation,
      label: threshold,
      value: duration.inMilliseconds,
      parameters: {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        'threshold': threshold,
        'session_id': _currentSessionId,
        'user_id': _userId,
        ...?parameters,
      },
      timestamp: DateTime.now(),
    );

    await _trackEvent(event);
  }

  // Track error event
  static Future<void> trackErrorEvent({
    required String errorType,
    required String errorMessage,
    String? endpoint,
    Map<String, dynamic>? parameters,
  }) async {
    if (!EnvironmentConfig.enableAnalytics) return;

    final event = AnalyticsEvent(
      name: 'error_event',
      category: 'error',
      action: errorType,
      label: endpoint,
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        'endpoint': endpoint,
        'session_id': _currentSessionId,
        'user_id': _userId,
        ...?parameters,
      },
      timestamp: DateTime.now(),
    );

    await _trackEvent(event);
  }

  // Set user properties
  static Future<void> setUserProperties(Map<String, dynamic> properties) async {
    _userProperties.addAll(properties);
    await _storeUserProperties();
  }

  // Set user ID
  static Future<void> setUserId(String userId) async {
    _userId = userId;
    await _storeUserProperties();
  }

  // Start new session
  static void _startNewSession() {
    _currentSessionId = _generateSessionId();
    _sessionStartTime = DateTime.now();
    _storeSession();
  }

  // Check session timeout
  static void _checkSessionTimeout() {
    if (_sessionStartTime != null) {
      final now = DateTime.now();
      if (now.difference(_sessionStartTime!) > _sessionTimeout) {
        _startNewSession();
      }
    }
  }

  // Track event
  static Future<void> _trackEvent(AnalyticsEvent event) async {
    _checkSessionTimeout();
    
    _events.add(event);
    await _storeEvent(event);

    if (kDebugMode) {
      print('Analytics event tracked: ${event.name} - ${event.action}');
    }

    // Send to remote analytics service
    if (EnvironmentConfig.enableAnalytics) {
      await _sendEventToRemote(event);
    }
  }

  // Store event locally
  static Future<void> _storeEvent(AnalyticsEvent event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingEvents = prefs.getStringList(_analyticsKey) ?? [];
      
      existingEvents.add(jsonEncode(event.toJson()));
      
      // Limit number of stored events
      if (existingEvents.length > _maxEvents) {
        existingEvents.removeRange(0, existingEvents.length - _maxEvents);
      }
      
      await prefs.setStringList(_analyticsKey, existingEvents);
    } catch (e) {
      if (kDebugMode) {
        print('Error storing analytics event: $e');
      }
    }
  }

  // Store user properties
  static Future<void> _storeUserProperties() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userPropertiesKey, jsonEncode(_userProperties));
    } catch (e) {
      if (kDebugMode) {
        print('Error storing user properties: $e');
      }
    }
  }

  // Store session
  static Future<void> _storeSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = {
        'session_id': _currentSessionId,
        'start_time': _sessionStartTime?.toIso8601String(),
        'user_id': _userId,
      };
      await prefs.setString(_sessionKey, jsonEncode(sessionData));
    } catch (e) {
      if (kDebugMode) {
        print('Error storing session: $e');
      }
    }
  }

  // Load stored events
  static Future<void> _loadStoredEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final events = prefs.getStringList(_analyticsKey) ?? [];
      
      for (final eventJson in events) {
        try {
          final eventData = jsonDecode(eventJson) as Map<String, dynamic>;
          _events.add(AnalyticsEvent.fromJson(eventData));
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing analytics event: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading stored events: $e');
      }
    }
  }

  // Load user properties
  static Future<void> _loadUserProperties() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final propertiesJson = prefs.getString(_userPropertiesKey);
      
      if (propertiesJson != null) {
        final properties = jsonDecode(propertiesJson) as Map<String, dynamic>;
        _userProperties.addAll(properties);
        _userId = properties['user_id'] as String?;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user properties: $e');
      }
    }
  }

  // Send event to remote analytics service
  static Future<void> _sendEventToRemote(AnalyticsEvent event) async {
    try {
      // This would typically send to a service like Firebase Analytics, Mixpanel, etc.
      // For now, we'll just log it
      if (kDebugMode) {
        print('Sending analytics event to remote: ${event.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending analytics event to remote: $e');
      }
    }
  }

  // Generate session ID
  static String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (1000 + (DateTime.now().microsecond % 9000)).toString();
  }

  // Get analytics events
  static List<AnalyticsEvent> getEvents() => List.unmodifiable(_events);

  // Get user properties
  static Map<String, dynamic> getUserProperties() => Map.unmodifiable(_userProperties);

  // Get current session ID
  static String? getCurrentSessionId() => _currentSessionId;

  // Get session start time
  static DateTime? getSessionStartTime() => _sessionStartTime;

  // Get user ID
  static String? getUserId() => _userId;

  // Clear all analytics data
  static Future<void> clearAllData() async {
    _events.clear();
    _userProperties.clear();
    _currentSessionId = null;
    _sessionStartTime = null;
    _userId = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_analyticsKey);
    await prefs.remove(_userPropertiesKey);
    await prefs.remove(_sessionKey);
  }

  // Get analytics statistics
  static Map<String, dynamic> getAnalyticsStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = today.subtract(Duration(days: today.weekday - 1));
    final thisMonth = DateTime(now.year, now.month, 1);

    final todayEvents = _events.where((e) => e.timestamp.isAfter(today)).length;
    final weekEvents = _events.where((e) => e.timestamp.isAfter(thisWeek)).length;
    final monthEvents = _events.where((e) => e.timestamp.isAfter(thisMonth)).length;

    return {
      'totalEvents': _events.length,
      'todayEvents': todayEvents,
      'weekEvents': weekEvents,
      'monthEvents': monthEvents,
      'currentSessionId': _currentSessionId,
      'sessionStartTime': _sessionStartTime,
      'userId': _userId,
      'userProperties': _userProperties.length,
    };
  }

  // Get events by category
  static List<AnalyticsEvent> getEventsByCategory(String category) {
    return _events.where((e) => e.category == category).toList();
  }

  // Get events by name
  static List<AnalyticsEvent> getEventsByName(String name) {
    return _events.where((e) => e.name == name).toList();
  }

  // Get events in date range
  static List<AnalyticsEvent> getEventsInDateRange(DateTime start, DateTime end) {
    return _events.where((e) => 
      e.timestamp.isAfter(start) && e.timestamp.isBefore(end)
    ).toList();
  }
}

// Analytics event
class AnalyticsEvent {
  final String name;
  final String category;
  final String action;
  final String? label;
  final int? value;
  final Map<String, dynamic>? parameters;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.name,
    required this.category,
    required this.action,
    this.label,
    this.value,
    this.parameters,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'action': action,
      'label': label,
      'value': value,
      'parameters': parameters,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      name: json['name'] as String,
      category: json['category'] as String,
      action: json['action'] as String,
      label: json['label'] as String?,
      value: json['value'] as int?,
      parameters: json['parameters'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}