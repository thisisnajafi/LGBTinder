import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment_config.dart';
import '../models/user_state_models.dart';

class ErrorMonitoringService {
  static const String _errorLogKey = 'error_logs';
  static const String _crashLogKey = 'crash_logs';
  static const String _performanceLogKey = 'performance_logs';
  static const int _maxLogEntries = 1000;
  static const int _maxLogFileSize = 10 * 1024 * 1024; // 10MB

  // Error tracking
  static final List<ErrorLogEntry> _errorLogs = [];
  static final List<CrashLogEntry> _crashLogs = [];
  static final List<PerformanceLogEntry> _performanceLogs = [];

  // Initialize error monitoring
  static Future<void> initialize() async {
    if (EnvironmentConfig.enableCrashReporting) {
      await _loadStoredLogs();
      _setupCrashHandler();
    }
  }

  // Log generic error
  static Future<void> logError({
    required String message,
    String errorType = 'generic',
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    Map<String, dynamic>? details,
    String? userId,
  }) async {
    if (!EnvironmentConfig.enableCrashReporting) return;

    final errorLog = ErrorLogEntry(
      id: _generateId(),
      timestamp: DateTime.now(),
      type: ErrorType.generic,
      errorMessage: message,
      stackTrace: stackTrace?.toString(),
      userId: userId,
      context: context,
      details: details != null ? json.encode(details) : null,
      appVersion: '1.0.0',
      environment: 'development',
    );

    _errorLogs.add(errorLog);
    await _saveErrorLogs();
  }

