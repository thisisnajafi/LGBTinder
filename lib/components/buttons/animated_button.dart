import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/haptic_feedback_service.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonAnimationType animationType;
  final Duration animationDuration;
  final Curve animationCurve;
  final Color? rippleColor;
  final bool enableHapticFeedback;
  final String? semanticLabel;
  final String? semanticHint;

  const AnimatedButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.animationType = ButtonAnimationType.scale,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationCurve = Curves.easeInOut,
    this.rippleColor,
    this.enableHapticFeedback = true,
    this.semanticLabel,
    this.semanticHint,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late AnimationController _rotationController;
  late AnimationController _bounceController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _bounceAnimation;
  
  bool _isPressed = false;
  Offset? _rippleCenter;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: widget.animationCurve,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    _rotationController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    
    setState(() {
      _isPressed = true;
      _rippleCenter = details.localPosition;
    });

    _startPressAnimation();
    
    if (widget.enableHapticFeedback) {
      HapticFeedbackService.light();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    
    setState(() {
      _isPressed = false;
    });

    _startReleaseAnimation();
  }

  void _onTapCancel() {
    if (widget.onPressed == null) return;
    
    setState(() {
      _isPressed = false;
    });

    _startReleaseAnimation();
  }

  void _onTap() {
    if (widget.onPressed == null) return;
    
    widget.onPressed!();
    
    if (widget.enableHapticFeedback) {
      HapticFeedbackService.selection();
    }
  }

  void _startPressAnimation() {
    switch (widget.animationType) {
      case ButtonAnimationType.scale:
        _scaleController.forward();
        break;
      case ButtonAnimationType.ripple:
        _rippleController.forward();
        break;
      case ButtonAnimationType.rotation:
        _rotationController.forward();
        break;
      case ButtonAnimationType.bounce:
        _bounceController.forward();
        break;
      case ButtonAnimationType.combined:
        _scaleController.forward();
        _rippleController.forward();
        break;
    }
  }

  void _startReleaseAnimation() {
    switch (widget.animationType) {
      case ButtonAnimationType.scale:
        _scaleController.reverse();
        break;
      case ButtonAnimationType.ripple:
        _rippleController.reverse();
        break;
      case ButtonAnimationType.rotation:
        _rotationController.reverse();
        break;
      case ButtonAnimationType.bounce:
        _bounceController.reverse();
        break;
      case ButtonAnimationType.combined:
        _scaleController.reverse();
        _rippleController.reverse();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      hint: widget.semanticHint,
      button: true,
      enabled: widget.onPressed != null,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: _onTap,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _scaleController,
              _rippleController,
              _rotationController,
              _bounceController,
            ]),
            builder: (context, child) {
              return _buildAnimatedChild();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedChild() {
    Widget animatedChild = widget.child;

    switch (widget.animationType) {
      case ButtonAnimationType.scale:
        animatedChild = Transform.scale(
          scale: _scaleAnimation.value,
          child: animatedChild,
        );
        break;
      case ButtonAnimationType.ripple:
        animatedChild = _buildRippleEffect(animatedChild);
        break;
      case ButtonAnimationType.rotation:
        animatedChild = Transform.rotate(
          angle: _rotationAnimation.value,
          child: animatedChild,
        );
        break;
      case ButtonAnimationType.bounce:
        animatedChild = Transform.scale(
          scale: 1.0 + (_bounceAnimation.value * 0.1),
          child: animatedChild,
        );
        break;
      case ButtonAnimationType.combined:
        animatedChild = Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildRippleEffect(animatedChild),
        );
        break;
    }

    return animatedChild;
  }

  Widget _buildRippleEffect(Widget child) {
    if (_rippleCenter == null) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: CustomPaint(
            painter: RipplePainter(
              center: _rippleCenter!,
              progress: _rippleAnimation.value,
              color: widget.rippleColor ?? AppColors.primaryLight.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }
}

enum ButtonAnimationType {
  scale,
  ripple,
  rotation,
  bounce,
  combined,
}

class RipplePainter extends CustomPainter {
  final Offset center;
  final double progress;
  final Color color;

  RipplePainter({
    required this.center,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity((1.0 - progress) * 0.5)
      ..style = PaintingStyle.fill;

    final radius = progress * size.width;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.center != center ||
           oldDelegate.color != color;
  }
}

class PulseButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration pulseDuration;
  final double pulseScale;
  final Color? pulseColor;
  final bool enableHapticFeedback;

  const PulseButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.pulseDuration = const Duration(milliseconds: 1000),
    this.pulseScale = 1.1,
    this.pulseColor,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<PulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.pulseDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pulseScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
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
    return GestureDetector(
      onTap: () {
        widget.onPressed?.call();
        if (widget.enableHapticFeedback) {
          HapticFeedbackService.medium();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulse effect
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.pulseColor ?? AppColors.primaryLight,
                    ),
                    child: widget.child,
                  ),
                ),
              ),
              // Main button
              widget.child,
            ],
          );
        },
      ),
    );
  }
}

class ShakeButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration shakeDuration;
  final double shakeIntensity;
  final bool enableHapticFeedback;

  const ShakeButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.shakeDuration = const Duration(milliseconds: 500),
    this.shakeIntensity = 10.0,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<ShakeButton> createState() => _ShakeButtonState();
}

class _ShakeButtonState extends State<ShakeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.shakeDuration,
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: widget.shakeIntensity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _shake() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    
    if (widget.enableHapticFeedback) {
      HapticFeedbackService.heavy();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed?.call();
        _shake();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _shakeAnimation.value * (0.5 - (DateTime.now().millisecondsSinceEpoch % 2)),
              0,
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}
