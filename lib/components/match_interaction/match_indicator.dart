import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class MatchIndicator extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const MatchIndicator({
    Key? key,
    required this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<MatchIndicator> createState() => _MatchIndicatorState();
}

class _MatchIndicatorState extends State<MatchIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final List<Confetti> _confetti = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      50,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1000 + _random.nextInt(1000)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
    }).toList();

    _generateConfetti();
    _startAnimation();
  }

  void _generateConfetti() {
    for (int i = 0; i < 50; i++) {
      _confetti.add(
        Confetti(
          color: _getRandomColor(),
          size: 8.0 + _random.nextDouble() * 8.0,
          startX: 0.5,
          startY: 0.5,
          angle: _random.nextDouble() * 2 * pi,
          speed: 0.5 + _random.nextDouble() * 0.5,
        ),
      );
    }
  }

  Color _getRandomColor() {
    final colors = [
      AppColors.primaryLight,
      AppColors.secondaryLight,
      AppColors.successLight,
      AppColors.warningLight,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _startAnimation() {
    for (var controller in _controllers) {
      controller.forward();
    }

    Future.delayed(const Duration(seconds: 2), () {
      widget.onAnimationComplete();
    });
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
    return Stack(
      children: [
        ...List.generate(50, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              final confetti = _confetti[index];
              final progress = _animations[index].value;
              final x = confetti.startX + cos(confetti.angle) * confetti.speed * progress;
              final y = confetti.startY + sin(confetti.angle) * confetti.speed * progress;

              return Positioned(
                left: x * MediaQuery.of(context).size.width,
                top: y * MediaQuery.of(context).size.height,
                child: Transform.rotate(
                  angle: progress * 2 * pi,
                  child: Container(
                    width: confetti.size,
                    height: confetti.size,
                    decoration: BoxDecoration(
                      color: confetti.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'It\'s a Match!',
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You and your match have liked each other',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Confetti {
  final Color color;
  final double size;
  final double startX;
  final double startY;
  final double angle;
  final double speed;

  Confetti({
    required this.color,
    required this.size,
    required this.startX,
    required this.startY,
    required this.angle,
    required this.speed,
  });
} 