import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class TypingIndicator extends StatefulWidget {
  final bool isTyping;
  final String? typingText;

  const TypingIndicator({
    Key? key,
    required this.isTyping,
    this.typingText,
  }) : super(key: key);

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animations = List.generate(
      3,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.easeInOut,
          ),
        ),
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
    if (!widget.isTyping) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.typingText != null) ...[
            Text(
              widget.typingText!,
              style: TextStyle(
                color: AppColors.textSecondaryLight,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
          ],
          ...List.generate(
            3,
            (index) => AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(
                      0.3 + _animations[index].value * 0.7,
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 