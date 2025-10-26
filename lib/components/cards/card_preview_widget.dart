import 'package:flutter/material.dart';
import '../theme/colors.dart';

class CardPreviewWidget extends StatelessWidget {
  final Widget child;
  final int stackIndex;
  final int maxStackSize;
  final double previewOpacity;
  final double previewScale;
  final double previewOffset;
  final bool showPreview;

  const CardPreviewWidget({
    Key? key,
    required this.child,
    required this.stackIndex,
    this.maxStackSize = 3,
    this.previewOpacity = 0.6,
    this.previewScale = 0.95,
    this.previewOffset = 20.0,
    this.showPreview = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showPreview || stackIndex == 0) {
      return child;
    }

    final opacity = _calculateOpacity();
    final scale = _calculateScale();
    final offset = _calculateOffset();

    return Transform.translate(
      offset: Offset(0, offset),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1 * opacity),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  double _calculateOpacity() {
    if (stackIndex >= maxStackSize) return 0.0;
    return previewOpacity * (1.0 - (stackIndex / maxStackSize));
  }

  double _calculateScale() {
    if (stackIndex >= maxStackSize) return 0.0;
    return previewScale * (1.0 - (stackIndex * 0.05));
  }

  double _calculateOffset() {
    return stackIndex * previewOffset;
  }
}

class AnimatedCardPreview extends StatefulWidget {
  final Widget child;
  final int stackIndex;
  final int maxStackSize;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool showPreview;

  const AnimatedCardPreview({
    Key? key,
    required this.child,
    required this.stackIndex,
    this.maxStackSize = 3,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.showPreview = true,
  }) : super(key: key);

  @override
  State<AnimatedCardPreview> createState() => _AnimatedCardPreviewState();
}

class _AnimatedCardPreviewState extends State<AnimatedCardPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: _calculateOpacity(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: _calculateScale(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 50),
      end: Offset(0, _calculateOffset()),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCardPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stackIndex != widget.stackIndex) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    _opacityAnimation = Tween<double>(
      begin: _opacityAnimation.value,
      end: _calculateOpacity(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    _scaleAnimation = Tween<double>(
      begin: _scaleAnimation.value,
      end: _calculateScale(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    _offsetAnimation = Tween<Offset>(
      begin: _offsetAnimation.value,
      end: Offset(0, _calculateOffset()),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _calculateOpacity() {
    if (!widget.showPreview || widget.stackIndex >= widget.maxStackSize) return 0.0;
    return 0.6 * (1.0 - (widget.stackIndex / widget.maxStackSize));
  }

  double _calculateScale() {
    if (!widget.showPreview || widget.stackIndex >= widget.maxStackSize) return 0.0;
    return 0.95 * (1.0 - (widget.stackIndex * 0.05));
  }

  double _calculateOffset() {
    return widget.stackIndex * 20.0;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showPreview || widget.stackIndex == 0) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _offsetAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1 * _opacityAnimation.value),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class CardPreviewStack extends StatelessWidget {
  final List<Widget> cards;
  final int maxVisibleCards;
  final double cardWidth;
  final double cardHeight;
  final EdgeInsets padding;

  const CardPreviewStack({
    Key? key,
    required this.cards,
    this.maxVisibleCards = 3,
    this.cardWidth = 300.0,
    this.cardHeight = 400.0,
    this.padding = const EdgeInsets.all(20),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Stack(
        children: [
          // Render cards in reverse order so the first card appears on top
          for (int i = cards.length - 1; i >= 0 && i >= cards.length - maxVisibleCards; i--)
            _buildCard(cards.length - 1 - i, cards[i]),
        ],
      ),
    );
  }

  Widget _buildCard(int stackIndex, Widget card) {
    return CardPreviewWidget(
      stackIndex: stackIndex,
      maxStackSize: maxVisibleCards,
      child: card,
    );
  }
}

class PreviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final Color? backgroundColor;
  final Widget? child;

  const PreviewCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.backgroundColor,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackgroundDark,
        borderRadius: BorderRadius.circular(20),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: child ?? _buildDefaultContent(),
    );
  }

  Widget _buildDefaultContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.headlineSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
