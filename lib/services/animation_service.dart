import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimationService {
  static final AnimationService _instance = AnimationService._internal();
  factory AnimationService() => _instance;
  AnimationService._internal();

  // Animation settings
  bool _animationsEnabled = true;
  bool _reduceMotionEnabled = false;
  Duration _defaultDuration = const Duration(milliseconds: 300);
  Duration _fastDuration = const Duration(milliseconds: 150);
  Duration _slowDuration = const Duration(milliseconds: 500);
  Curve _defaultCurve = Curves.easeInOut;
  Curve _bounceCurve = Curves.elasticOut;
  Curve _springCurve = Curves.elasticOut;

  // Getters
  bool get animationsEnabled => _animationsEnabled;
  bool get reduceMotionEnabled => _reduceMotionEnabled;
  Duration get defaultDuration => _defaultDuration;
  Duration get fastDuration => _fastDuration;
  Duration get slowDuration => _slowDuration;
  Curve get defaultCurve => _defaultCurve;
  Curve get bounceCurve => _bounceCurve;
  Curve get springCurve => _springCurve;

  /// Initialize animation service
  void initialize() {
    debugPrint('Animation Service initialized');
  }

  /// Enable/disable animations
  void setAnimationsEnabled(bool enabled) {
    _animationsEnabled = enabled;
  }

  /// Enable/disable reduced motion
  void setReduceMotionEnabled(bool enabled) {
    _reduceMotionEnabled = enabled;
  }

  /// Set default animation duration
  void setDefaultDuration(Duration duration) {
    _defaultDuration = duration;
  }

  /// Get effective duration based on settings
  Duration getEffectiveDuration(Duration? duration) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return Duration.zero;
    }
    return duration ?? _defaultDuration;
  }

  /// Get effective curve based on settings
  Curve getEffectiveCurve(Curve? curve) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return Curves.linear;
    }
    return curve ?? _defaultCurve;
  }

  /// Create fade transition
  Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
    Duration? duration,
    Curve? curve,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return child;
    }

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Create scale transition
  Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
    Duration? duration,
    Curve? curve,
    Alignment alignment = Alignment.center,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return child;
    }

    return ScaleTransition(
      scale: animation,
      alignment: alignment,
      child: child,
    );
  }

  /// Create slide transition
  Widget slideTransition({
    required Widget child,
    required Animation<Offset> animation,
    Duration? duration,
    Curve? curve,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return child;
    }

    return SlideTransition(
      position: animation,
      child: child,
    );
  }

  /// Create rotation transition
  Widget rotationTransition({
    required Widget child,
    required Animation<double> animation,
    Duration? duration,
    Curve? curve,
    Alignment alignment = Alignment.center,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return child;
    }

    return RotationTransition(
      turns: animation,
      alignment: alignment,
      child: child,
    );
  }

  /// Create size transition
  Widget sizeTransition({
    required Widget child,
    required Animation<double> animation,
    Duration? duration,
    Curve? curve,
    Axis axis = Axis.vertical,
    Axis sizeAxis = Axis.vertical,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return child;
    }

    return SizeTransition(
      sizeFactor: animation,
      axis: axis,
      child: child,
    );
  }

  /// Create position transition
  Widget positionTransition({
    required Widget child,
    required Animation<RelativeRect> animation,
    Duration? duration,
    Curve? curve,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return child;
    }

    return PositionedTransition(
      rect: animation,
      child: child,
    );
  }

  /// Create hero animation
  Widget heroAnimation({
    required String tag,
    required Widget child,
    Duration? duration,
    Curve? curve,
    HeroFlightShuttleBuilder? flightShuttleBuilder,
    HeroPlaceholderBuilder? placeholderBuilder,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return child;
    }

    return Hero(
      tag: tag,
      child: child,
      flightShuttleBuilder: flightShuttleBuilder,
      placeholderBuilder: placeholderBuilder,
    );
  }

  /// Create page route transition
  PageRouteBuilder createPageRoute({
    required Widget page,
    Duration? duration,
    Curve? curve,
    RouteTransitionsBuilder? transitionsBuilder,
  }) {
    final effectiveDuration = getEffectiveDuration(duration);
    final effectiveCurve = getEffectiveCurve(curve);

    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: effectiveDuration,
      reverseTransitionDuration: effectiveDuration,
      transitionsBuilder: transitionsBuilder ?? (context, animation, secondaryAnimation, child) {
        if (!_animationsEnabled || _reduceMotionEnabled) {
          return child;
        }

        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Create fade page route
  PageRouteBuilder createFadePageRoute({
    required Widget page,
    Duration? duration,
    Curve? curve,
  }) {
    return createPageRoute(
      page: page,
      duration: duration,
      curve: curve,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (!_animationsEnabled || _reduceMotionEnabled) {
          return child;
        }

        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Create scale page route
  PageRouteBuilder createScalePageRoute({
    required Widget page,
    Duration? duration,
    Curve? curve,
  }) {
    return createPageRoute(
      page: page,
      duration: duration,
      curve: curve,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (!_animationsEnabled || _reduceMotionEnabled) {
          return child;
        }

        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
    );
  }

  /// Create slide page route
  PageRouteBuilder createSlidePageRoute({
    required Widget page,
    Duration? duration,
    Curve? curve,
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
  }) {
    return createPageRoute(
      page: page,
      duration: duration,
      curve: curve,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (!_animationsEnabled || _reduceMotionEnabled) {
          return child;
        }

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve ?? _defaultCurve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Create shimmer animation
  Widget shimmerAnimation({
    required Widget child,
    Duration? duration,
    Color? baseColor,
    Color? highlightColor,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return child;
    }

    return _ShimmerAnimation(
      duration: duration ?? _defaultDuration,
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      child: child,
    );
  }

  /// Create pulse animation
  Widget pulseAnimation({
    required Widget child,
    Duration? duration,
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return child;
    }

    return _PulseAnimation(
      duration: duration ?? _defaultDuration,
      minScale: minScale,
      maxScale: maxScale,
      child: child,
    );
  }

  /// Create bounce animation
  Widget bounceAnimation({
    required Widget child,
    Duration? duration,
    double intensity = 0.1,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return child;
    }

    return _BounceAnimation(
      duration: duration ?? _defaultDuration,
      intensity: intensity,
      child: child,
    );
  }

  /// Create wiggle animation
  Widget wiggleAnimation({
    required Widget child,
    Duration? duration,
    double intensity = 0.1,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return child;
    }

    return _WiggleAnimation(
      duration: duration ?? _defaultDuration,
      intensity: intensity,
      child: child,
    );
  }

  /// Create floating animation
  Widget floatingAnimation({
    required Widget child,
    Duration? duration,
    double offset = 10.0,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return child;
    }

    return _FloatingAnimation(
      duration: duration ?? _slowDuration,
      offset: offset,
      child: child,
    );
  }

  /// Create heartbeat animation
  Widget heartbeatAnimation({
    required Widget child,
    Duration? duration,
    double intensity = 0.1,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return child;
    }

    return _HeartbeatAnimation(
      duration: duration ?? _defaultDuration,
      intensity: intensity,
      child: child,
    );
  }

  /// Create typing animation
  Widget typingAnimation({
    required List<Widget> dots,
    Duration? duration,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: dots,
      );
    }

    return _TypingAnimation(
      duration: duration ?? _fastDuration,
      dots: dots,
    );
  }

  /// Create loading spinner animation
  Widget loadingSpinnerAnimation({
    required Widget child,
    Duration? duration,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return child;
    }

    return _LoadingSpinnerAnimation(
      duration: duration ?? _defaultDuration,
      child: child,
    );
  }

  /// Create progress bar animation
  Widget progressBarAnimation({
    required double progress,
    Duration? duration,
    Color? backgroundColor,
    Color? progressColor,
    double height = 4.0,
    BorderRadius? borderRadius,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return LinearProgressIndicator(
        value: progress,
        backgroundColor: backgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(progressColor ?? Colors.blue),
        minHeight: height,
      );
    }

    return _ProgressBarAnimation(
      progress: progress,
      duration: duration ?? _defaultDuration,
      backgroundColor: backgroundColor,
      progressColor: progressColor,
      height: height,
      borderRadius: borderRadius,
    );
  }

  /// Create counter animation
  Widget counterAnimation({
    required int value,
    Duration? duration,
    TextStyle? style,
    String? prefix,
    String? suffix,
  }) {
    if (!_animationsEnabled || _reduceMotionEnabled) {
      return Text(
        '${prefix ?? ''}$value${suffix ?? ''}',
        style: style,
      );
    }

    return _CounterAnimation(
      value: value,
      duration: duration ?? _defaultDuration,
      style: style,
      prefix: prefix,
      suffix: suffix,
    );
  }

  /// Dispose service
  void dispose() {
    debugPrint('Animation Service disposed');
  }
}

// Custom animation widgets
class _ShimmerAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const _ShimmerAnimation({
    required this.child,
    required this.duration,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<_ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<_ShimmerAnimation>
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
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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

class _PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const _PulseAnimation({
    required this.child,
    required this.duration,
    required this.minScale,
    required this.maxScale,
  });

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
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
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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
        return Transform.scale(
          scale: _animation.value.clamp(0.5, 2.0), // Prevent extreme scaling
          child: widget.child,
        );
      },
    );
  }
}

class _BounceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double intensity;

  const _BounceAnimation({
    required this.child,
    required this.duration,
    required this.intensity,
  });

  @override
  State<_BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<_BounceAnimation>
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
      end: widget.intensity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
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
        return Transform.translate(
          offset: Offset(0, -_animation.value * 20),
          child: widget.child,
        );
      },
    );
  }
}