  // Save error logs to storage
  static Future<void> _saveErrorLogs() async {
    if (!EnvironmentConfig.enableCrashReporting) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_errorLogs.map((log) => log.toJson()).toList());
      await prefs.setString(_errorLogKey, jsonString);
    } catch (e) {
      // Handle error silently to avoid infinite loops
      debugPrint('Failed to save error logs: $e');
    }
  }

  // Log API error
  static Future<void> logApiError({
    required String endpoint,
    required String method,
    required int statusCode,
    required String errorMessage,
    required String requestId,
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
    StackTrace? stackTrace,
  }) async {
    final errorLog = ErrorLogEntry(
      id: _generateId(),
      timestamp: DateTime.now(),
      type: ErrorType.apiError,
      endpoint: endpoint,
      method: method,
      statusCode: statusCode,
      errorMessage: errorMessage,
      requestId: requestId,
      requestData: requestData,
      responseData: responseData,
      stackTrace: stackTrace?.toString(),
      environment: EnvironmentConfig.environmentName,
      appVersion: EnvironmentConfig.appVersion,
    );

    _errorLogs.add(errorLog);
    await _storeErrorLog(errorLog);

    if (EnvironmentConfig.enableCrashReporting) {
      await _sendErrorToRemote(errorLog);
    }

    if (kDebugMode) {
      print('API Error logged: $endpoint - $errorMessage');
    }
  }

  // Log authentication error
  static Future<void> logAuthError({
    required AuthErrorType errorType,
    required String errorMessage,
    String? details,
    String? userId,
    Map<String, dynamic>? context,
  }) async {
    final errorLog = ErrorLogEntry(
      id: _generateId(),
      timestamp: DateTime.now(),
      type: ErrorType.authError,
      errorMessage: errorMessage,
      details: details,
      userId: userId,
      context: context,
      environment: EnvironmentConfig.environmentName,
      appVersion: EnvironmentConfig.appVersion,
    );

    _errorLogs.add(errorLog);
    await _storeErrorLog(errorLog);

    if (EnvironmentConfig.enableCrashReporting) {
      await _sendErrorToRemote(errorLog);
    }

    if (kDebugMode) {
      print('Auth Error logged: $errorType - $errorMessage');
    }
  }

  // Log validation error
  static Future<void> logValidationError({
    required String field,
    required String errorMessage,
    String? value,
    Map<String, dynamic>? context,
  }) async {
    final errorLog = ErrorLogEntry(
      id: _generateId(),
      timestamp: DateTime.now(),
      type: ErrorType.validationError,
      errorMessage: errorMessage,
      details: 'Field: $field, Value: $value',
      context: context,
      environment: EnvironmentConfig.environmentName,
      appVersion: EnvironmentConfig.appVersion,
    );

    _errorLogs.add(errorLog);
    await _storeErrorLog(errorLog);

    if (kDebugMode) {
      print('Validation Error logged: $field - $errorMessage');
    }
  }

  // Log network error
  static Future<void> logNetworkError({
    required String endpoint,
    required String errorMessage,
    required String requestId,
    Map<String, dynamic>? context,
  }) async {
    final errorLog = ErrorLogEntry(
      id: _generateId(),
      timestamp: DateTime.now(),
      type: ErrorType.networkError,
      endpoint: endpoint,
      errorMessage: errorMessage,
      requestId: requestId,
      context: context,
      environment: EnvironmentConfig.environmentName,
      appVersion: EnvironmentConfig.appVersion,
    );

    _errorLogs.add(errorLog);
    await _storeErrorLog(errorLog);

    if (EnvironmentConfig.enableCrashReporting) {
      await _sendErrorToRemote(errorLog);
    }

    if (kDebugMode) {
      print('Network Error logged: $endpoint - $errorMessage');
    }
  }

  // Log crash
  static Future<void> logCrash({
    required String errorMessage,
    required StackTrace stackTrace,
    Map<String, dynamic>? context,
  }) async {
    final crashLog = CrashLogEntry(
      id: _generateId(),
      timestamp: DateTime.now(),
      errorMessage: errorMessage,
      stackTrace: stackTrace.toString(),
      context: context,
      environment: EnvironmentConfig.environmentName,
      appVersion: EnvironmentConfig.appVersion,
    );

    _crashLogs.add(crashLog);
    await _storeCrashLog(crashLog);

    if (EnvironmentConfig.enableCrashReporting) {
      await _sendCrashToRemote(crashLog);
    }

    if (kDebugMode) {
      print('Crash logged: $errorMessage');
    }
  }

  // Log performance issue
  static Future<void> logPerformanceIssue({
    required String operation,
    required Duration duration,
    required String threshold,
    Map<String, dynamic>? context,
  }) async {
    final performanceLog = PerformanceLogEntry(
      id: _generateId(),
      timestamp: DateTime.now(),
      operation: operation,
      duration: duration.inMilliseconds,
      threshold: threshold,
      context: context,
      environment: EnvironmentConfig.environmentName,
      appVersion: EnvironmentConfig.appVersion,
    );

    _performanceLogs.add(performanceLog);
    await _storePerformanceLog(performanceLog);

    if (EnvironmentConfig.enablePerformanceMonitoring) {
      await _sendPerformanceToRemote(performanceLog);
    }

    if (kDebugMode) {
      print('Performance Issue logged: $operation - ${duration.inMilliseconds}ms');
    }
  }

  // Log user action
  static Future<void> logUserAction({
    required String action,
    required String screen,
    Map<String, dynamic>? parameters,
  }) async {
    final actionLog = ErrorLogEntry(
      id: _generateId(),
      timestamp: DateTime.now(),
      type: ErrorType.userAction,
      errorMessage: action,
      details: 'Screen: $screen',
      context: parameters,
      environment: EnvironmentConfig.environmentName,
      appVersion: EnvironmentConfig.appVersion,
    );

    _errorLogs.add(actionLog);
    await _storeErrorLog(actionLog);

    if (kDebugMode) {
      print('User Action logged: $action on $screen');
    }
  }

  // Setup crash handler
  static void _setupCrashHandler() {
    FlutterError.onError = (FlutterErrorDetails details) {
      logCrash(
        errorMessage: details.exception.toString(),
        stackTrace: details.stack ?? StackTrace.current,
        context: {
          'library': details.library,
          'context': details.context?.toString(),
        },
      );
    };
  }

  // Store error log locally
  static Future<void> _storeErrorLog(ErrorLogEntry errorLog) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingLogs = prefs.getStringList(_errorLogKey) ?? [];
      
      existingLogs.add(jsonEncode(errorLog.toJson()));
      
      // Limit number of stored logs
      if (existingLogs.length > _maxLogEntries) {
        existingLogs.removeRange(0, existingLogs.length - _maxLogEntries);
      }
      
      await prefs.setStringList(_errorLogKey, existingLogs);
    } catch (e) {
      if (kDebugMode) {
        print('Error storing error log: $e');
      }
    }
  }

  // Store crash log locally
  static Future<void> _storeCrashLog(CrashLogEntry crashLog) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingLogs = prefs.getStringList(_crashLogKey) ?? [];
      
      existingLogs.add(jsonEncode(crashLog.toJson()));
      
      // Limit number of stored logs
      if (existingLogs.length > _maxLogEntries) {
        existingLogs.removeRange(0, existingLogs.length - _maxLogEntries);
      }
      
      await prefs.setStringList(_crashLogKey, existingLogs);
    } catch (e) {
      if (kDebugMode) {
        print('Error storing crash log: $e');
      }
    }
  }

  // Store performance log locally
  static Future<void> _storePerformanceLog(PerformanceLogEntry performanceLog) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingLogs = prefs.getStringList(_performanceLogKey) ?? [];
      
      existingLogs.add(jsonEncode(performanceLog.toJson()));
      
      // Limit number of stored logs
      if (existingLogs.length > _maxLogEntries) {
        existingLogs.removeRange(0, existingLogs.length - _maxLogEntries);
      }
      
      await prefs.setStringList(_performanceLogKey, existingLogs);
    } catch (e) {
      if (kDebugMode) {
        print('Error storing performance log: $e');
      }
    }
  }

  // Load stored logs
  static Future<void> _loadStoredLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load error logs
      final errorLogs = prefs.getStringList(_errorLogKey) ?? [];
      for (final logJson in errorLogs) {
        try {
          final logData = jsonDecode(logJson) as Map<String, dynamic>;
          _errorLogs.add(ErrorLogEntry.fromJson(logData));
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing error log: $e');
          }
        }
      }
      
      // Load crash logs
      final crashLogs = prefs.getStringList(_crashLogKey) ?? [];
      for (final logJson in crashLogs) {
        try {
          final logData = jsonDecode(logJson) as Map<String, dynamic>;
          _crashLogs.add(CrashLogEntry.fromJson(logData));
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing crash log: $e');
          }
        }
      }
      
      // Load performance logs
      final performanceLogs = prefs.getStringList(_performanceLogKey) ?? [];
      for (final logJson in performanceLogs) {
        try {
          final logData = jsonDecode(logJson) as Map<String, dynamic>;
          _performanceLogs.add(PerformanceLogEntry.fromJson(logData));
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing performance log: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading stored logs: $e');
      }
    }
  }

  // Send error to remote monitoring service
  static Future<void> _sendErrorToRemote(ErrorLogEntry errorLog) async {
    try {
      // This would typically send to a service like Sentry, Crashlytics, etc.
      // For now, we'll just log it
      if (kDebugMode) {
        print('Sending error to remote monitoring: ${errorLog.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending error to remote: $e');
      }
    }
  }

  // Send crash to remote monitoring service
  static Future<void> _sendCrashToRemote(CrashLogEntry crashLog) async {
    try {
      // This would typically send to a service like Sentry, Crashlytics, etc.
      // For now, we'll just log it
      if (kDebugMode) {
        print('Sending crash to remote monitoring: ${crashLog.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending crash to remote: $e');
      }
    }
  }

  // Send performance data to remote monitoring service
  static Future<void> _sendPerformanceToRemote(PerformanceLogEntry performanceLog) async {
    try {
      // This would typically send to a service like Firebase Performance, etc.
      // For now, we'll just log it
      if (kDebugMode) {
        print('Sending performance data to remote monitoring: ${performanceLog.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending performance data to remote: $e');
      }
    }
  }

  // Get error logs
  static List<ErrorLogEntry> getErrorLogs() => List.unmodifiable(_errorLogs);

  // Get crash logs
  static List<CrashLogEntry> getCrashLogs() => List.unmodifiable(_crashLogs);

  // Get performance logs
  static List<PerformanceLogEntry> getPerformanceLogs() => List.unmodifiable(_performanceLogs);

  // Clear all logs
  static Future<void> clearAllLogs() async {
    _errorLogs.clear();
    _crashLogs.clear();
    _performanceLogs.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_errorLogKey);
    await prefs.remove(_crashLogKey);
    await prefs.remove(_performanceLogKey);
  }

  // Generate unique ID
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (1000 + (DateTime.now().microsecond % 9000)).toString();
  }

  // Get log statistics
  static Map<String, dynamic> getLogStatistics() {
    return {
      'errorLogs': _errorLogs.length,
      'crashLogs': _crashLogs.length,
      'performanceLogs': _performanceLogs.length,
      'totalLogs': _errorLogs.length + _crashLogs.length + _performanceLogs.length,
      'oldestLog': _errorLogs.isNotEmpty ? _errorLogs.first.timestamp : null,
      'newestLog': _errorLogs.isNotEmpty ? _errorLogs.last.timestamp : null,
    };
  }
}

