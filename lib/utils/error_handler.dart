import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

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
} 