class _WiggleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double intensity;

  const _WiggleAnimation({
    required this.child,
    required this.duration,
    required this.intensity,
  });

  @override
  State<_WiggleAnimation> createState() => _WiggleAnimationState();
}

class _WiggleAnimationState extends State<_WiggleAnimation>
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
      begin: -widget.intensity,
      end: widget.intensity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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
        return Transform.rotate(
          angle: _animation.value * 0.1,
          child: widget.child,
        );
      },
    );
  }
}

class _FloatingAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;

  const _FloatingAnimation({
    required this.child,
    required this.duration,
    required this.offset,
  });

  @override
  State<_FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<_FloatingAnimation>
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
      begin: -widget.offset,
      end: widget.offset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: widget.child,
        );
      },
    );
  }
}

class _HeartbeatAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double intensity;

  const _HeartbeatAnimation({
    required this.child,
    required this.duration,
    required this.intensity,
  });

  @override
  State<_HeartbeatAnimation> createState() => _HeartbeatAnimationState();
}

class _HeartbeatAnimationState extends State<_HeartbeatAnimation>
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
      begin: 1.0,
      end: 1.0 + widget.intensity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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
        return Transform.scale(
          scale: _animation.value.clamp(0.5, 2.0), // Prevent extreme scaling
          child: widget.child,
        );
      },
    );
  }
}

