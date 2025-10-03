import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_state_models.dart';

class SecureErrorHandler {
  // Sensitive patterns that should be redacted from error messages
  static const List<String> _sensitivePatterns = [
    'password',
    'token',
    'secret',
    'key',
    'auth',
    'credential',
    'session',
    'cookie',
    'jwt',
    'bearer',
    'api_key',
    'private',
    'confidential',
  ];

  // Network error patterns
  static const List<String> _networkErrorPatterns = [
    'socket',
    'connection',
    'timeout',
    'network',
    'dns',
    'ssl',
    'certificate',
    'handshake',
  ];

  // Server error patterns
  static const List<String> _serverErrorPatterns = [
    'database',
    'sql',
    'query',
    'table',
    'column',
    'constraint',
    'foreign key',
    'primary key',
    'index',
    'migration',
    'seed',
  ];

  // Handle and sanitize errors
  static AuthError handleError(dynamic error, {String? context}) {
    if (error is AuthError) {
      return _sanitizeAuthError(error);
    }

    if (error is SocketException) {
      return _handleNetworkError(error, context);
    }

    if (error is HttpException) {
      return _handleHttpError(error, context);
    }

    if (error is FormatException) {
      return _handleFormatError(error, context);
    }

    if (error is TimeoutException) {
      return _handleTimeoutError(error, context);
    }

    // Generic error handling
    return _handleGenericError(error, context);
  }

  // Sanitize AuthError to remove sensitive information
  static AuthError _sanitizeAuthError(AuthError error) {
    return AuthError(
      type: error.type,
      message: _sanitizeMessage(error.message),
      details: error.details,
    );
  }

  // Handle network errors
  static AuthError _handleNetworkError(SocketException error, String? context) {
    String message = 'Network connection failed';
    String? details;

    if (error.message.contains('Connection refused')) {
      message = 'Unable to connect to server';
      details = 'Please check your internet connection and try again';
    } else if (error.message.contains('Network is unreachable')) {
      message = 'Network unreachable';
      details = 'Please check your internet connection';
    } else if (error.message.contains('No route to host')) {
      message = 'Server unreachable';
      details = 'The server may be temporarily unavailable';
    } else {
      details = 'Network connectivity issue';
    }

    return AuthError(
      type: AuthErrorType.networkError,
      message: message,
      details: details != null ? {'message': details} : null,
    );
  }

  // Handle HTTP errors
  static AuthError _handleHttpError(HttpException error, String? context) {
    String message = 'HTTP request failed';
    String? details;

    if (error.message.contains('404')) {
      message = 'Resource not found';
      details = 'The requested resource could not be found';
    } else if (error.message.contains('403')) {
      message = 'Access denied';
      details = 'You do not have permission to access this resource';
    } else if (error.message.contains('401')) {
      message = 'Authentication required';
      details = 'Please log in to continue';
    } else if (error.message.contains('500')) {
      message = 'Server error';
      details = 'The server encountered an unexpected error';
    } else if (error.message.contains('503')) {
      message = 'Service unavailable';
      details = 'The service is temporarily unavailable';
    } else {
      details = 'HTTP request failed';
    }

    return AuthError(
      type: AuthErrorType.serverError,
      message: message,
      details: details != null ? {'message': details} : null,
    );
  }

  // Handle format errors
  static AuthError _handleFormatError(FormatException error, String? context) {
    return AuthError(
      type: AuthErrorType.validationError,
      message: 'Invalid data format',
      details: {'message': 'The data received is not in the expected format'},
    );
  }

  // Handle timeout errors
  static AuthError _handleTimeoutError(TimeoutException error, String? context) {
    return AuthError(
      type: AuthErrorType.networkError,
      message: 'Request timeout',
      details: {'message': 'The request took too long to complete. Please try again.'},
    );
  }

  // Handle generic errors
  static AuthError _handleGenericError(dynamic error, String? context) {
    String errorString = error.toString();
    
    // Check for sensitive information
    if (_containsSensitiveInfo(errorString)) {
      return AuthError(
        type: AuthErrorType.unknownError,
        message: 'An unexpected error occurred',
        details: {'message': 'Please try again or contact support if the problem persists'},
      );
    }

    // Check for network-related errors
    if (_isNetworkError(errorString)) {
      return AuthError(
        type: AuthErrorType.networkError,
        message: 'Network error',
        details: {'message': 'Please check your internet connection and try again'},
      );
    }

    // Check for server-related errors
    if (_isServerError(errorString)) {
      return AuthError(
        type: AuthErrorType.serverError,
        message: 'Server error',
        details: {'message': 'The server encountered an error. Please try again later'},
      );
    }

    // Generic error message
    return AuthError(
      type: AuthErrorType.unknownError,
      message: 'An unexpected error occurred',
      details: {'message': 'Please try again or contact support if the problem persists'},
    );
  }

