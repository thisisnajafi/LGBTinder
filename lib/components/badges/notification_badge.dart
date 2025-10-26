import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final double? size;
  final bool showZero;
  final Widget? child;

  const NotificationBadge({
    Key? key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.size,
    this.showZero = false,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shouldShow = showZero || count > 0;
    
    if (!shouldShow) {
      return child ?? const SizedBox.shrink();
    }

    final badgeSize = size ?? 20.0;
    final badgeColor = backgroundColor ?? AppColors.feedbackError;
    final textColor = this.textColor ?? Colors.white;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (child != null) child!,
        Positioned(
          right: -8,
          top: -8,
          child: Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: AppTypography.caption.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: badgeSize * 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NavbarBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget child;

  const NavbarBadge({
    Key? key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return child;
    }

    final badgeColor = backgroundColor ?? AppColors.feedbackError;
    final textColor = this.textColor ?? Colors.white;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            height: 18,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.navbarBackground,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: AppTypography.caption.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DotBadge extends StatelessWidget {
  final bool show;
  final Color? color;
  final double size;
  final Widget child;

  const DotBadge({
    Key? key,
    required this.show,
    this.color,
    this.size = 8.0,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return child;
    }

    final badgeColor = color ?? AppColors.feedbackError;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AnimatedBadge extends StatefulWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final double? size;
  final bool showZero;
  final Widget? child;
  final Duration animationDuration;

  const AnimatedBadge({
    Key? key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.size,
    this.showZero = false,
    this.child,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldShow = widget.showZero || widget.count > 0;
    
    if (!shouldShow) {
      return widget.child ?? const SizedBox.shrink();
    }

    final badgeSize = widget.size ?? 20.0;
    final badgeColor = widget.backgroundColor ?? AppColors.feedbackError;
    final textColor = widget.textColor ?? Colors.white;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (widget.child != null) widget.child!,
        Positioned(
          right: -8,
          top: -8,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    width: badgeSize,
                    height: badgeSize,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.count > 99 ? '99+' : widget.count.toString(),
                        style: AppTypography.caption.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: badgeSize * 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