class _TypingAnimation extends StatefulWidget {
  final List<Widget> dots;
  final Duration duration;

  const _TypingAnimation({
    required this.dots,
    required this.duration,
  });

  @override
  State<_TypingAnimation> createState() => _TypingAnimationState();
}

class _TypingAnimationState extends State<_TypingAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.dots.length,
      (index) => AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
    );
    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    // Stagger the animations
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dots.length, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: 0.5 + (_animations[index].value * 0.5),
              child: widget.dots[index],
            );
          },
        );
      }),
    );
  }
}

class _LoadingSpinnerAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _LoadingSpinnerAnimation({
    required this.child,
    required this.duration,
  });

  @override
  State<_LoadingSpinnerAnimation> createState() => _LoadingSpinnerAnimationState();
}

class _LoadingSpinnerAnimationState extends State<_LoadingSpinnerAnimation>
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
    ).animate(_controller);
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
        return Transform.rotate(
          angle: _animation.value * 2 * math.pi,
          child: widget.child,
        );
      },
    );
  }
}

class _ProgressBarAnimation extends StatefulWidget {
  final double progress;
  final Duration duration;
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final BorderRadius? borderRadius;

  const _ProgressBarAnimation({
    required this.progress,
    required this.duration,
    this.backgroundColor,
    this.progressColor,
    required this.height,
    this.borderRadius,
  });

  @override
  State<_ProgressBarAnimation> createState() => _ProgressBarAnimationState();
}

class _ProgressBarAnimationState extends State<_ProgressBarAnimation>
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
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_ProgressBarAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.reset();
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.grey[300],
            borderRadius: widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _animation.value,
            child: Container(
              decoration: BoxDecoration(
                color: widget.progressColor ?? Colors.blue,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CounterAnimation extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;

  const _CounterAnimation({
    required this.value,
    required this.duration,
    this.style,
    this.prefix,
    this.suffix,
  });

  @override
  State<_CounterAnimation> createState() => _CounterAnimationState();
}

class _CounterAnimationState extends State<_CounterAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: _previousValue.toDouble(),
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_CounterAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _previousValue.toDouble(),
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.reset();
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix ?? ''}${_animation.value.round()}${widget.suffix ?? ''}',
          style: widget.style,
        );
      },
    );
  }
}
