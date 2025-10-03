import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/colors.dart';
import '../services/haptic_feedback_service.dart';
import '../services/audio_service.dart';

class SuperLikeSheet extends StatefulWidget {
  final String userName;
  final String userImageUrl;
  final VoidCallback? onSuperLike;
  final VoidCallback? onCancel;
  final int remainingSuperLikes;

  const SuperLikeSheet({
    Key? key,
    required this.userName,
    required this.userImageUrl,
    this.onSuperLike,
    this.onCancel,
    this.remainingSuperLikes = 0,
  }) : super(key: key);

  @override
  State<SuperLikeSheet> createState() => _SuperLikeSheetState();
}

class _SuperLikeSheetState extends State<SuperLikeSheet>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _starController;
  late AnimationController _pulseController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _starAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isSuperLiking = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _controller.forward();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _starController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _starAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _starController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHandle(),
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildUserProfile(),
                  const SizedBox(height: 24),
                  _buildSuperLikeInfo(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.textSecondaryDark,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.star,
          color: AppColors.prideYellow,
          size: 28,
        ),
        const SizedBox(width: 12),
        const Text(
          'Super Like',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            HapticFeedbackService.selection();
            widget.onCancel?.call();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.close,
              color: AppColors.textSecondaryDark,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfile() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.prideYellow.withOpacity(0.2),
                  AppColors.prideOrange.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.prideYellow.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.prideYellow,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.prideYellow.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      widget.userImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceSecondary,
                        child: Icon(
                          Icons.person,
                          color: AppColors.textSecondaryDark,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Show them you really like them!',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuperLikeInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.prideYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.prideYellow.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.prideYellow,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Super Like Benefits',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            'Get noticed first',
            'Your profile appears at the top of their stack',
            Icons.visibility,
          ),
          const SizedBox(height: 8),
          _buildBenefitItem(
            'Higher match rate',
            'Super Likes are 3x more likely to result in a match',
            Icons.trending_up,
          ),
          const SizedBox(height: 8),
          _buildBenefitItem(
            'Stand out',
            'Show them you\'re really interested',
            Icons.star,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String title, String description, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.prideYellow,
          size: 16,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSuperLiking ? null : _handleSuperLike,
            icon: _isSuperLiking 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : AnimatedBuilder(
                    animation: _starAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _starAnimation.value,
                        child: const Icon(Icons.star),
                      );
                    },
                  ),
            label: Text(_isSuperLiking ? 'Sending Super Like...' : 'Send Super Like'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.prideYellow,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              shadowColor: AppColors.prideYellow.withOpacity(0.3),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (widget.remainingSuperLikes > 0)
          Text(
            '${widget.remainingSuperLikes} Super Likes remaining',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryDark,
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.feedbackWarning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.feedbackWarning.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning,
                  color: AppColors.feedbackWarning,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'No Super Likes remaining',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.feedbackWarning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            HapticFeedbackService.selection();
            widget.onCancel?.call();
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.borderDefault),
            foregroundColor: AppColors.textPrimaryDark,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void _handleSuperLike() async {
    if (_isSuperLiking) return;

    setState(() {
      _isSuperLiking = true;
    });

    // Play super like animation
    _starController.forward();
    
    // Play sound effect
    AudioService().playSound(SoundType.superLike);
    
    // Haptic feedback
    HapticFeedbackService.superLike();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isSuperLiking = false;
      });
      
      widget.onSuperLike?.call();
    }
  }
}

class SuperLikeButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;
  final double size;
  final int remainingCount;
  final bool showCount;

  const SuperLikeButton({
    Key? key,
    this.onPressed,
    this.isEnabled = true,
    this.size = 60.0,
    this.remainingCount = 0,
    this.showCount = true,
  }) : super(key: key);

  @override
  State<SuperLikeButton> createState() => _SuperLikeButtonState();
}

class _SuperLikeButtonState extends State<SuperLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Stack(
                children: [
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.prideYellow,
                          AppColors.prideOrange,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.prideYellow.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.white,
                      size: widget.size * 0.6,
                    ),
                  ),
                  if (widget.showCount && widget.remainingCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.feedbackError,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          widget.remainingCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    
    setState(() {
      _isPressed = true;
    });
    
    _controller.forward();
    HapticFeedbackService.buttonPress();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    
    setState(() {
      _isPressed = false;
    });
    
    _controller.reverse();
  }

  void _onTapCancel() {
    if (!widget.isEnabled) return;
    
    setState(() {
      _isPressed = false;
    });
    
    _controller.reverse();
  }

  void _onTap() {
    if (!widget.isEnabled) return;
    
    widget.onPressed?.call();
    HapticFeedbackService.superLike();
  }
}

class SuperLikeCounter extends StatelessWidget {
  final int remainingCount;
  final VoidCallback? onTap;

  const SuperLikeCounter({
    Key? key,
    required this.remainingCount,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackService.selection();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.prideYellow.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.prideYellow.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: AppColors.prideYellow,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              remainingCount.toString(),
              style: const TextStyle(
                color: AppColors.prideYellow,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
