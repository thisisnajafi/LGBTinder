import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../services/haptic_feedback_service.dart';

class ResponsiveModal extends StatefulWidget {
  final Widget child;
  final bool isDismissible;
  final bool enableBackdrop;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double? maxWidth;
  final double? maxHeight;
  final Alignment alignment;
  final Duration animationDuration;
  final Curve animationCurve;

  const ResponsiveModal({
    Key? key,
    required this.child,
    this.isDismissible = true,
    this.enableBackdrop = true,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.maxWidth,
    this.maxHeight,
    this.alignment = Alignment.center,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<ResponsiveModal> createState() => _ResponsiveModalState();
}

class _ResponsiveModalState extends State<ResponsiveModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _controller.forward();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (widget.isDismissible) {
      _controller.reverse().then((_) {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 1200;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.isDismissible ? _dismiss : null,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: widget.enableBackdrop 
              ? Colors.black.withOpacity(0.5)
              : Colors.transparent,
          child: GestureDetector(
            onTap: () {}, // Prevent tap from bubbling up
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Align(
                      alignment: widget.alignment,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: widget.maxWidth ?? _getMaxWidth(screenSize, isTablet, isDesktop),
                          maxHeight: widget.maxHeight ?? _getMaxHeight(screenSize, isTablet, isDesktop),
                        ),
                        margin: _getMargin(screenSize, isTablet, isDesktop),
                        padding: widget.padding ?? _getPadding(isTablet, isDesktop),
                        decoration: BoxDecoration(
                          color: widget.backgroundColor ?? AppColors.navbarBackground,
                          borderRadius: widget.borderRadius ?? _getBorderRadius(isTablet, isDesktop),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
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
          ),
        ),
      ),
    );
  }

  double _getMaxWidth(Size screenSize, bool isTablet, bool isDesktop) {
    if (isDesktop) {
      return screenSize.width * 0.4;
    } else if (isTablet) {
      return screenSize.width * 0.6;
    } else {
      return screenSize.width * 0.9;
    }
  }

  double _getMaxHeight(Size screenSize, bool isTablet, bool isDesktop) {
    if (isDesktop) {
      return screenSize.height * 0.8;
    } else if (isTablet) {
      return screenSize.height * 0.85;
    } else {
      return screenSize.height * 0.9;
    }
  }

  EdgeInsets _getMargin(Size screenSize, bool isTablet, bool isDesktop) {
    if (isDesktop) {
      return const EdgeInsets.all(40);
    } else if (isTablet) {
      return const EdgeInsets.all(30);
    } else {
      return const EdgeInsets.all(20);
    }
  }

  EdgeInsets _getPadding(bool isTablet, bool isDesktop) {
    if (isDesktop) {
      return const EdgeInsets.all(32);
    } else if (isTablet) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(20);
    }
  }

  BorderRadius _getBorderRadius(bool isTablet, bool isDesktop) {
    if (isDesktop) {
      return BorderRadius.circular(20);
    } else if (isTablet) {
      return BorderRadius.circular(16);
    } else {
      return BorderRadius.circular(12);
    }
  }
}

class MatchModal extends StatefulWidget {
  final String matchName;
  final String matchImageUrl;
  final VoidCallback? onStartChat;
  final VoidCallback? onKeepSwiping;
  final VoidCallback? onShare;

  const MatchModal({
    Key? key,
    required this.matchName,
    required this.matchImageUrl,
    this.onStartChat,
    this.onKeepSwiping,
    this.onShare,
  }) : super(key: key);

  @override
  State<MatchModal> createState() => _MatchModalState();
}

class _MatchModalState extends State<MatchModal>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _heartController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _controller.forward();
    _heartController.forward();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
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

    _heartAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveModal(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildMatchContent(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.favorite,
          color: AppColors.prideRed,
          size: 28,
        ),
        const SizedBox(width: 12),
        const Text(
          'It\'s a Match!',
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
            Navigator.of(context).pop();
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

  Widget _buildMatchContent() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.prideRed.withOpacity(0.1),
                    AppColors.pridePurple.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _heartController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _heartAnimation.value,
                        child: Icon(
                          Icons.favorite,
                          color: AppColors.prideRed,
                          size: 64,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You and ${widget.matchName} liked each other!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProfileImage(widget.matchImageUrl),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.favorite,
                        color: AppColors.prideRed,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      _buildUserProfileImage(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryLight,
          width: 3,
        ),
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.surfaceSecondary,
            child: Icon(
              Icons.person,
              color: AppColors.textSecondaryDark,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryLight,
          width: 3,
        ),
      ),
      child: ClipOval(
        child: Container(
          color: AppColors.surfaceSecondary,
          child: Icon(
            Icons.person,
            color: AppColors.textSecondaryDark,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedbackService.success();
              Navigator.of(context).pop();
              widget.onStartChat?.call();
            },
            icon: const Icon(Icons.chat),
            label: const Text('Start Chatting'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedbackService.selection();
                  Navigator.of(context).pop();
                  widget.onKeepSwiping?.call();
                },
                icon: const Icon(Icons.swipe),
                label: const Text('Keep Swiping'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.borderDefault),
                  foregroundColor: AppColors.textPrimaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedbackService.selection();
                  Navigator.of(context).pop();
                  widget.onShare?.call();
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.borderDefault),
                  foregroundColor: AppColors.textPrimaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ModalUtils {
  static Future<T?> showResponsiveModal<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableBackdrop = true,
    Color? backgroundColor,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    double? maxWidth,
    double? maxHeight,
    Alignment alignment = Alignment.center,
    Duration animationDuration = const Duration(milliseconds: 300),
    Curve animationCurve = Curves.easeInOut,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => ResponsiveModal(
        isDismissible: isDismissible,
        enableBackdrop: enableBackdrop,
        backgroundColor: backgroundColor,
        padding: padding,
        borderRadius: borderRadius,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        alignment: alignment,
        animationDuration: animationDuration,
        animationCurve: animationCurve,
        child: child,
      ),
    );
  }

  static Future<void> showMatchModal({
    required BuildContext context,
    required String matchName,
    required String matchImageUrl,
    VoidCallback? onStartChat,
    VoidCallback? onKeepSwiping,
    VoidCallback? onShare,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => MatchModal(
        matchName: matchName,
        matchImageUrl: matchImageUrl,
        onStartChat: onStartChat,
        onKeepSwiping: onKeepSwiping,
        onShare: onShare,
      ),
    );
  }

  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? AppColors.navbarBackground,
      constraints: height != null ? BoxConstraints(maxHeight: height) : null,
      shape: borderRadius != null 
          ? RoundedRectangleBorder(borderRadius: borderRadius)
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
      builder: (context) => child,
    );
  }
}
