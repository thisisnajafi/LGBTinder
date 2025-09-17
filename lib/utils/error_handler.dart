import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

/// Custom exception classes for different types of errors
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class ApiException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? responseData;

  ApiException(String message, {this.statusCode, this.responseData, String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  ValidationException(String message, this.fieldErrors, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class AuthException extends AppException {
  AuthException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class RateLimitException extends AppException {
  final int cooldownSeconds;

  RateLimitException(String message, {this.cooldownSeconds = 0, String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Error handler utility class
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// Handles different types of errors and returns user-friendly messages
  static String handleError(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (error is HttpException) {
      return 'Network error occurred. Please try again.';
    }

    if (error is FormatException) {
      return 'Invalid data format. Please try again.';
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }

    // Generic error message
    return 'Something went wrong. Please try again.';
  }

  /// Handles API errors with specific status codes
  static String handleApiError(int statusCode, [Map<String, dynamic>? responseData]) {
    switch (statusCode) {
      case 400:
        return _handleBadRequest(responseData);
      case 401:
        return 'Your session has expired. Please log in again.';
      case 403:
        return 'You don\'t have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'This resource already exists.';
      case 422:
        return _handleValidationError(responseData);
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Server error occurred. Please try again later.';
      case 502:
        return 'Service temporarily unavailable. Please try again later.';
      case 503:
        return 'Service is under maintenance. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Handles bad request errors (400)
  static String _handleBadRequest(Map<String, dynamic>? responseData) {
    if (responseData != null && responseData['message'] != null) {
      return responseData['message'];
    }
    return 'Invalid request. Please check your input and try again.';
  }

  /// Handles validation errors (422)
  static String _handleValidationError(Map<String, dynamic>? responseData) {
    if (responseData != null && responseData['errors'] != null) {
      final errors = responseData['errors'] as Map<String, dynamic>;
      if (errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first;
        } else if (firstError is String) {
          return firstError;
        }
      }
    }
    return 'Please check your input and try again.';
  }

  /// Checks if the device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Shows a user-friendly error dialog
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (actionText != null && onAction != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction();
              },
              child: Text(actionText),
            ),
        ],
      ),
    );
  }

  /// Shows a user-friendly error snackbar
  static void showErrorSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionText,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.red,
        action: actionText != null && onAction != null
            ? SnackBarAction(
                label: actionText,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  /// Shows a retry dialog for failed operations
  static Future<bool> showRetryDialog(
    BuildContext context, {
    required String message,
    String title = 'Operation Failed',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Shows a confirmation dialog for destructive actions
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : null,
              foregroundColor: isDestructive ? Colors.white : null,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Shows an offline mode indicator
  static void showOfflineIndicator(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 8),
            Text('You are offline. Some features may be limited.'),
          ],
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.orange,
      ),
    );
  }

  /// Shows a connection restored indicator
  static void showConnectionRestoredIndicator(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi, color: Colors.white),
            SizedBox(width: 8),
            Text('Connection restored!'),
          ],
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Logs errors for debugging (in production, this would send to a logging service)
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    // In a real app, this would send to a logging service like Firebase Crashlytics
    print('Error: $error');
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
  }

  /// Creates a retry mechanism for failed operations
  static Future<T> retryOperation<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;
        
        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }
        
        // If this is the last attempt, throw the error
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        // Wait before retrying
        await Future.delayed(delay * attempts); // Exponential backoff
      }
    }
    
    throw Exception('Operation failed after $maxRetries attempts');
  }

  /// Handles network connectivity changes (simplified version)
  static Stream<bool> get connectivityStream {
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      return await hasInternetConnection();
    }).asyncMap((future) => future);
  }

  /// Checks if an error is retryable
  static bool isRetryableError(dynamic error) {
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    if (error is HttpException) return true;
    
    if (error is ApiException) {
      final statusCode = error.statusCode;
      return statusCode == null || 
             statusCode >= 500 || 
             statusCode == 429; // Retry on server errors and rate limits
    }
    
    return false;
  }

  /// Gets a user-friendly error message for specific error types
  static String getErrorMessage(dynamic error) {
    if (error is ValidationException) {
      if (error.fieldErrors.isNotEmpty) {
        return error.fieldErrors.values.first;
      }
      return error.message;
    }
    
    if (error is AuthException) {
      return error.message;
    }
    
    if (error is NetworkException) {
      return error.message;
    }
    
    if (error is ApiException) {
      return handleApiError(error.statusCode ?? 0, error.responseData);
    }
    
    return handleError(error);
  }

  /// Shows a loading indicator with optional message
  static void showLoadingIndicator(
    BuildContext context, {
    String message = 'Loading...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Hides the loading indicator
  static void hideLoadingIndicator(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Shows a success message
  static void showSuccessMessage(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        duration: duration,
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Shows an info message
  static void showInfoMessage(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        duration: duration,
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Handles API response errors with detailed error information
  static Map<String, dynamic> parseApiErrorResponse(String responseBody) {
    try {
      final Map<String, dynamic> errorData = jsonDecode(responseBody);
      return errorData;
    } catch (e) {
      return {
        'message': 'Failed to parse error response',
        'error': e.toString(),
      };
    }
  }

  /// Creates a standardized error response for API calls
  static Map<String, dynamic> createErrorResponse({
    required String message,
    String? code,
    Map<String, String>? fieldErrors,
    dynamic originalError,
  }) {
    return {
      'success': false,
      'message': message,
      'code': code,
      'errors': fieldErrors,
      'timestamp': DateTime.now().toIso8601String(),
      'original_error': originalError?.toString(),
    };
  }

  /// Handles timeout errors with specific timeout types
  static String handleTimeoutError(Duration timeout) {
    if (timeout.inSeconds < 10) {
      return 'Request timed out quickly. Please check your connection.';
    } else if (timeout.inSeconds < 30) {
      return 'Request timed out. The server may be slow.';
    } else {
      return 'Request timed out after ${timeout.inSeconds} seconds. Please try again.';
    }
  }

  /// Handles specific HTTP status codes with detailed messages
  static String getDetailedErrorMessage(int statusCode, Map<String, dynamic>? responseData) {
    switch (statusCode) {
      case 400:
        return _getBadRequestMessage(responseData);
      case 401:
        return _getUnauthorizedMessage(responseData);
      case 403:
        return _getForbiddenMessage(responseData);
      case 404:
        return _getNotFoundMessage(responseData);
      case 409:
        return _getConflictMessage(responseData);
      case 422:
        return _getValidationErrorMessage(responseData);
      case 429:
        return _getRateLimitMessage(responseData);
      case 500:
        return _getServerErrorMessage(responseData);
      case 502:
        return 'Bad Gateway: The server received an invalid response from an upstream server.';
      case 503:
        return 'Service Unavailable: The server is temporarily unable to handle requests.';
      case 504:
        return 'Gateway Timeout: The server did not receive a timely response from an upstream server.';
      default:
        return 'HTTP Error $statusCode: An unexpected error occurred.';
    }
  }

  static String _getBadRequestMessage(Map<String, dynamic>? responseData) {
    if (responseData?['message'] != null) {
      return 'Bad Request: ${responseData!['message']}';
    }
    return 'Bad Request: The request was invalid or malformed.';
  }

  static String _getUnauthorizedMessage(Map<String, dynamic>? responseData) {
    if (responseData?['message'] != null) {
      return 'Unauthorized: ${responseData!['message']}';
    }
    return 'Unauthorized: Authentication is required to access this resource.';
  }

  static String _getForbiddenMessage(Map<String, dynamic>? responseData) {
    if (responseData?['message'] != null) {
      return 'Forbidden: ${responseData!['message']}';
    }
    return 'Forbidden: You do not have permission to access this resource.';
  }

  static String _getNotFoundMessage(Map<String, dynamic>? responseData) {
    if (responseData?['message'] != null) {
      return 'Not Found: ${responseData!['message']}';
    }
    return 'Not Found: The requested resource could not be found.';
  }

  static String _getConflictMessage(Map<String, dynamic>? responseData) {
    if (responseData?['message'] != null) {
      return 'Conflict: ${responseData!['message']}';
    }
    return 'Conflict: The request conflicts with the current state of the resource.';
  }

  static String _getValidationErrorMessage(Map<String, dynamic>? responseData) {
    if (responseData?['errors'] != null) {
      final errors = responseData!['errors'] as Map<String, dynamic>;
      if (errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return 'Validation Error: ${firstError.first}';
        } else if (firstError is String) {
          return 'Validation Error: $firstError';
        }
      }
    }
    return 'Validation Error: The provided data is invalid.';
  }

  static String _getRateLimitMessage(Map<String, dynamic>? responseData) {
    if (responseData?['retry_after'] != null) {
      final retryAfter = responseData!['retry_after'];
      return 'Rate Limited: Too many requests. Please wait $retryAfter seconds before trying again.';
    }
    return 'Rate Limited: Too many requests. Please wait a moment before trying again.';
  }

  static String _getServerErrorMessage(Map<String, dynamic>? responseData) {
    if (responseData?['message'] != null) {
      return 'Server Error: ${responseData!['message']}';
    }
    return 'Server Error: An internal server error occurred. Please try again later.';
  }

  /// Handles network connectivity errors with specific messages
  static String handleNetworkError(dynamic error) {
    if (error is SocketException) {
      if (error.osError?.errorCode == 7) {
        return 'No internet connection. Please check your network settings.';
      } else if (error.osError?.errorCode == 111) {
        return 'Connection refused. The server may be down.';
      } else {
        return 'Network error: ${error.message}';
      }
    }
    
    if (error is HttpException) {
      return 'HTTP error: ${error.message}';
    }
    
    if (error is FormatException) {
      return 'Data format error: ${error.message}';
    }
    
    return 'Network error occurred. Please try again.';
  }

  /// Creates a retry mechanism with exponential backoff
  static Future<T> retryWithExponentialBackoff<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    Duration maxDelay = const Duration(seconds: 30),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;
        
        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }
        
        // If this is the last attempt, throw the error
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        // Wait before retrying with exponential backoff
        await Future.delayed(delay);
        delay = Duration(
          milliseconds: (delay.inMilliseconds * backoffMultiplier).clamp(
            initialDelay.inMilliseconds,
            maxDelay.inMilliseconds,
          ).round(),
        );
      }
    }
    
    throw Exception('Operation failed after $maxRetries attempts');
  }

  /// Handles authentication errors with specific actions
  static Future<void> handleAuthError(BuildContext context, AuthException error) async {
    if (error.code == 'TOKEN_EXPIRED') {
      // Show dialog to re-authenticate
      await showErrorDialog(
        context,
        title: 'Session Expired',
        message: 'Your session has expired. Please log in again.',
        actionText: 'Login',
        onAction: () {
          // Navigate to login screen
          Navigator.of(context).pushReplacementNamed('/login');
        },
      );
    } else if (error.code == 'INVALID_CREDENTIALS') {
      showErrorSnackBar(
        context,
        message: 'Invalid email or password. Please try again.',
      );
    } else {
      showErrorSnackBar(
        context,
        message: error.message,
      );
    }
  }

  /// Handles validation errors with field-specific messages
  static void handleValidationError(BuildContext context, ValidationException error) {
    if (error.fieldErrors.isNotEmpty) {
      final firstError = error.fieldErrors.values.first;
      showErrorSnackBar(
        context,
        message: firstError,
      );
    } else {
      showErrorSnackBar(
        context,
        message: error.message,
      );
    }
  }

  /// Handles rate limit errors with cooldown information
  static void handleRateLimitError(BuildContext context, RateLimitException error) {
    final cooldownMinutes = (error.cooldownSeconds / 60).ceil();
    showErrorSnackBar(
      context,
      message: 'Rate limit exceeded. Please wait $cooldownMinutes minutes before trying again.',
      duration: const Duration(seconds: 6),
    );
  }

  /// Creates a comprehensive error report for debugging
  static Map<String, dynamic> createErrorReport({
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? userId,
    String? sessionId,
  }) {
    return {
      'error': {
        'type': error.runtimeType.toString(),
        'message': error.toString(),
        'stack_trace': stackTrace?.toString(),
      },
      'context': context ?? {},
      'user_id': userId,
      'session_id': sessionId,
      'timestamp': DateTime.now().toIso8601String(),
      'app_version': '1.0.0', // This should come from app config
      'platform': Platform.operatingSystem,
    };
  }

  /// Handles errors in background operations
  static void handleBackgroundError(dynamic error, StackTrace stackTrace) {
    // Log error for debugging
    logError(error, stackTrace);
    
    // In production, send to crash reporting service
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  /// Validates error response format
  static bool isValidErrorResponse(Map<String, dynamic> response) {
    return response.containsKey('message') && 
           response['message'] is String &&
           response['message'].isNotEmpty;
  }

  /// Extracts error code from response
  static String? extractErrorCode(Map<String, dynamic> response) {
    return response['code'] as String?;
  }

  /// Extracts field errors from validation response
  static Map<String, String> extractFieldErrors(Map<String, dynamic> response) {
    final errors = response['errors'] as Map<String, dynamic>?;
    if (errors == null) return {};
    
    final fieldErrors = <String, String>{};
    errors.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        fieldErrors[key] = value.first.toString();
      } else if (value is String) {
        fieldErrors[key] = value;
      }
    });
    
    return fieldErrors;
  }
} 