import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/user_state_models.dart';

/// Error handling widget that displays user-friendly error messages
class ErrorHandlingWidget extends StatelessWidget {
  final AuthError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorHandlingWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                _getErrorIcon(),
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getErrorTitle(),
                  style: AppTypography.h3.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            error.message,
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          if (error.details != null) ...[
            const SizedBox(height: 8),
            _buildErrorDetails(),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: AppTypography.button.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (error.type) {
      case AuthErrorType.networkError:
        return Icons.wifi_off;
      case AuthErrorType.validationError:
        return Icons.error_outline;
      case AuthErrorType.serverError:
        return Icons.server_error;
      case AuthErrorType.emailNotSent:
        return Icons.email_outlined;
      case AuthErrorType.invalidCode:
        return Icons.lock_outline;
      case AuthErrorType.userBanned:
        return Icons.block;
      case AuthErrorType.unknownError:
      default:
        return Icons.error;
    }
  }

  String _getErrorTitle() {
    switch (error.type) {
      case AuthErrorType.networkError:
        return 'Network Error';
      case AuthErrorType.validationError:
        return 'Validation Error';
      case AuthErrorType.serverError:
        return 'Server Error';
      case AuthErrorType.emailNotSent:
        return 'Email Issue';
      case AuthErrorType.invalidCode:
        return 'Invalid Code';
      case AuthErrorType.userBanned:
        return 'Account Banned';
      case AuthErrorType.unknownError:
      default:
        return 'Error';
    }
  }

  Widget _buildErrorDetails() {
    if (error.details == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.appBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: error.details!.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• ${entry.key}: ${entry.value}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Error dialog that shows authentication errors
class ErrorDialog {
  static void show(
    BuildContext context,
    AuthError error, {
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: ErrorHandlingWidget(
          error: error,
          onRetry: onRetry,
          onDismiss: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

/// Error snackbar that shows authentication errors
class ErrorSnackbar {
  static void show(
    BuildContext context,
    AuthError error, {
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(error.type),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error.message,
                style: AppTypography.body2.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  static IconData _getErrorIcon(AuthErrorType type) {
    switch (type) {
      case AuthErrorType.networkError:
        return Icons.wifi_off;
      case AuthErrorType.validationError:
        return Icons.error_outline;
      case AuthErrorType.serverError:
        return Icons.server_error;
      case AuthErrorType.emailNotSent:
        return Icons.email_outlined;
      case AuthErrorType.invalidCode:
        return Icons.lock_outline;
      case AuthErrorType.userBanned:
        return Icons.block;
      case AuthErrorType.unknownError:
      default:
        return Icons.error;
    }
  }
}

/// Loading overlay that shows during async operations
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackgroundDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textPrimaryDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