// Error types
enum ErrorType {
  generic,
  apiError,
  authError,
  validationError,
  networkError,
  userAction,
  systemError,
}

// Error log entry
class ErrorLogEntry {
  final String id;
  final DateTime timestamp;
  final ErrorType type;
  final String? endpoint;
  final String? method;
  final int? statusCode;
  final String errorMessage;
  final String? requestId;
  final Map<String, dynamic>? requestData;
  final Map<String, dynamic>? responseData;
  final String? stackTrace;
  final String? details;
  final String? userId;
  final Map<String, dynamic>? context;
  final String environment;
  final String appVersion;

  ErrorLogEntry({
    required this.id,
    required this.timestamp,
    required this.type,
    this.endpoint,
    this.method,
    this.statusCode,
    required this.errorMessage,
    this.requestId,
    this.requestData,
    this.responseData,
    this.stackTrace,
    this.details,
    this.userId,
    this.context,
    required this.environment,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      'endpoint': endpoint,
      'method': method,
      'statusCode': statusCode,
      'errorMessage': errorMessage,
      'requestId': requestId,
      'requestData': requestData,
      'responseData': responseData,
      'stackTrace': stackTrace,
      'details': details,
      'userId': userId,
      'context': context,
      'environment': environment,
      'appVersion': appVersion,
    };
  }

