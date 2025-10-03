import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/secure_error_handler.dart';

/// A utility class for showing consistent error snackbars across the app
class ErrorSnackBar {
  static void show(
    BuildContext context, {
    required dynamic error,
    String? context,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onAction,
    String? actionText,
  }) {
    final authError = SecureErrorHandler.handleError(error, context: context);
    final userMessage = SecureErrorHandler.createUserFriendlyMessage(authError);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(authError.type),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                userMessage,
                style: AppTypography.body2.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(authError.type),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: onAction != null && actionText != null
            ? SnackBarAction(
                label: actionText,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionText,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.body2.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: onAction != null && actionText != null
            ? SnackBarAction(
                label: actionText,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionText,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.body2.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: onAction != null && actionText != null
            ? SnackBarAction(
                label: actionText,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionText,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.body2.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.info,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: onAction != null && actionText != null
            ? SnackBarAction(
                label: actionText,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static IconData _getErrorIcon(String errorType) {
    switch (errorType) {
      case 'network_error':
        return Icons.wifi_off;
      case 'server_error':
        return Icons.api;
      case 'validation_error':
        return Icons.warning;
      case 'authentication_error':
        return Icons.lock;
      case 'authorization_error':
        return Icons.block;
      case 'rate_limit_error':
        return Icons.schedule;
      default:
        return Icons.error_outline;
    }
  }

  static Color _getErrorColor(String errorType) {
    switch (errorType) {
      case 'network_error':
        return AppColors.warning;
      case 'server_error':
        return AppColors.error;
      case 'validation_error':
        return AppColors.warning;
      case 'authentication_error':
        return AppColors.error;
      case 'authorization_error':
        return AppColors.error;
      case 'rate_limit_error':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }
}
