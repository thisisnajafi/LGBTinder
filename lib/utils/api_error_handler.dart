import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'error_handler.dart';

class ApiErrorHandler {
  /// Handle API errors and show appropriate user messages
  static void handleApiError(BuildContext context, dynamic error, {
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    String message;
    String? title;
    Color? backgroundColor;
    
    if (error is AuthException) {
      title = 'Authentication Error';
      message = error.message;
      backgroundColor = Colors.orange;
    } else if (error is ValidationException) {
      title = 'Validation Error';
      message = error.message;
      backgroundColor = Colors.amber;
    } else if (error is RateLimitException) {
      title = 'Too Many Requests';
      message = error.message;
      backgroundColor = Colors.red;
    } else if (error is NetworkException) {
      title = 'Network Error';
      message = 'Please check your internet connection and try again.';
      backgroundColor = Colors.red;
    } else if (error is ApiException) {
      title = 'Server Error';
      message = error.message;
      backgroundColor = Colors.red;
    } else {
      title = 'Error';
      message = customMessage ?? 'An unexpected error occurred. Please try again.';
      backgroundColor = Colors.red;
    }
    
    _showErrorSnackBar(
      context,
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      onRetry: onRetry,
    );
  }
  
  /// Show error snackbar with retry option
  static void _showErrorSnackBar(
    BuildContext context, {
    required String title,
    required String message,
    Color? backgroundColor,
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? Colors.red,
        duration: const Duration(seconds: 5),
        action: onRetry != null ? SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: onRetry,
        ) : null,
      ),
    );
  }
  
  /// Handle HTTP response errors
  static void handleHttpError(BuildContext context, http.Response response, {
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    String message;
    String title;
    Color backgroundColor;
    
    switch (response.statusCode) {
      case 400:
        title = 'Bad Request';
        message = 'Invalid request. Please check your input and try again.';
        backgroundColor = Colors.amber;
        break;
      case 401:
        title = 'Authentication Required';
        message = 'Please log in to continue.';
        backgroundColor = Colors.orange;
        break;
      case 403:
        title = 'Access Denied';
        message = 'You don\'t have permission to perform this action.';
        backgroundColor = Colors.red;
        break;
      case 404:
        title = 'Not Found';
        message = 'The requested resource was not found.';
        backgroundColor = Colors.red;
        break;
      case 422:
        title = 'Validation Error';
        message = 'Please check your input and try again.';
        backgroundColor = Colors.amber;
        break;
      case 429:
        title = 'Too Many Requests';
        message = 'Please wait a moment before trying again.';
        backgroundColor = Colors.red;
        break;
      case 500:
        title = 'Server Error';
        message = 'Something went wrong on our end. Please try again later.';
        backgroundColor = Colors.red;
        break;
      case 502:
      case 503:
      case 504:
        title = 'Service Unavailable';
        message = 'The service is temporarily unavailable. Please try again later.';
        backgroundColor = Colors.red;
        break;
      default:
        title = 'Error';
        message = customMessage ?? 'An unexpected error occurred. Please try again.';
        backgroundColor = Colors.red;
    }
    
    _showErrorSnackBar(
      context,
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      onRetry: onRetry,
    );
  }
  
  /// Show success message
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Show loading indicator
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Hide loading indicator
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
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
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}
