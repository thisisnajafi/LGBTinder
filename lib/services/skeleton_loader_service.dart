import 'package:flutter/material.dart';
import 'dart:math' as math;

class SkeletonLoaderService {
  static final SkeletonLoaderService _instance = SkeletonLoaderService._internal();
  factory SkeletonLoaderService() => _instance;
  SkeletonLoaderService._internal();

  // Skeleton settings
  bool _isEnabled = true;
  Color _baseColor = Colors.grey[300]!;
  Color _highlightColor = Colors.grey[100]!;
  Duration _animationDuration = const Duration(milliseconds: 1500);
  Duration _animationDelay = const Duration(milliseconds: 200);
  Curve _animationCurve = Curves.easeInOut;
  double _shimmerAngle = 0.0;
  double _shimmerSpeed = 1.0;

  // Getters
  bool get isEnabled => _isEnabled;
  Color get baseColor => _baseColor;
  Color get highlightColor => _highlightColor;
  Duration get animationDuration => _animationDuration;
  Duration get animationDelay => _animationDelay;
  Curve get animationCurve => _animationCurve;
  double get shimmerAngle => _shimmerAngle;
  double get shimmerSpeed => _shimmerSpeed;

  /// Initialize skeleton loader service
  void initialize() {
    debugPrint('Skeleton Loader Service initialized');
  }

  /// Enable/disable skeleton loaders
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Set skeleton colors
  void setColors({
    Color? baseColor,
    Color? highlightColor,
  }) {
    if (baseColor != null) _baseColor = baseColor;
    if (highlightColor != null) _highlightColor = highlightColor;
  }

  /// Set animation settings
  void setAnimationSettings({
    Duration? duration,
    Duration? delay,
    Curve? curve,
    double? shimmerAngle,
    double? shimmerSpeed,
  }) {
    if (duration != null) _animationDuration = duration;
    if (delay != null) _animationDelay = delay;
    if (curve != null) _animationCurve = curve;
    if (shimmerAngle != null) _shimmerAngle = shimmerAngle;
    if (shimmerSpeed != null) _shimmerSpeed = shimmerSpeed.clamp(0.1, 3.0);
  }

  /// Create a shimmer effect widget
  Widget createShimmer({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
    Duration? duration,
    Curve? curve,
  }) {
    if (!_isEnabled) return child;

    return _ShimmerWidget(
      baseColor: baseColor ?? _baseColor,
      highlightColor: highlightColor ?? _highlightColor,
      duration: duration ?? _animationDuration,
      curve: curve ?? _animationCurve,
      child: child,
    );
  }

  /// Create a skeleton box
  Widget createSkeletonBox({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? color,
  }) {
    if (!_isEnabled) {
      return SizedBox(width: width, height: height);
    }

    return _SkeletonBox(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(4),
      color: color ?? _baseColor,
      highlightColor: _highlightColor,
      duration: _animationDuration,
      curve: _animationCurve,
    );
  }

  /// Create a skeleton circle
  Widget createSkeletonCircle({
    double? diameter,
    Color? color,
  }) {
    if (!_isEnabled) {
      return SizedBox(width: diameter, height: diameter);
    }

    return _SkeletonCircle(
      diameter: diameter ?? 40,
      color: color ?? _baseColor,
      highlightColor: _highlightColor,
      duration: _animationDuration,
      curve: _animationCurve,
    );
  }

  /// Create a skeleton text
  Widget createSkeletonText({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? color,
  }) {
    if (!_isEnabled) {
      return SizedBox(width: width, height: height);
    }

    return _SkeletonText(
      width: width,
      height: height ?? 16,
      borderRadius: borderRadius ?? BorderRadius.circular(4),
      color: color ?? _baseColor,
      highlightColor: _highlightColor,
      duration: _animationDuration,
      curve: _animationCurve,
    );
  }

  /// Create a skeleton avatar
  Widget createSkeletonAvatar({
    double? size,
    Color? color,
  }) {
    if (!_isEnabled) {
      return SizedBox(width: size, height: size);
    }

    return _SkeletonAvatar(
      size: size ?? 40,
      color: color ?? _baseColor,
      highlightColor: _highlightColor,
      duration: _animationDuration,
      curve: _animationCurve,
    );
  }

  /// Create a skeleton card
  Widget createSkeletonCard({
    double? width,
    double? height,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    Color? color,
  }) {
    if (!_isEnabled) {
      return SizedBox(width: width, height: height);
    }

    return _SkeletonCard(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      color: color ?? _baseColor,
      highlightColor: _highlightColor,
      duration: _animationDuration,
      curve: _animationCurve,
    );
  }

  /// Create a skeleton list item
  Widget createSkeletonListItem({
    double? width,
    double? height,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    Color? color,
    bool showAvatar = true,
    bool showTitle = true,
    bool showSubtitle = true,
  }) {
    if (!_isEnabled) {
      return SizedBox(width: width, height: height);
    }

    return _SkeletonListItem(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      color: color ?? _baseColor,
      highlightColor: _highlightColor,
      duration: _animationDuration,
      curve: _animationCurve,
      showAvatar: showAvatar,
      showTitle: showTitle,
      showSubtitle: showSubtitle,
    );
  }

