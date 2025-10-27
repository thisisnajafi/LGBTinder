import 'package:flutter/material.dart';
import 'dart:math';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/haptic_feedback_service.dart';

class SuperLikeAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onAnimationComplete;
  final Duration animationDuration;
  final bool enableHapticFeedback;
  final bool enableSound;

  const SuperLikeAnimation({
    Key? key,
    required this.child,
    this.onAnimationComplete,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.enableHapticFeedback = true,
    this.enableSound = true,
  }) : super(key: key);

  @override
  State<SuperLikeAnimation> createState() => _SuperLikeAnimationState();
}

class _SuperLikeAnimationState extends State<SuperLikeAnimation>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _burstController;
  late AnimationController _glowController;
  late AnimationController _scaleController;
  
  late Animation<double> _starAnimation;
  late Animation<double> _burstAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  
  List<StarParticle> _starParticles = [];
  List<BurstParticle> _burstParticles = [];
  
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _startSuperLikeAnimation();
  }

  void _initializeAnimations() {
    _starController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _burstController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _starAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.elasticOut,
    ));

    _burstAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _burstController,
      curve: Curves.easeOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
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
    _starParticles = List.generate(12, (index) => StarParticle(
      x: 0.5 + (cos(index * pi / 6) * 0.3),
      y: 0.5 + (sin(index * pi / 6) * 0.3),
      size: _random.nextDouble() * 8 + 4,
      velocity: _random.nextDouble() * 2 + 1,
      rotation: index * pi / 6,
      rotationSpeed: _random.nextDouble() * 0.2 - 0.1,
    ));

    _burstParticles = List.generate(24, (index) => BurstParticle(
      x: 0.5,
      y: 0.5,
      angle: (index * 2 * pi) / 24,
      velocity: _random.nextDouble() * 3 + 2,
      size: _random.nextDouble() * 6 + 3,
      color: _getRandomBurstColor(),
    ));
  }

  Color _getRandomBurstColor() {
    final colors = [
      AppColors.prideYellow,
      AppColors.prideOrange,
      AppColors.prideRed,
      Colors.white,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _startSuperLikeAnimation() {
    if (widget.enableHapticFeedback) {
      HapticFeedbackService.superLike();
    }

    _starController.forward();
    _burstController.forward();
    _glowController.forward();
    
    _scaleController.forward().then((_) {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _starController.dispose();
    _burstController.dispose();
    _glowController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        _buildGlowEffect(),
        _buildBurstEffect(),
        _buildStarEffect(),
        _buildScaleEffect(),
      ],
    );
  }

  Widget _buildGlowEffect() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                AppColors.prideYellow.withOpacity(0.3 * _glowAnimation.value),
                AppColors.prideOrange.withOpacity(0.2 * _glowAnimation.value),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBurstEffect() {
    return AnimatedBuilder(
      animation: _burstAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: BurstPainter(
            particles: _burstParticles,
            progress: _burstAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildStarEffect() {
    return AnimatedBuilder(
      animation: _starAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: StarPainter(
            particles: _starParticles,
            progress: _starAnimation.value,
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
          scale: 1.0 + (_scaleAnimation.value * 0.15),
          child: Opacity(
            opacity: 0.9 + (_scaleAnimation.value * 0.1),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.prideYellow.withOpacity(0.4 * _scaleAnimation.value),
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

class StarParticle {
  double x;
  double y;
  double size;
  double velocity;
  double rotation;
  double rotationSpeed;

  StarParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class BurstParticle {
  double x;
  double y;
  double angle;
  double velocity;
  double size;
  Color color;

  BurstParticle({
    required this.x,
    required this.y,
    required this.angle,
    required this.velocity,
    required this.size,
    required this.color,
  });
}

class StarPainter extends CustomPainter {
  final List<StarParticle> particles;
  final double progress;

  StarPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = AppColors.prideYellow.withOpacity(1.0 - progress)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + (progress * particle.rotationSpeed * 10));
      
      _drawStar(canvas, Offset.zero, particle.size, paint);
      
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final radius = size / 2;
    final innerRadius = radius * 0.4;

    for (int i = 0; i < 10; i++) {
      final angle = (i * pi) / 5;
      final isOuter = i % 2 == 0;
      final currentRadius = isOuter ? radius : innerRadius;
      
      final x = center.dx + cos(angle) * currentRadius;
      final y = center.dy + sin(angle) * currentRadius;
      
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
  bool shouldRepaint(StarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class BurstPainter extends CustomPainter {
  final List<BurstParticle> particles;
  final double progress;

  BurstPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(1.0 - progress)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width + cos(particle.angle) * progress * size.width * particle.velocity * 0.3;
      final y = particle.y * size.height + sin(particle.angle) * progress * size.height * particle.velocity * 0.3;

      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1.0 - progress),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class SuperLikeButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;
  final double size;
  final bool enableAnimation;

  const SuperLikeButton({
    Key? key,
    this.onPressed,
    this.isEnabled = true,
    this.size = 60.0,
    this.enableAnimation = true,
  }) : super(key: key);

  @override
  State<SuperLikeButton> createState() => _SuperLikeButtonState();
}

class _SuperLikeButtonState extends State<SuperLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    if (widget.enableAnimation) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );

      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 0.9,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));

      _rotationAnimation = Tween<double>(
        begin: 0.0,
        end: 0.1,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    if (widget.enableAnimation) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    
    setState(() {
      _isPressed = true;
    });
    
    if (widget.enableAnimation) {
      _controller.forward();
    }
    
    HapticFeedbackService.buttonPress();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    
    setState(() {
      _isPressed = false;
    });
    
    if (widget.enableAnimation) {
      _controller.reverse();
    }
    
    widget.onPressed?.call();
    HapticFeedbackService.superLike();
  }

  void _onTapCancel() {
    if (!widget.isEnabled) return;
    
    setState(() {
      _isPressed = false;
    });
    
    if (widget.enableAnimation) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: widget.enableAnimation ? _buildAnimatedButton() : _buildStaticButton(),
    );
  }

  Widget _buildAnimatedButton() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: _buildButtonContainer(),
          ),
        );
      },
    );
  }

  Widget _buildStaticButton() {
    return _buildButtonContainer();
  }

  Widget _buildButtonContainer() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.prideYellow,
            AppColors.prideOrange,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.prideYellow.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        Icons.star,
        color: Colors.white,
        size: widget.size * 0.6,
      ),
    );
  }
}

class SuperLikeOverlay extends StatefulWidget {
  final String message;
  final VoidCallback? onDismiss;
  final Duration displayDuration;

  const SuperLikeOverlay({
    Key? key,
    this.message = "Super Like!",
    this.onDismiss,
    this.displayDuration = const Duration(milliseconds: 2000),
  }) : super(key: key);

  @override
  State<SuperLikeOverlay> createState() => _SuperLikeOverlayState();
}

class _SuperLikeOverlayState extends State<SuperLikeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
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
      begin: 0.3,
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
                    AppColors.prideYellow.withOpacity(0.9),
                    AppColors.prideOrange.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.prideYellow.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.message,
                    style: AppTypography.headlineSmall.copyWith(
                      color: Colors.white,
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
