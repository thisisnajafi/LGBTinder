import 'package:flutter/material.dart';
import 'dart:math';
import '../../theme/colors.dart';
import '../../services/haptic_feedback_service.dart';

class MatchCelebration extends StatefulWidget {
  final Widget child;
  final VoidCallback? onAnimationComplete;
  final Duration animationDuration;
  final CelebrationType type;
  final bool enableHapticFeedback;
  final bool enableSound;

  const MatchCelebration({
    Key? key,
    required this.child,
    this.onAnimationComplete,
    this.animationDuration = const Duration(milliseconds: 2000),
    this.type = CelebrationType.confetti,
    this.enableHapticFeedback = true,
    this.enableSound = true,
  }) : super(key: key);

  @override
  State<MatchCelebration> createState() => _MatchCelebrationState();
}

class _MatchCelebrationState extends State<MatchCelebration>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _heartController;
  late AnimationController _sparkleController;
  late AnimationController _scaleController;
  
  late Animation<double> _confettiAnimation;
  late Animation<double> _heartAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _scaleAnimation;
  
  List<ConfettiParticle> _confettiParticles = [];
  List<HeartParticle> _heartParticles = [];
  List<SparkleParticle> _sparkleParticles = [];
  
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _startCelebration();
  }

  void _initializeAnimations() {
    _confettiController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));

    _heartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.elasticOut,
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  void _generateParticles() {
    _confettiParticles = List.generate(50, (index) => ConfettiParticle(
      x: _random.nextDouble(),
      y: 0.0,
      color: _getRandomColor(),
      size: _random.nextDouble() * 8 + 4,
      velocity: _random.nextDouble() * 2 + 1,
      rotation: _random.nextDouble() * 2 * pi,
      rotationSpeed: _random.nextDouble() * 0.1 - 0.05,
    ));

    _heartParticles = List.generate(20, (index) => HeartParticle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 20 + 10,
      velocity: _random.nextDouble() * 3 + 1,
      opacity: _random.nextDouble() * 0.8 + 0.2,
    ));

    _sparkleParticles = List.generate(30, (index) => SparkleParticle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 6 + 3,
      velocity: _random.nextDouble() * 2 + 0.5,
      opacity: _random.nextDouble() * 0.9 + 0.1,
    ));
  }

  Color _getRandomColor() {
    final colors = [
      AppColors.prideRed,
      AppColors.prideOrange,
      AppColors.prideYellow,
      AppColors.prideGreen,
      AppColors.prideBlue,
      AppColors.pridePurple,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _startCelebration() {
    if (widget.enableHapticFeedback) {
      HapticFeedbackService.matchFound();
    }

    switch (widget.type) {
      case CelebrationType.confetti:
        _confettiController.forward();
        break;
      case CelebrationType.hearts:
        _heartController.forward();
        break;
      case CelebrationType.sparkles:
        _sparkleController.forward();
        break;
      case CelebrationType.combined:
        _confettiController.forward();
        _heartController.forward();
        _sparkleController.forward();
        break;
    }

    _scaleController.forward().then((_) {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _heartController.dispose();
    _sparkleController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.type == CelebrationType.confetti || widget.type == CelebrationType.combined)
          _buildConfetti(),
        if (widget.type == CelebrationType.hearts || widget.type == CelebrationType.combined)
          _buildHearts(),
        if (widget.type == CelebrationType.sparkles || widget.type == CelebrationType.combined)
          _buildSparkles(),
        _buildScaleEffect(),
      ],
    );
  }

  Widget _buildConfetti() {
    return AnimatedBuilder(
      animation: _confettiAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _confettiParticles,
            progress: _confettiAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildHearts() {
    return AnimatedBuilder(
      animation: _heartAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: HeartPainter(
            particles: _heartParticles,
            progress: _heartAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildSparkles() {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: SparklePainter(
            particles: _sparkleParticles,
            progress: _sparkleAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildScaleEffect() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_scaleAnimation.value * 0.1),
          child: Opacity(
            opacity: 0.8 + (_scaleAnimation.value * 0.2),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryLight.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

enum CelebrationType {
  confetti,
  hearts,
  sparkles,
  combined,
}

class ConfettiParticle {
  double x;
  double y;
  Color color;
  double size;
  double velocity;
  double rotation;
  double rotationSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class HeartParticle {
  double x;
  double y;
  double size;
  double velocity;
  double opacity;

  HeartParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.velocity,
    required this.opacity,
  });
}

class SparkleParticle {
  double x;
  double y;
  double size;
  double velocity;
  double opacity;

  SparkleParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.velocity,
    required this.opacity,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(1.0 - progress)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height + (progress * size.height * particle.velocity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + (progress * particle.rotationSpeed * 10));
      
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class HeartPainter extends CustomPainter {
  final List<HeartParticle> particles;
  final double progress;

  HeartPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = AppColors.prideRed.withOpacity(particle.opacity * (1.0 - progress))
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height - (progress * size.height * particle.velocity);

      _drawHeart(canvas, Offset(x, y), particle.size, paint);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final width = size;
    final height = size * 0.9;

    path.moveTo(center.dx, center.dy + height * 0.3);
    path.cubicTo(
      center.dx - width * 0.5, center.dy - height * 0.1,
      center.dx - width * 0.5, center.dy + height * 0.3,
      center.dx, center.dy + height * 0.3,
    );
    path.cubicTo(
      center.dx + width * 0.5, center.dy + height * 0.3,
      center.dx + width * 0.5, center.dy - height * 0.1,
      center.dx, center.dy + height * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HeartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class SparklePainter extends CustomPainter {
  final List<SparkleParticle> particles;
  final double progress;

  SparklePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(particle.opacity * (1.0 - progress))
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      _drawSparkle(canvas, Offset(x, y), particle.size, paint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final radius = size / 2;

    // Draw a star shape
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi) / 4;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class MatchCelebrationOverlay extends StatefulWidget {
  final String message;
  final VoidCallback? onDismiss;
  final Duration displayDuration;

  const MatchCelebrationOverlay({
    Key? key,
    this.message = "It's a Match!",
    this.onDismiss,
    this.displayDuration = const Duration(milliseconds: 3000),
  }) : super(key: key);

  @override
  State<MatchCelebrationOverlay> createState() => _MatchCelebrationOverlayState();
}

class _MatchCelebrationOverlayState extends State<MatchCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();
    
    Future.delayed(widget.displayDuration, () {
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.prideRed.withOpacity(0.8),
                    AppColors.pridePurple.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
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
