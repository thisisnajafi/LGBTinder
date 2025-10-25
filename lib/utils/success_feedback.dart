import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Success feedback utility class for providing user feedback
class SuccessFeedback {
  /// Shows a success toast message
  static void showSuccessToast(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionText,
    VoidCallback? onAction,
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
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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

  /// Shows an info toast message
  static void showInfoToast(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionText,
    VoidCallback? onAction,
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
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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

  /// Shows a warning toast message
  static void showWarningToast(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionText,
    VoidCallback? onAction,
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
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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

  /// Shows a loading indicator with custom message
  static void showLoadingIndicator(
    BuildContext context, {
    String message = 'Loading...',
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => WillPopScope(
        onWillPop: () async => barrierDismissible,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a full-screen loading indicator
  static void showFullScreenLoading(
    BuildContext context, {
    String message = 'Loading...',
    Color? backgroundColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: backgroundColor ?? Colors.black54,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows a progress indicator with percentage
  static void showProgressIndicator(
    BuildContext context, {
    required double progress,
    String message = 'Processing...',
    bool showPercentage = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
              ),
              if (showPercentage) ...[
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).round()}%',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isDestructive ? Colors.red : AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDestructive ? Colors.red : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTypography.bodyLarge.copyWith(
            color: Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              confirmText,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Shows a success dialog
  static Future<void> showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onButtonPressed,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTypography.bodyLarge.copyWith(
            color: Colors.black54,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onButtonPressed?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              buttonText,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a custom loading overlay
  static OverlayEntry showLoadingOverlay(
    BuildContext context, {
    String message = 'Loading...',
    Color? backgroundColor,
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Material(
        color: backgroundColor ?? Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    return entry;
  }

  /// Hides the loading overlay
  static void hideLoadingOverlay(OverlayEntry entry) {
    entry.remove();
  }

  /// Provides haptic feedback (simplified version)
  static void hapticFeedback() {
    // Simplified haptic feedback - in a real app, you'd use HapticFeedback.impact()
  }

  /// Shows a success feedback with haptic
  static void showSuccessWithHaptic(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    hapticFeedback();
    showSuccessToast(context, message: message, duration: duration);
  }

  /// Shows an error feedback with haptic
  static void showErrorWithHaptic(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    hapticFeedback();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Shows a completion dialog with animation
  static Future<void> showCompletionDialog(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.check_circle,
    Color iconColor = AppColors.success,
    String buttonText = 'Continue',
    VoidCallback? onButtonPressed,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 64,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onButtonPressed?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              buttonText,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a step completion indicator
  static void showStepCompletion(
    BuildContext context, {
    required String stepName,
    required int currentStep,
    required int totalSteps,
  }) {
    showSuccessToast(
      context,
      message: '$stepName completed! (Step $currentStep of $totalSteps)',
      duration: const Duration(seconds: 2),
    );
  }

  /// Shows a profile completion celebration
  static Future<void> showProfileCompletionCelebration(
    BuildContext context, {
    required int completionPercentage,
  }) async {
    await showCompletionDialog(
      context,
      title: 'Profile Complete! 🎉',
      message: 'Your profile is ${completionPercentage}% complete. You\'re all set to start matching!',
      icon: Icons.celebration,
      iconColor: AppColors.primary,
      buttonText: 'Start Matching',
    );
  }
}
