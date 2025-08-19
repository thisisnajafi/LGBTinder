import 'package:flutter/material.dart';

class ErrorHandler {
  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Handle API response and show appropriate message
  static void handleApiResponse(BuildContext context, Map<String, dynamic> response) {
    if (response['success'] == true) {
      if (response['message'] != null && response['message'] != 'Success') {
        showSuccessSnackBar(context, response['message']);
      }
    } else {
      final message = response['message'] ?? 'An error occurred';
      showErrorSnackBar(context, message);
    }
  }

  // Get user-friendly error message based on status code
  static String getErrorMessage(int statusCode, [String? customMessage]) {
    if (customMessage != null) return customMessage;

    switch (statusCode) {
      case 400:
        return 'Bad Request – Please check the request data and try again.';
      case 401:
        return 'Unauthorized – Please login to continue.';
      case 403:
        return 'Access Denied – You do not have permission to perform this action.';
      case 404:
        return 'Not Found – The requested resource does not exist.';
      case 422:
        return 'Validation Error – Please check your input and try again.';
      case 500:
        return 'Server Error – Something went wrong, please try again later.';
      case 0:
        return 'Network Error – Please check your internet connection and try again.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  // Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
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
        );
      },
    );
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  // Handle authentication errors
  static void handleAuthError(BuildContext context, Map<String, dynamic> response) {
    if (response['statusCode'] == 401) {
      showErrorDialog(
        context,
        title: 'Authentication Required',
        message: 'Your session has expired. Please login again.',
        actionText: 'Login',
        onAction: () {
          // Navigate to login screen
          Navigator.of(context).pushReplacementNamed('/login');
        },
      );
    } else {
      handleApiResponse(context, response);
    }
  }

  // Handle network errors
  static void handleNetworkError(BuildContext context, String error) {
    showErrorDialog(
      context,
      title: 'Connection Error',
      message: 'Unable to connect to the server. Please check your internet connection and try again.',
      actionText: 'Retry',
      onAction: () {
        // You can implement retry logic here
        Navigator.of(context).pop();
      },
    );
  }

  // Log error for debugging
  static void logError(String method, String error, [Map<String, dynamic>? context]) {
    print('❌ Error in $method: $error');
    if (context != null) {
      print('Context: $context');
    }
  }

  // Log success for debugging
  static void logSuccess(String method, [Map<String, dynamic>? data]) {
    print('✅ Success in $method');
    if (data != null) {
      print('Data: $data');
    }
  }
} 