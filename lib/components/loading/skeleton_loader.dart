import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/colors.dart';

/// A skeleton loader widget that provides animated loading placeholders
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final Widget? child;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.child,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor ?? AppColors.surface,
                widget.highlightColor ?? AppColors.surface.withOpacity(0.3),
                widget.baseColor ?? AppColors.surface,
              ],
              stops: [
                math.max(0.0, _animation.value - 0.3),
                _animation.value,
                math.min(1.0, _animation.value + 0.3),
              ],
            ),
          ),
          child: widget.child,
        );
  }
}

/// A skeleton loader for text content
class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const SkeletonText({
    super.key,
    required this.width,
    this.height = 16.0,
    this.borderRadius = 4.0,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: borderRadius,
      baseColor: baseColor,
      highlightColor: highlightColor,
      duration: duration,
    );
  }
}

/// A skeleton loader for circular content (like avatars)
class SkeletonCircle extends StatelessWidget {
  final double size;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const SkeletonCircle({
    super.key,
    required this.size,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: size,
      height: size,
      borderRadius: size / 2,
      baseColor: baseColor,
      highlightColor: highlightColor,
      duration: duration,
    );
  }
}

/// A skeleton loader for list items
class SkeletonListItem extends StatelessWidget {
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final bool showAvatar;
  final double avatarSize;
  final int textLines;
  final double textLineHeight;
  final double textLineSpacing;

  const SkeletonListItem({
    super.key,
    this.height = 80.0,
    this.borderRadius = 8.0,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.showAvatar = true,
    this.avatarSize = 48.0,
    this.textLines = 2,
    this.textLineHeight = 16.0,
    this.textLineSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (showAvatar) ...[
            SkeletonCircle(
              size: avatarSize,
              baseColor: baseColor,
              highlightColor: highlightColor,
              duration: duration,
            ),
            const SizedBox(width: 16.0),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                textLines,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index < textLines - 1 ? textLineSpacing : 0,
                  ),
                  child: SkeletonText(
                    width: index == 0 ? double.infinity : 200.0,
                    height: textLineHeight,
                    borderRadius: borderRadius / 2,
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    duration: duration,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A skeleton loader for grid items
class SkeletonGridItem extends StatelessWidget {
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final bool showText;
  final int textLines;
  final double textLineHeight;
  final double textLineSpacing;

  const SkeletonGridItem({
    super.key,
    this.height = 200.0,
    this.borderRadius = 12.0,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.showText = true,
    this.textLines = 2,
    this.textLineHeight = 16.0,
    this.textLineSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SkeletonLoader(
              width: double.infinity,
              height: double.infinity,
              borderRadius: borderRadius,
              baseColor: baseColor,
              highlightColor: highlightColor,
              duration: duration,
            ),
          ),
          if (showText) ...[
            const SizedBox(height: 16.0),
            ...List.generate(
              textLines,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index < textLines - 1 ? textLineSpacing : 0,
                ),
                child: SkeletonText(
                  width: index == 0 ? double.infinity : 150.0,
                  height: textLineHeight,
                  borderRadius: borderRadius / 2,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  duration: duration,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A skeleton loader for card content
class SkeletonCard extends StatelessWidget {
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final bool showHeader;
  final bool showContent;
  final int contentLines;
  final double contentLineHeight;
  final double contentLineSpacing;

  const SkeletonCard({
    super.key,
    this.height = 300.0,
    this.borderRadius = 12.0,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.showHeader = true,
    this.showContent = true,
    this.contentLines = 3,
    this.contentLineHeight = 16.0,
    this.contentLineSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Row(
              children: [
                SkeletonCircle(
                  size: 40.0,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  duration: duration,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonText(
                        width: 120.0,
                        height: 16.0,
                        borderRadius: borderRadius / 2,
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                        duration: duration,
                      ),
                      const SizedBox(height: 4.0),
                      SkeletonText(
                        width: 80.0,
                        height: 12.0,
                        borderRadius: borderRadius / 2,
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                        duration: duration,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
          ],
          if (showContent) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  contentLines,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index < contentLines - 1 ? contentLineSpacing : 0,
                    ),
                    child: SkeletonText(
                      width: index == contentLines - 1 ? 200.0 : double.infinity,
                      height: contentLineHeight,
                      borderRadius: borderRadius / 2,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      duration: duration,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