  // Sanitize error messages to remove sensitive information
  static String _sanitizeMessage(String message) {
    String sanitized = message;
    
    for (String pattern in _sensitivePatterns) {
      // Replace sensitive patterns with [REDACTED]
      final regex = RegExp(pattern, caseSensitive: false);
      sanitized = sanitized.replaceAll(regex, '[REDACTED]');
    }

    // Remove any remaining sensitive-looking patterns
    sanitized = _removeSensitivePatterns(sanitized);
    
    return sanitized;
  }

  // Remove sensitive patterns from error messages
  static String _removeSensitivePatterns(String message) {
    // Remove email addresses
    message = message.replaceAll(RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), '[EMAIL]');
    
    // Remove phone numbers
    message = message.replaceAll(RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'), '[PHONE]');
    
    // Remove credit card numbers
    message = message.replaceAll(RegExp(r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b'), '[CARD]');
    
    // Remove SSN patterns
    message = message.replaceAll(RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), '[SSN]');
    
    // Remove API keys (common patterns)
    message = message.replaceAll(RegExp(r'\b[A-Za-z0-9]{32,}\b'), '[KEY]');
    
    // Remove file paths that might contain sensitive info
    message = message.replaceAll(RegExp(r'[A-Za-z]:\\[^\\]+\\[^\\]+'), '[PATH]');
    message = message.replaceAll(RegExp(r'/[^/]+/[^/]+'), '[PATH]');
    
    return message;
  }

  // Check if error contains sensitive information
  static bool _containsSensitiveInfo(String error) {
    final lowerError = error.toLowerCase();
    return _sensitivePatterns.any((pattern) => lowerError.contains(pattern));
  }

  // Check if error is network-related
  static bool _isNetworkError(String error) {
    final lowerError = error.toLowerCase();
    return _networkErrorPatterns.any((pattern) => lowerError.contains(pattern));
  }

  // Check if error is server-related
  static bool _isServerError(String error) {
    final lowerError = error.toLowerCase();
    return _serverErrorPatterns.any((pattern) => lowerError.contains(pattern));
  }

  // Log error securely (only in debug mode)
  static void logError(dynamic error, {String? context, StackTrace? stackTrace}) {
    if (kDebugMode) {
      final sanitizedError = handleError(error, context: context);
      print('Error in $context: ${sanitizedError.message}');
      if (sanitizedError.details != null) {
        print('Details: ${sanitizedError.details}');
      }
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
  }

  // Create user-friendly error message
  static String createUserFriendlyMessage(AuthError error) {
    switch (error.type) {
      case AuthErrorType.networkError:
        return 'Please check your internet connection and try again.';
      case AuthErrorType.validationError:
        return 'Please check your input and try again.';
      case AuthErrorType.serverError:
        return 'The server is experiencing issues. Please try again later.';
      case AuthErrorType.emailNotSent:
        return 'Unable to send email. Please try again.';
      case AuthErrorType.invalidCode:
        return 'The verification code is incorrect. Please try again.';
      case AuthErrorType.userBanned:
        return 'Your account has been suspended. Please contact support.';
      case AuthErrorType.unknownError:
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  // Check if error should be reported to analytics
  static bool shouldReportError(AuthError error) {
    // Don't report validation errors or user-specific errors
    return error.type != AuthErrorType.validationError && 
           error.type != AuthErrorType.invalidCode &&
           error.type != AuthErrorType.userBanned;
  }

  // Get error category for analytics
  static String getErrorCategory(AuthError error) {
    switch (error.type) {
      case AuthErrorType.networkError:
        return 'network';
      case AuthErrorType.validationError:
        return 'validation';
      case AuthErrorType.serverError:
        return 'server';
      case AuthErrorType.emailNotSent:
        return 'email';
      case AuthErrorType.invalidCode:
        return 'authentication';
      case AuthErrorType.userBanned:
        return 'account';
      case AuthErrorType.unknownError:
      default:
        return 'unknown';
    }
  }
}
