import 'package:flutter/material.dart';

/// Simple skeleton loader service
class SkeletonLoaderService {
  /// Create a skeleton profile card
  static Widget createSkeletonProfileCard() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Avatar
          _ShimmerContainer(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Name lines
          _ShimmerContainer(
            child: Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[300],
              ),
            ),
          ),
          SizedBox(height: 8),
          _ShimmerContainer(
            child: Container(
              width: 80,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Create a skeleton box
  static Widget createSkeletonBox({double width = 100, double height = 50}) {
    return _ShimmerContainer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[300],
        ),
      ),
    );
  }

  /// Create skeleton text lines
  static Widget createSkeletonText({int lines = 2, double lineHeight = 16}) {
    return Column(
      children: List.generate(lines, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? 8 : 0),
          child: _ShimmerContainer(
            child: Container(
              height: lineHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[300],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Simple skeleton card widget
class SkeletonCard extends StatelessWidget {
  final double height;
  final Widget? child;

  const SkeletonCard({
    super.key,
    this.height = 100,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child ?? _ShimmerContainer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[300],
          ),
        ),
      ),
    );
  }
}

/// Simple shimmer effect container
class _ShimmerContainer extends StatelessWidget {
  final Widget child;
  static const Duration _duration = Duration(milliseconds: 1500);

  const _ShimmerContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: _duration,
      tween: Tween(begin: 0.3, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      onEnd: () {
        // Would restart animation in a real implementation
      },
      child: child,
    );
  }
}