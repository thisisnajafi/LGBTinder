import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

enum SnackbarType {
  success,
  error,
  info,
  warning,
}

class AnimatedSnackbar extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final Duration duration;
  final VoidCallback? onDismiss;

  const AnimatedSnackbar({
    Key? key,
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
  }) : super(key: key);

  @override
  State<AnimatedSnackbar> createState() => _AnimatedSnackbarState();
}

class _AnimatedSnackbarState extends State<AnimatedSnackbar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case SnackbarType.success:
        return AppColors.successLight;
      case SnackbarType.error:
        return AppColors.errorLight;
      case SnackbarType.warning:
        return AppColors.warningLight;
      case SnackbarType.info:
        return AppColors.primaryLight;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.error:
        return Icons.error;
      case SnackbarType.warning:
        return Icons.warning;
      case SnackbarType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _getIcon(),
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: AppTypography.bodyMediumStyle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      _controller.reverse().then((_) {
                        widget.onDismiss?.call();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Helper function to show snackbar
void showAnimatedSnackbar({
  required BuildContext context,
  required String message,
  required SnackbarType type,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: AnimatedSnackbar(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    ),
  );

  overlay.insert(overlayEntry);
} 