import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/secure_error_handler.dart';
import '../../models/api_models/common_models.dart';

/// A reusable widget for displaying API errors consistently across the app
class ErrorDisplayWidget extends StatelessWidget {
  final dynamic error;
  final String? context;
  final VoidCallback? onRetry;
  final String? retryText;
  final bool showDetails;
  final bool isFullScreen;

  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.context,
    this.onRetry,
    this.retryText = 'Try Again',
    this.showDetails = false,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final authError = SecureErrorHandler.handleError(error, context: this.context);
    final userMessage = SecureErrorHandler.createUserFriendlyMessage(authError);

    if (isFullScreen) {
      return _buildFullScreenError(userMessage);
    }

    return _buildInlineError(userMessage);
  }

  Widget _buildFullScreenError(String message) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getErrorIcon(),
                size: 80,
                color: AppColors.error,
              ),
              const SizedBox(height: 24),
              Text(
                _getErrorTitle(),
                style: AppTypography.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (showDetails) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    error.toString(),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    retryText!,
                    style: AppTypography.button.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInlineError(String message) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error',
                  style: AppTypography.subtitle2.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.body2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                retryText!,
                style: AppTypography.button.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getErrorIcon() {
    if (error is NetworkException) {
      return Icons.wifi_off;
    } else if (error is ApiException) {
      return Icons.api;
    } else if (error is ValidationException) {
      return Icons.warning;
    } else {
      return Icons.error_outline;
    }
  }

  String _getErrorTitle() {
    if (error is NetworkException) {
      return 'Connection Error';
    } else if (error is ApiException) {
      return 'Server Error';
    } else if (error is ValidationException) {
      return 'Validation Error';
    } else {
      return 'Something went wrong';
    }
  }
}

/// A widget for displaying loading states with optional error handling
class LoadingErrorWidget extends StatelessWidget {
  final bool isLoading;
  final dynamic error;
  final String? context;
  final VoidCallback? onRetry;
  final Widget? loadingWidget;
  final Widget? child;

  const LoadingErrorWidget({
    super.key,
    required this.isLoading,
    this.error,
    this.context,
    this.onRetry,
    this.loadingWidget,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? _buildDefaultLoading();
    }

    if (error != null) {
      return ErrorDisplayWidget(
        error: error,
        context: this.context,
        onRetry: onRetry,
        isFullScreen: true,
      );
    }

    return child ?? const SizedBox.shrink();
  }

  Widget _buildDefaultLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}

/// A widget for displaying empty states
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: AppTypography.button.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