  /// Create a skeleton profile card
  Widget createSkeletonProfileCard({
    double? width,
    double? height,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    Color? color,
  }) {
    if (!_isEnabled) {
      return SizedBox(width: width, height: height);
    }

    return _SkeletonProfileCard(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      color: color ?? _baseColor,
      highlightColor: _highlightColor,
      duration: _animationDuration,
      curve: _animationCurve,
    );
  }

  /// Create a skeleton chat message
  Widget createSkeletonChatMessage({
    double? width,
    double? height,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    Color? color,
    bool isOwnMessage = false,
  }) {
    if (!_isEnabled) {
      return SizedBox(width: width, height: height);
    }

    return _SkeletonChatMessage(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(12),
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      color: color ?? _baseColor,
      highlightColor: _highlightColor,
      duration: _animationDuration,
      curve: _animationCurve,
      isOwnMessage: isOwnMessage,
    );
  }

  /// Create a skeleton grid item
  Widget createSkeletonGridItem({
    double? width,
    double? height,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    Color? color,
  }) {
    if (!_isEnabled) {
      return SizedBox(width: width, height: height);
    }

    return _SkeletonGridItem(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(8),
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      color: color ?? _baseColor,
      highlightColor: _highlightColor,
      duration: _animationDuration,
      curve: _animationCurve,
    );
  }

  /// Dispose service
  void dispose() {
    debugPrint('Skeleton Loader Service disposed');
  }
}

