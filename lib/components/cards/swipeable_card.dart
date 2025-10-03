import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../services/haptic_feedback_service.dart';

class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onTap;
  final double threshold;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool showSwipeIndicators;
  final Color? leftSwipeColor;
  final Color? rightSwipeColor;
  final Color? upSwipeColor;

  const SwipeableCard({
    Key? key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onTap,
    this.threshold = 100.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.showSwipeIndicators = true,
    this.leftSwipeColor,
    this.rightSwipeColor,
    this.upSwipeColor,
  }) : super(key: key);

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  Offset _offset = Offset.zero;
  bool _isAnimating = false;
  SwipeDirection? _currentSwipeDirection;
  double _swipeProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
    
    _controller.addListener(() {
      setState(() {
        _offset = _animation.value;
      });
    });
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isAnimating = false;
        if (_offset.dx.abs() > widget.threshold || _offset.dy < -widget.threshold) {
          _triggerSwipeAction();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    
    setState(() {
      _offset += details.delta;
      
      // Calculate swipe progress and direction
      _swipeProgress = _calculateSwipeProgress();
      _currentSwipeDirection = _getSwipeDirection();
      
      // Add rotation based on horizontal movement
      final rotation = _offset.dx * 0.001;
      _rotationAnimation = Tween<double>(
        begin: _rotationAnimation.value,
        end: rotation,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.animationCurve,
      ));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating) return;
    
    final velocity = details.velocity.pixelsPerSecond;
    final shouldSwipeLeft = _offset.dx < -widget.threshold || velocity.dx < -500;
    final shouldSwipeRight = _offset.dx > widget.threshold || velocity.dx > 500;
    final shouldSwipeUp = _offset.dy < -widget.threshold || velocity.dy < -500;
    
    if (shouldSwipeLeft) {
      _animateSwipe(Offset(-1000, _offset.dy), -0.3);
      HapticFeedbackService.medium();
    } else if (shouldSwipeRight) {
      _animateSwipe(Offset(1000, _offset.dy), 0.3);
      HapticFeedbackService.medium();
    } else if (shouldSwipeUp) {
      _animateSwipe(Offset(_offset.dx, -1000), 0.0);
      HapticFeedbackService.light();
    } else {
      _animateSwipe(Offset.zero, 0.0);
      HapticFeedbackService.selection();
    }
  }

  void _animateSwipe(Offset endOffset, double endRotation) {
    _isAnimating = true;
    
    _animation = Tween<Offset>(
      begin: _offset,
      end: endOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: _rotationAnimation.value,
      end: endRotation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: endOffset == Offset.zero ? 1.0 : 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
    
    _controller.forward(from: 0);
  }

  void _triggerSwipeAction() {
    if (_offset.dx < -widget.threshold) {
      widget.onSwipeLeft?.call();
    } else if (_offset.dx > widget.threshold) {
      widget.onSwipeRight?.call();
    } else if (_offset.dy < -widget.threshold) {
      widget.onSwipeUp?.call();
    }
  }

  double _calculateSwipeProgress() {
    final maxDistance = widget.threshold * 2;
    if (_offset.dx.abs() > _offset.dy.abs()) {
      return (_offset.dx.abs() / maxDistance).clamp(0.0, 1.0);
    } else {
      return (_offset.dy.abs() / maxDistance).clamp(0.0, 1.0);
    }
  }

  SwipeDirection? _getSwipeDirection() {
    if (_offset.dx.abs() > _offset.dy.abs()) {
      if (_offset.dx < -widget.threshold * 0.3) return SwipeDirection.left;
      if (_offset.dx > widget.threshold * 0.3) return SwipeDirection.right;
    } else {
      if (_offset.dy < -widget.threshold * 0.3) return SwipeDirection.up;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: widget.onTap,
      child: Stack(
        children: [
          // Main card content
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: _offset,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
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
          ),
          
          // Swipe indicators
          if (widget.showSwipeIndicators && _currentSwipeDirection != null)
            _buildSwipeIndicators(),
        ],
      ),
    );
  }

  Widget _buildSwipeIndicators() {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: _swipeProgress,
        duration: const Duration(milliseconds: 200),
        child: Stack(
          children: [
            // Left swipe indicator
            if (_currentSwipeDirection == SwipeDirection.left)
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildSwipeIndicator(
                    SwipeDirection.left,
                    widget.leftSwipeColor ?? AppColors.feedbackError,
                  ),
                ),
              ),
            
            // Right swipe indicator
            if (_currentSwipeDirection == SwipeDirection.right)
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildSwipeIndicator(
                    SwipeDirection.right,
                    widget.rightSwipeColor ?? AppColors.feedbackSuccess,
                  ),
                ),
              ),
            
            // Up swipe indicator
            if (_currentSwipeDirection == SwipeDirection.up)
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildSwipeIndicator(
                    SwipeDirection.up,
                    widget.upSwipeColor ?? AppColors.feedbackWarning,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeIndicator(SwipeDirection direction, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Icon(
        _getIconForDirection(direction),
        color: color,
        size: 32,
      ),
    );
  }

  IconData _getIconForDirection(SwipeDirection direction) {
    switch (direction) {
      case SwipeDirection.left:
        return Icons.close;
      case SwipeDirection.right:
        return Icons.favorite;
      case SwipeDirection.up:
        return Icons.star;
    }
  }
}

class SwipeIndicator extends StatelessWidget {
  final double progress;
  final SwipeDirection direction;
  final Color? color;

  const SwipeIndicator({
    Key? key,
    required this.progress,
    required this.direction,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final indicatorColor = color ?? AppColors.feedbackError;
    
    return AnimatedOpacity(
      opacity: progress.clamp(0.0, 1.0),
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: indicatorColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: indicatorColor,
            width: 2,
          ),
        ),
        child: Icon(
          _getIconForDirection(direction),
          color: indicatorColor,
          size: 24,
        ),
      ),
    );
  }

  IconData _getIconForDirection(SwipeDirection direction) {
    switch (direction) {
      case SwipeDirection.left:
        return Icons.close;
      case SwipeDirection.right:
        return Icons.favorite;
      case SwipeDirection.up:
        return Icons.star;
    }
  }
}

enum SwipeDirection {
  left,
  right,
  up,
}
