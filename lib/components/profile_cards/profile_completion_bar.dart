import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class ProfileCompletionBar extends StatefulWidget {
  final double progress;
  final double height;
  final Duration animationDuration;

  const ProfileCompletionBar({
    Key? key,
    required this.progress,
    this.height = 8.0,
    this.animationDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<ProfileCompletionBar> createState() => _ProfileCompletionBarState();
}

class _ProfileCompletionBarState extends State<ProfileCompletionBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(ProfileCompletionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) {
      return AppColors.errorLight;
    } else if (progress < 0.7) {
      return AppColors.warningLight;
    } else {
      return AppColors.successLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(widget.height / 2),
              child: LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: AppColors.cardBackgroundLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(_progressAnimation.value),
                ),
                minHeight: widget.height,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(_progressAnimation.value * 100).toInt()}% Complete',
              style: AppTypography.bodySmall.copyWith(
                color: _getProgressColor(_progressAnimation.value),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
} 