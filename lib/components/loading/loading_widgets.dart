import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// A collection of reusable loading widgets for different scenarios
class LoadingWidgets {
  /// Basic circular progress indicator
  static Widget circular({
    Color? color,
    double size = 24.0,
    double strokeWidth = 2.0,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
        strokeWidth: strokeWidth,
      ),
    );
  }

  /// Linear progress indicator
  static Widget linear({
    Color? color,
    double height = 4.0,
    double? value,
  }) {
    return SizedBox(
      height: height,
      child: LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
        backgroundColor: AppColors.surface,
        value: value,
      ),
    );
  }

  /// Loading with text
  static Widget withText({
    required String text,
    Color? color,
    double size = 24.0,
    double strokeWidth = 2.0,
    MainAxisAlignment alignment = MainAxisAlignment.center,
  }) {
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        circular(
          color: color,
          size: size,
          strokeWidth: strokeWidth,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: AppTypography.body1.copyWith(
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Full screen loading
  static Widget fullScreen({
    String? text,
    Color? backgroundColor,
    Color? color,
  }) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            circular(
              color: color,
              size: 48.0,
              strokeWidth: 3.0,
            ),
            if (text != null) ...[
              const SizedBox(height: 24),
              Text(
                text,
                style: AppTypography.heading3.copyWith(
                  color: color ?? AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Button loading state
  static Widget button({
    required String text,
    Color? color,
    double size = 20.0,
    double strokeWidth = 2.0,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        circular(
          color: color ?? Colors.white,
          size: size,
          strokeWidth: strokeWidth,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTypography.button.copyWith(
            color: color ?? Colors.white,
          ),
        ),
      ],
    );
  }

  /// Card loading skeleton
  static Widget cardSkeleton({
    double height = 200.0,
    double borderRadius = 12.0,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: circular(),
      ),
    );
  }

  /// List item loading skeleton
  static Widget listItemSkeleton({
    double height = 60.0,
    double borderRadius = 8.0,
  }) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: circular(size: 20.0),
      ),
    );
  }

  /// Grid item loading skeleton
  static Widget gridItemSkeleton({
    double height = 150.0,
    double borderRadius = 12.0,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: circular(size: 24.0),
      ),
    );
  }
}

/// A widget that shows loading state with optional error handling
class LoadingStateWidget extends StatelessWidget {
  final bool isLoading;
  final Widget? loadingWidget;
  final Widget? child;
  final String? loadingText;
  final Color? loadingColor;

  const LoadingStateWidget({
    super.key,
    required this.isLoading,
    this.loadingWidget,
    this.child,
    this.loadingText,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? 
        LoadingWidgets.withText(
          text: loadingText ?? 'Loading...',
          color: loadingColor,
        );
    }

    return child ?? const SizedBox.shrink();
  }
}

/// A widget that shows loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;
  final Color? backgroundColor;
  final Color? loadingColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
    this.backgroundColor,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? AppColors.background.withOpacity(0.8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingWidgets.circular(
                    color: loadingColor,
                    size: 48.0,
                    strokeWidth: 3.0,
                  ),
                  if (loadingText != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      loadingText!,
                      style: AppTypography.heading3.copyWith(
                        color: loadingColor ?? AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// A widget that shows loading state for buttons
class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final Widget child;
  final Widget? loadingChild;
  final String? loadingText;
  final ButtonStyle? style;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.child,
    this.loadingChild,
    this.loadingText,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? (loadingChild ?? 
              LoadingWidgets.button(
                text: loadingText ?? 'Loading...',
              ))
          : child,
    );
  }
}

/// A widget that shows loading state for list items
class LoadingListItem extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final double height;
  final double borderRadius;

  const LoadingListItem({
    super.key,
    required this.isLoading,
    required this.child,
    this.height = 60.0,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingWidgets.listItemSkeleton(
        height: height,
        borderRadius: borderRadius,
      );
    }

    return child;
  }
}

/// A widget that shows loading state for grid items
class LoadingGridItem extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final double height;
  final double borderRadius;

  const LoadingGridItem({
    super.key,
    required this.isLoading,
    required this.child,
    this.height = 150.0,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingWidgets.gridItemSkeleton(
        height: height,
        borderRadius: borderRadius,
      );
    }

    return child;
  }
}
