import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../services/haptic_feedback_service.dart';
import 'cards/swipeable_card.dart';

class CardStackManager extends StatefulWidget {
  final List<dynamic> cards;
  final Widget Function(dynamic card, int index) cardBuilder;
  final VoidCallback? onStackEmpty;
  final Function(dynamic card, SwipeDirection direction)? onSwipe;
  final double cardWidth;
  final double cardHeight;
  final int maxVisibleCards;
  final Duration animationDuration;
  final Curve animationCurve;

  const CardStackManager({
    Key? key,
    required this.cards,
    required this.cardBuilder,
    this.onStackEmpty,
    this.onSwipe,
    this.cardWidth = 300.0,
    this.cardHeight = 400.0,
    this.maxVisibleCards = 3,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<CardStackManager> createState() => _CardStackManagerState();
}

class _CardStackManagerState extends State<CardStackManager>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _rotationAnimations;
  
  int _currentIndex = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.maxVisibleCards,
      (index) => AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: Offset.zero,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: widget.animationCurve,
      ));
    }).toList();

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: widget.animationCurve,
      ));
    }).toList();

    _rotationAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: widget.animationCurve,
      ));
    }).toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _swipeCard(SwipeDirection direction) {
    if (_isAnimating || _currentIndex >= widget.cards.length) return;

    _isAnimating = true;
    final card = widget.cards[_currentIndex];
    
    // Trigger haptic feedback
    switch (direction) {
      case SwipeDirection.left:
        HapticFeedbackService.medium();
        break;
      case SwipeDirection.right:
        HapticFeedbackService.medium();
        break;
      case SwipeDirection.up:
        HapticFeedbackService.light();
        break;
    }

    // Animate the current card out
    _animateCardOut(0, direction);

    // Animate remaining cards up
    for (int i = 1; i < widget.maxVisibleCards && i < widget.cards.length - _currentIndex; i++) {
      _animateCardUp(i);
    }

    // Call swipe callback
    widget.onSwipe?.call(card, direction);

    // Move to next card
    _currentIndex++;

    // Check if stack is empty
    if (_currentIndex >= widget.cards.length) {
      Future.delayed(widget.animationDuration, () {
        widget.onStackEmpty?.call();
      });
    }
  }

  void _animateCardOut(int cardIndex, SwipeDirection direction) {
    final controller = _controllers[cardIndex];
    final endOffset = _getSwipeOffset(direction);
    final endRotation = _getSwipeRotation(direction);

    _animations[cardIndex] = Tween<Offset>(
      begin: Offset.zero,
      end: endOffset,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: widget.animationCurve,
    ));

    _rotationAnimations[cardIndex] = Tween<double>(
      begin: 0.0,
      end: endRotation,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: widget.animationCurve,
    ));

    _scaleAnimations[cardIndex] = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: widget.animationCurve,
    ));

    controller.forward().then((_) {
      controller.reset();
      _isAnimating = false;
    });
  }

  void _animateCardUp(int cardIndex) {
    final controller = _controllers[cardIndex];
    final newIndex = cardIndex - 1;

    _animations[cardIndex] = Tween<Offset>(
      begin: Offset(0, cardIndex * 20.0),
      end: Offset(0, newIndex * 20.0),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: widget.animationCurve,
    ));

    _scaleAnimations[cardIndex] = Tween<double>(
      begin: 1.0 - (cardIndex * 0.05),
      end: 1.0 - (newIndex * 0.05),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: widget.animationCurve,
    ));

    controller.forward().then((_) {
      controller.reset();
    });
  }

  Offset _getSwipeOffset(SwipeDirection direction) {
    switch (direction) {
      case SwipeDirection.left:
        return const Offset(-1000, 0);
      case SwipeDirection.right:
        return const Offset(1000, 0);
      case SwipeDirection.up:
        return const Offset(0, -1000);
    }
  }

  double _getSwipeRotation(SwipeDirection direction) {
    switch (direction) {
      case SwipeDirection.left:
        return -0.3;
      case SwipeDirection.right:
        return 0.3;
      case SwipeDirection.up:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.cardWidth,
      height: widget.cardHeight,
      child: Stack(
        children: [
          // Render visible cards
          for (int i = 0; i < widget.maxVisibleCards && i < widget.cards.length - _currentIndex; i++)
            _buildCard(i),
          
          // Action buttons overlay
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCard(int stackIndex) {
    final cardIndex = _currentIndex + stackIndex;
    if (cardIndex >= widget.cards.length) return const SizedBox.shrink();

    final card = widget.cards[cardIndex];
    final isTopCard = stackIndex == 0;

    return AnimatedBuilder(
      animation: _controllers[stackIndex],
      builder: (context, child) {
        return Transform.translate(
          offset: _animations[stackIndex].value,
          child: Transform.rotate(
            angle: _rotationAnimations[stackIndex].value,
            child: Transform.scale(
              scale: _scaleAnimations[stackIndex].value,
              child: Positioned(
                top: stackIndex * 20.0,
                left: 0,
                right: 0,
                child: SwipeableCard(
                  onSwipeLeft: isTopCard ? () => _swipeCard(SwipeDirection.left) : null,
                  onSwipeRight: isTopCard ? () => _swipeCard(SwipeDirection.right) : null,
                  onSwipeUp: isTopCard ? () => _swipeCard(SwipeDirection.up) : null,
                  child: widget.cardBuilder(card, cardIndex),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.close,
            color: AppColors.feedbackError,
            onTap: () => _swipeCard(SwipeDirection.left),
          ),
          _buildActionButton(
            icon: Icons.star,
            color: AppColors.feedbackWarning,
            onTap: () => _swipeCard(SwipeDirection.up),
          ),
          _buildActionButton(
            icon: Icons.favorite,
            color: AppColors.feedbackSuccess,
            onTap: () => _swipeCard(SwipeDirection.right),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

class CardStackController {
  final _CardStackManagerState _state;

  CardStackController(this._state);

  void swipeLeft() => _state._swipeCard(SwipeDirection.left);
  void swipeRight() => _state._swipeCard(SwipeDirection.right);
  void swipeUp() => _state._swipeCard(SwipeDirection.up);
  
  int get currentIndex => _state._currentIndex;
  int get remainingCards => _state.widget.cards.length - _state._currentIndex;
  bool get isEmpty => remainingCards <= 0;
}
