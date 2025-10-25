import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Pre-configured Lottie animations for the app
class LottieAnimations {
  // ==================== LOADING ANIMATIONS ====================
  
  /// General loading spinner
  static Widget loading({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/loading.json',
      width: width ?? 100,
      height: height ?? 100,
      fit: fit,
      repeat: true,
    );
  }

  /// Loading with animated hearts
  static Widget loadingHearts({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/loading_hearts.json',
      width: width ?? 150,
      height: height ?? 150,
      fit: fit,
      repeat: true,
    );
  }

  /// Rainbow-themed loading animation
  static Widget loadingRainbow({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/loading_rainbow.json',
      width: width ?? 150,
      height: height ?? 150,
      fit: fit,
      repeat: true,
    );
  }

  // ==================== SUCCESS & CELEBRATION ====================
  
  /// Success checkmark animation
  static Widget success({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    VoidCallback? onComplete,
  }) {
    return _buildAnimation(
      'assets/lottie/success.json',
      width: width ?? 150,
      height: height ?? 150,
      fit: fit,
      repeat: false,
      onComplete: onComplete,
    );
  }

  /// Confetti celebration animation
  static Widget celebration({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    VoidCallback? onComplete,
  }) {
    return _buildAnimation(
      'assets/lottie/celebration.json',
      width: width ?? 300,
      height: height ?? 300,
      fit: fit,
      repeat: false,
      onComplete: onComplete,
    );
  }

  /// Match celebration animation
  static Widget matchCelebration({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    VoidCallback? onComplete,
  }) {
    return _buildAnimation(
      'assets/lottie/match_celebration.json',
      width: width ?? 250,
      height: height ?? 250,
      fit: fit,
      repeat: false,
      onComplete: onComplete,
    );
  }

  /// Hearts bursting animation
  static Widget heartBurst({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/heart_burst.json',
      width: width ?? 200,
      height: height ?? 200,
      fit: fit,
      repeat: false,
    );
  }

  // ==================== PROFILE & VERIFICATION ====================
  
  /// Profile completion celebration
  static Widget profileComplete({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/profile_complete.json',
      width: width ?? 200,
      height: height ?? 200,
      fit: fit,
      repeat: false,
    );
  }

  /// Verification approved animation
  static Widget verificationSuccess({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/verification_success.json',
      width: width ?? 180,
      height: height ?? 180,
      fit: fit,
      repeat: false,
    );
  }

  /// Photo upload progress animation
  static Widget photoUpload({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/photo_upload.json',
      width: width ?? 120,
      height: height ?? 120,
      fit: fit,
      repeat: true,
    );
  }

  // ==================== EMPTY STATES ====================
  
  /// No matches found
  static Widget emptyMatches({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/empty_matches.json',
      width: width ?? 250,
      height: height ?? 250,
      fit: fit,
      repeat: true,
    );
  }

  /// No messages yet
  static Widget emptyChat({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/empty_chat.json',
      width: width ?? 250,
      height: height ?? 250,
      fit: fit,
      repeat: true,
    );
  }

  /// No notifications
  static Widget emptyNotifications({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/empty_notifications.json',
      width: width ?? 250,
      height: height ?? 250,
      fit: fit,
      repeat: true,
    );
  }

  // ==================== ERROR STATES ====================
  
  /// General error animation
  static Widget error({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/error.json',
      width: width ?? 150,
      height: height ?? 150,
      fit: fit,
      repeat: false,
    );
  }

  /// Network connection error
  static Widget networkError({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/network_error.json',
      width: width ?? 200,
      height: height ?? 200,
      fit: fit,
      repeat: true,
    );
  }

  /// Something went wrong
  static Widget somethingWrong({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/something_wrong.json',
      width: width ?? 200,
      height: height ?? 200,
      fit: fit,
      repeat: false,
    );
  }

  // ==================== INTERACTIVE ELEMENTS ====================
  
  /// Swipe left hint animation
  static Widget swipeLeft({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/swipe_left.json',
      width: width ?? 80,
      height: height ?? 80,
      fit: fit,
      repeat: true,
    );
  }

  /// Swipe right hint animation
  static Widget swipeRight({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/swipe_right.json',
      width: width ?? 80,
      height: height ?? 80,
      fit: fit,
      repeat: true,
    );
  }

  /// Heart like animation
  static Widget likeAnimation({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/like_animation.json',
      width: width ?? 100,
      height: height ?? 100,
      fit: fit,
      repeat: false,
    );
  }

  /// Super like star animation
  static Widget superLikeAnimation({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/super_like_animation.json',
      width: width ?? 120,
      height: height ?? 120,
      fit: fit,
      repeat: false,
    );
  }

  // ==================== PREMIUM FEATURES ====================
  
  /// Premium membership badge
  static Widget premiumBadge({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/premium_badge.json',
      width: width ?? 100,
      height: height ?? 100,
      fit: fit,
      repeat: true,
    );
  }

  /// Feature unlock animation
  static Widget unlockFeature({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/unlock_feature.json',
      width: width ?? 180,
      height: height ?? 180,
      fit: fit,
      repeat: false,
    );
  }

  /// Profile boost animation
  static Widget boostProfile({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _buildAnimation(
      'assets/lottie/boost_profile.json',
      width: width ?? 150,
      height: height ?? 150,
      fit: fit,
      repeat: false,
    );
  }

  // ==================== HELPER METHOD ====================
  
  /// Build animation with fallback handling
  static Widget _buildAnimation(
    String assetPath, {
    required double width,
    required double height,
    required BoxFit fit,
    required bool repeat,
    VoidCallback? onComplete,
  }) {
    return Container(
      width: width,
      height: height,
      child: Lottie.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        repeat: repeat,
        onLoaded: (composition) {
          if (onComplete != null && !repeat) {
            // Call onComplete after animation duration
            Future.delayed(composition.duration, onComplete);
          }
        },
        // Fallback widget if animation fails to load
        errorBuilder: (context, error, stackTrace) {
          debugPrint('⚠️ Failed to load Lottie animation: $assetPath');
          debugPrint('Error: $error');
          return _buildFallback(width, height);
        },
      ),
    );
  }

  /// Fallback widget when animation fails to load
  static Widget _buildFallback(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: Icon(
          Icons.animation,
          size: width * 0.5,
          color: Colors.grey.withOpacity(0.5),
        ),
      ),
    );
  }
}

/// Custom Lottie animation controller widget for advanced use cases
class AnimatedLottie extends StatefulWidget {
  final String assetPath;
  final double width;
  final double height;
  final bool autoPlay;
  final bool repeat;
  final VoidCallback? onComplete;
  final BoxFit fit;

  const AnimatedLottie({
    Key? key,
    required this.assetPath,
    this.width = 200,
    this.height = 200,
    this.autoPlay = true,
    this.repeat = false,
    this.onComplete,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  State<AnimatedLottie> createState() => _AnimatedLottieState();
}

class _AnimatedLottieState extends State<AnimatedLottie>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    if (widget.autoPlay) {
      _controller.forward();
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.repeat) {
          _controller.repeat();
        } else {
          widget.onComplete?.call();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.assetPath,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      controller: _controller,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
        if (widget.autoPlay) {
          _controller.forward();
        }
      },
    );
  }

  /// Play the animation
  void play() => _controller.forward();

  /// Pause the animation
  void pause() => _controller.stop();

  /// Reset the animation
  void reset() => _controller.reset();

  /// Reverse the animation
  void reverse() => _controller.reverse();
}

