import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class AnimatedAvatar extends StatefulWidget {
  final String imageUrl;
  final double size;
  final bool isNewMatch;
  final VoidCallback? onTap;

  const AnimatedAvatar({
    Key? key,
    required this.imageUrl,
    this.size = 80.0,
    this.isNewMatch = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<AnimatedAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: widget.isNewMatch
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryLight.withOpacity(_glowAnimation.value),
                        AppColors.secondaryLight.withOpacity(_glowAnimation.value),
                        AppColors.successLight.withOpacity(_glowAnimation.value),
                      ],
                    )
                  : null,
              boxShadow: widget.isNewMatch
                  ? [
                      BoxShadow(
                        color: AppColors.primaryLight.withOpacity(0.3 * _glowAnimation.value),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isNewMatch
                      ? Colors.white.withOpacity(0.5)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.size / 2),
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.cardBackgroundLight,
                      child: Icon(
                        Icons.person,
                        size: widget.size * 0.6,
                        color: AppColors.textSecondaryLight,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 