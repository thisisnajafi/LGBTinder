import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Premium Badge Component
/// 
/// Shows premium badge on user profiles and UI elements
class PremiumBadge extends StatelessWidget {
  final String tier; // bronze, silver, gold
  final double size;
  final bool showLabel;

  const PremiumBadge({
    Key? key,
    required this.tier,
    this.size = 24,
    this.showLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 8 : 4,
        vertical: showLabel ? 4 : 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getTierColors(),
        ),
        borderRadius: BorderRadius.circular(showLabel ? 12 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTierIcon(),
            color: Colors.white,
            size: size,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              _getTierLabel(),
              style: AppTypography.body3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Color> _getTierColors() {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return [
          const Color(0xFFCD7F32),
          const Color(0xFFA0522D),
        ];
      case 'silver':
        return [
          const Color(0xFFC0C0C0),
          const Color(0xFF808080),
        ];
      case 'gold':
        return [
          const Color(0xFFFFD700),
          const Color(0xFFFFA500),
        ];
      default:
        return [
          AppColors.primary,
          AppColors.primary.withOpacity(0.7),
        ];
    }
  }

  IconData _getTierIcon() {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return Icons.star;
      case 'silver':
        return Icons.star_half;
      case 'gold':
        return Icons.stars;
      default:
        return Icons.workspace_premium;
    }
  }

  String _getTierLabel() {
    return tier.toUpperCase();
  }
}

/// Animated Premium Badge
/// 
/// Premium badge with gradient animation
class AnimatedPremiumBadge extends StatefulWidget {
  final String tier;
  final double size;
  final bool showLabel;

  const AnimatedPremiumBadge({
    Key? key,
    required this.tier,
    this.size = 24,
    this.showLabel = false,
  }) : super(key: key);

  @override
  State<AnimatedPremiumBadge> createState() => _AnimatedPremiumBadgeState();
}

class _AnimatedPremiumBadgeState extends State<AnimatedPremiumBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        return Opacity(
          opacity: _animation.value,
          child: PremiumBadge(
            tier: widget.tier,
            size: widget.size,
            showLabel: widget.showLabel,
          ),
        );
      },
    );
  }
}

/// Premium Feature Lock
/// 
/// Shows locked feature with upgrade prompt
class PremiumFeatureLock extends StatelessWidget {
  final String featureName;
  final VoidCallback onUpgrade;

  const PremiumFeatureLock({
    Key? key,
    required this.featureName,
    required this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock,
            color: AppColors.primary,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            '$featureName is Premium',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Upgrade to unlock this feature',
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onUpgrade,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Upgrade Now',
                  style: AppTypography.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium Indicator Icon
/// 
/// Small premium icon for lists
class PremiumIndicator extends StatelessWidget {
  final String tier;
  final double size;

  const PremiumIndicator({
    Key? key,
    required this.tier,
    this.size = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getTierColors(),
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.workspace_premium,
        color: Colors.white,
        size: size,
      ),
    );
  }

  List<Color> _getTierColors() {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return [
          const Color(0xFFCD7F32),
          const Color(0xFFA0522D),
        ];
      case 'silver':
        return [
          const Color(0xFFC0C0C0),
          const Color(0xFF808080),
        ];
      case 'gold':
        return [
          const Color(0xFFFFD700),
          const Color(0xFFFFA500),
        ];
      default:
        return [
          AppColors.primary,
          AppColors.primary.withOpacity(0.7),
        ];
    }
  }
}

/// Unlock Animation
/// 
/// Celebration animation when subscribing
class UnlockAnimation extends StatefulWidget {
  final VoidCallback? onComplete;

  const UnlockAnimation({
    Key? key,
    this.onComplete,
  }) : super(key: key);

  @override
  State<UnlockAnimation> createState() => _UnlockAnimationState();
}

class _UnlockAnimationState extends State<UnlockAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700),
                    Color(0xFFFFA500),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_open,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Premium Success Confetti
/// 
/// Confetti animation for successful purchase
class PremiumSuccessConfetti extends StatefulWidget {
  const PremiumSuccessConfetti({Key? key}) : super(key: key);

  @override
  State<PremiumSuccessConfetti> createState() => _PremiumSuccessConfettiState();
}

class _PremiumSuccessConfettiState extends State<PremiumSuccessConfetti>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Generate confetti particles
    for (int i = 0; i < 50; i++) {
      _particles.add(ConfettiParticle(
        color: _getRandomColor(),
        startX: (i % 10) * 0.1,
        delay: (i / 50),
      ));
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRandomColor() {
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFFFA500),
      AppColors.primary,
      AppColors.success,
      const Color(0xFFFF1493),
    ];
    return colors[_particles.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 300),
          painter: ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class ConfettiParticle {
  final Color color;
  final double startX;
  final double delay;

  ConfettiParticle({
    required this.color,
    required this.startX,
    required this.delay,
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
      final particleProgress = ((progress - particle.delay) / (1 - particle.delay)).clamp(0.0, 1.0);
      
      final x = size.width * particle.startX;
      final y = size.height * particleProgress * 1.5;
      
      final paint = Paint()
        ..color = particle.color.withOpacity(1 - particleProgress)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