class _ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;
  final Curve curve;

  const _ShimmerWidget({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
    required this.duration,
    required this.curve,
  });

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final Color color;
  final Color highlightColor;
  final Duration duration;
  final Curve curve;

  const _SkeletonBox({
    this.width,
    this.height,
    required this.borderRadius,
    required this.color,
    required this.highlightColor,
    required this.duration,
    required this.curve,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(widget.color, widget.highlightColor, _animation.value.clamp(0.0, 1.0)),
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}

class _SkeletonCircle extends StatefulWidget {
  final double diameter;
  final Color color;
  final Color highlightColor;
  final Duration duration;
  final Curve curve;

  const _SkeletonCircle({
    required this.diameter,
    required this.color,
    required this.highlightColor,
    required this.duration,
    required this.curve,
  });

  @override
  State<_SkeletonCircle> createState() => _SkeletonCircleState();
}

class _SkeletonCircleState extends State<_SkeletonCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.diameter,
          height: widget.diameter,
          decoration: BoxDecoration(
            color: Color.lerp(widget.color, widget.highlightColor, _animation.value.clamp(0.0, 1.0)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class _SkeletonText extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;
  final Color color;
  final Color highlightColor;
  final Duration duration;
  final Curve curve;

  const _SkeletonText({
    this.width,
    required this.height,
    required this.borderRadius,
    required this.color,
    required this.highlightColor,
    required this.duration,
    required this.curve,
  });

  @override
  State<_SkeletonText> createState() => _SkeletonTextState();
}

class _SkeletonTextState extends State<_SkeletonText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(widget.color, widget.highlightColor, _animation.value.clamp(0.0, 1.0)),
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}

class _SkeletonAvatar extends StatefulWidget {
  final double size;
  final Color color;
  final Color highlightColor;
  final Duration duration;
  final Curve curve;

  const _SkeletonAvatar({
    required this.size,
    required this.color,
    required this.highlightColor,
    required this.duration,
    required this.curve,
  });

  @override
  State<_SkeletonAvatar> createState() => _SkeletonAvatarState();
}

class _SkeletonAvatarState extends State<_SkeletonAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Color.lerp(widget.color, widget.highlightColor, _animation.value.clamp(0.0, 1.0)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color color;
  final Color highlightColor;
  final Duration duration;
  final Curve curve;

  const _SkeletonCard({
    this.width,
    this.height,
    required this.padding,
    required this.borderRadius,
    required this.color,
    required this.highlightColor,
    required this.duration,
    required this.curve,
  });

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: Color.lerp(widget.color, widget.highlightColor, _animation.value.clamp(0.0, 1.0)),
            borderRadius: widget.borderRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title skeleton
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.lerp(widget.color.withOpacity(0.7), widget.highlightColor.withOpacity(0.7), _animation.value.clamp(0.0, 1.0)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle skeleton
              Container(
                height: 12,
                width: double.infinity * 0.7,
                decoration: BoxDecoration(
                  color: Color.lerp(widget.color.withOpacity(0.5), widget.highlightColor.withOpacity(0.5), _animation.value.clamp(0.0, 1.0)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonListItem extends StatefulWidget {
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color color;
  final Color highlightColor;
  final Duration duration;
  final Curve curve;
  final bool showAvatar;
  final bool showTitle;
  final bool showSubtitle;

  const _SkeletonListItem({
    this.width,
    this.height,
    required this.padding,
    required this.borderRadius,
    required this.color,
    required this.highlightColor,
    required this.duration,
    required this.curve,
    required this.showAvatar,
    required this.showTitle,
    required this.showSubtitle,
  });

  @override
  State<_SkeletonListItem> createState() => _SkeletonListItemState();
}

class _SkeletonListItemState extends State<_SkeletonListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: Color.lerp(widget.color, widget.highlightColor, _animation.value.clamp(0.0, 1.0)),
            borderRadius: widget.borderRadius,
          ),
          child: Row(
            children: [
              if (widget.showAvatar) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.lerp(widget.color.withOpacity(0.7), widget.highlightColor.withOpacity(0.7), _animation.value.clamp(0.0, 1.0)),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.showTitle) ...[
                      Container(
                        height: 16,
                        width: double.infinity * 0.6,
                        decoration: BoxDecoration(
                          color: Color.lerp(widget.color.withOpacity(0.8), widget.highlightColor.withOpacity(0.8), _animation.value.clamp(0.0, 1.0)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (widget.showSubtitle) ...[
                      Container(
                        height: 12,
                        width: double.infinity * 0.4,
                        decoration: BoxDecoration(
                          color: Color.lerp(widget.color.withOpacity(0.5), widget.highlightColor.withOpacity(0.5), _animation.value.clamp(0.0, 1.0)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonProfileCard extends StatefulWidget {
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color color;
  final Color highlightColor;
  final Duration duration;
  final Curve curve;

  const _SkeletonProfileCard({
    this.width,
    this.height,
    required this.padding,
    required this.borderRadius,
    required this.color,
    required this.highlightColor,
    required this.duration,
    required this.curve,
  });

  @override
  State<_SkeletonProfileCard> createState() => _SkeletonProfileCardState();
}

class _SkeletonProfileCardState extends State<_SkeletonProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: Color.lerp(widget.color, widget.highlightColor, _animation.value.clamp(0.0, 1.0)),
            borderRadius: widget.borderRadius,
          ),
          child: Column(
            children: [
              // Profile image skeleton
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color.lerp(widget.color.withOpacity(0.7), widget.highlightColor.withOpacity(0.7), _animation.value.clamp(0.0, 1.0)),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 16),
              // Name skeleton
              Container(
                height: 20,
                width: double.infinity * 0.6,
                decoration: BoxDecoration(
                  color: Color.lerp(widget.color.withOpacity(0.8), widget.highlightColor.withOpacity(0.8), _animation.value.clamp(0.0, 1.0)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              // Age skeleton
              Container(
                height: 16,
                width: double.infinity * 0.3,
                decoration: BoxDecoration(
                  color: Color.lerp(widget.color.withOpacity(0.6), widget.highlightColor.withOpacity(0.6), _animation.value.clamp(0.0, 1.0)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonChatMessage extends StatefulWidget {
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color color;
  final Color highlightColor;
  final Duration duration;
  final Curve curve;
  final bool isOwnMessage;

  const _SkeletonChatMessage({
    this.width,
    this.height,
    required this.padding,
    required this.borderRadius,
    required this.color,
    required this.highlightColor,
    required this.duration,
    required this.curve,
    required this.isOwnMessage,
  });

  @override
  State<_SkeletonChatMessage> createState() => _SkeletonChatMessageState();
}

class _SkeletonChatMessageState extends State<_SkeletonChatMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Align(
          alignment: widget.isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: Color.lerp(widget.color, widget.highlightColor, _animation.value.clamp(0.0, 1.0)),
              borderRadius: widget.borderRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message text skeleton
                Container(
                  height: 16,
                  width: double.infinity * 0.8,
                  decoration: BoxDecoration(
                    color: Color.lerp(widget.color.withOpacity(0.7), widget.highlightColor.withOpacity(0.7), _animation.value.clamp(0.0, 1.0)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 16,
                  width: double.infinity * 0.5,
                  decoration: BoxDecoration(
                    color: Color.lerp(widget.color.withOpacity(0.5), widget.highlightColor.withOpacity(0.5), _animation.value.clamp(0.0, 1.0)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonGridItem extends StatefulWidget {
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color color;
  final Color highlightColor;
  final Duration duration;
  final Curve curve;

  const _SkeletonGridItem({
    this.width,
    this.height,
    required this.padding,
    required this.borderRadius,
    required this.color,
    required this.highlightColor,
    required this.duration,
    required this.curve,
  });

  @override
  State<_SkeletonGridItem> createState() => _SkeletonGridItemState();
}

class _SkeletonGridItemState extends State<_SkeletonGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: Color.lerp(widget.color, widget.highlightColor, _animation.value.clamp(0.0, 1.0)),
            borderRadius: widget.borderRadius,
          ),
          child: Column(
            children: [
              // Image skeleton
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color.lerp(widget.color.withOpacity(0.7), widget.highlightColor.withOpacity(0.7), _animation.value.clamp(0.0, 1.0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Title skeleton
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.lerp(widget.color.withOpacity(0.8), widget.highlightColor.withOpacity(0.8), _animation.value.clamp(0.0, 1.0)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