  factory ErrorLogEntry.fromJson(Map<String, dynamic> json) {
    return ErrorLogEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: ErrorType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ErrorType.systemError,
      ),
      endpoint: json['endpoint'] as String?,
      method: json['method'] as String?,
      statusCode: json['statusCode'] as int?,
      errorMessage: json['errorMessage'] as String,
      requestId: json['requestId'] as String?,
      requestData: json['requestData'] as Map<String, dynamic>?,
      responseData: json['responseData'] as Map<String, dynamic>?,
      stackTrace: json['stackTrace'] as String?,
      details: json['details'] as String?,
      userId: json['userId'] as String?,
      context: json['context'] as Map<String, dynamic>?,
      environment: json['environment'] as String,
      appVersion: json['appVersion'] as String,
    );
  }
}

// Crash log entry
class CrashLogEntry {
  final String id;
  final DateTime timestamp;
  final String errorMessage;
  final String stackTrace;
  final Map<String, dynamic>? context;
  final String environment;
  final String appVersion;

  CrashLogEntry({
    required this.id,
    required this.timestamp,
    required this.errorMessage,
    required this.stackTrace,
    this.context,
    required this.environment,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'errorMessage': errorMessage,
      'stackTrace': stackTrace,
      'context': context,
      'environment': environment,
      'appVersion': appVersion,
    };
  }

  factory CrashLogEntry.fromJson(Map<String, dynamic> json) {
    return CrashLogEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      errorMessage: json['errorMessage'] as String,
      stackTrace: json['stackTrace'] as String,
      context: json['context'] as Map<String, dynamic>?,
      environment: json['environment'] as String,
      appVersion: json['appVersion'] as String,
    );
  }
}

// Performance log entry
class PerformanceLogEntry {
  final String id;
  final DateTime timestamp;
  final String operation;
  final int duration; // in milliseconds
  final String threshold;
  final Map<String, dynamic>? context;
  final String environment;
  final String appVersion;

  PerformanceLogEntry({
    required this.id,
    required this.timestamp,
    required this.operation,
    required this.duration,
    required this.threshold,
    this.context,
    required this.environment,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'operation': operation,
      'duration': duration,
      'threshold': threshold,
      'context': context,
      'environment': environment,
      'appVersion': appVersion,
    };
  }

  factory PerformanceLogEntry.fromJson(Map<String, dynamic> json) {
    return PerformanceLogEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      operation: json['operation'] as String,
      duration: json['duration'] as int,
      threshold: json['threshold'] as String,
      context: json['context'] as Map<String, dynamic>?,
      environment: json['environment'] as String,
      appVersion: json['appVersion'] as String,
    );
  }
}
