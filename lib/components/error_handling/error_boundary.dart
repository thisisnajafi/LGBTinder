import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/error_monitoring_service.dart';

/// A widget that catches and handles errors in its child widget tree
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, Object error, StackTrace? stackTrace)? errorBuilder;
  final VoidCallback? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = _handleFlutterError;
  }

  @override
  void dispose() {
    FlutterError.onError = FlutterError.presentError;
    super.dispose();
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    if (mounted) {
      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
      });

      // Log error to monitoring service
      ErrorMonitoringService.logError(
        error: details.exception,
        stackTrace: details.stack,
        context: 'ErrorBoundary',
      );

      // Call custom error handler
      widget.onError?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!, _stackTrace);
      }

      return _buildDefaultErrorWidget();
    }

    return widget.child;
  }

  Widget _buildDefaultErrorWidget() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: AppTypography.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'An unexpected error occurred. Please try again.',
                style: AppTypography.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    _error.toString(),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _stackTrace = null;
                  });
                },
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
                  'Try Again',
                  style: AppTypography.button.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A widget that provides error handling for async operations
class AsyncErrorHandler extends StatelessWidget {
  final Future<void> Function() operation;
  final Widget child;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final VoidCallback? onError;

  const AsyncErrorHandler({
    super.key,
    required this.operation,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: operation(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (errorBuilder != null) {
            return errorBuilder!(context, snapshot.error!);
          }

          return _buildDefaultErrorWidget(context, snapshot.error!);
        }

        return child;
      },
    );
  }

  Widget _buildDefaultErrorWidget(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load',
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again.',
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Retry the operation
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry',
                style: AppTypography.button.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
