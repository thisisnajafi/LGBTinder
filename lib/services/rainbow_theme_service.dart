import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/colors.dart';

class RainbowThemeService {
  static final RainbowThemeService _instance = RainbowThemeService._internal();
  factory RainbowThemeService() => _instance;
  RainbowThemeService._internal();

  // Theme state
  bool _isRainbowEnabled = false;
  bool _isAnimated = true;
  double _animationSpeed = 1.0;
  RainbowStyle _currentStyle = RainbowStyle.fullRainbow;
  
  // Animation controller
  AnimationController? _animationController;
  Animation<double>? _animation;
  
  // Getters
  bool get isRainbowEnabled => _isRainbowEnabled;
  bool get isAnimated => _isAnimated;
  double get animationSpeed => _animationSpeed;
  RainbowStyle get currentStyle => _currentStyle;

  /// Initialize the rainbow theme service
  void initialize(TickerProvider vsync) {
    _animationController = AnimationController(
      duration: Duration(milliseconds: (3000 / _animationSpeed).round()),
      vsync: vsync,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.linear,
    ));
    
    if (_isRainbowEnabled && _isAnimated) {
      _animationController!.repeat();
    }
  }

  /// Enable rainbow theme
  void enableRainbow({RainbowStyle style = RainbowStyle.fullRainbow}) {
    _isRainbowEnabled = true;
    _currentStyle = style;
    
    if (_isAnimated && _animationController != null) {
      _animationController!.repeat();
    }
  }

  /// Disable rainbow theme
  void disableRainbow() {
    _isRainbowEnabled = false;
    _animationController?.stop();
  }

  /// Set rainbow style
  void setRainbowStyle(RainbowStyle style) {
    _currentStyle = style;
  }

  /// Set animation speed
  void setAnimationSpeed(double speed) {
    _animationSpeed = speed.clamp(0.1, 3.0);
    
    if (_animationController != null) {
      _animationController!.duration = Duration(
        milliseconds: (3000 / _animationSpeed).round(),
      );
    }
  }

  /// Toggle animation
  void toggleAnimation() {
    _isAnimated = !_isAnimated;
    
    if (_isRainbowEnabled) {
      if (_isAnimated) {
        _animationController?.repeat();
      } else {
        _animationController?.stop();
      }
    }
  }

  /// Get rainbow gradient based on current style and animation
  LinearGradient getRainbowGradient({
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
    List<double>? stops,
  }) {
    if (!_isRainbowEnabled) {
      return LinearGradient(
        colors: [AppColors.primary, AppColors.secondaryLight],
        begin: begin,
        end: end,
        stops: stops,
      );
    }

    List<Color> colors;
    List<double> gradientStops;

    switch (_currentStyle) {
      case RainbowStyle.fullRainbow:
        colors = AppColors.lgbtGradient;
        gradientStops = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];
        break;
      case RainbowStyle.pastelRainbow:
        colors = _getPastelRainbowColors();
        gradientStops = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];
        break;
      case RainbowStyle.vibrantRainbow:
        colors = _getVibrantRainbowColors();
        gradientStops = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];
        break;
      case RainbowStyle.subtleRainbow:
        colors = _getSubtleRainbowColors();
        gradientStops = [0.0, 0.25, 0.5, 0.75, 1.0];
        break;
      case RainbowStyle.transPride:
        colors = _getTransPrideColors();
        gradientStops = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];
        break;
      case RainbowStyle.biPride:
        colors = _getBiPrideColors();
        gradientStops = [0.0, 0.33, 0.66, 1.0];
        break;
      case RainbowStyle.panPride:
        colors = _getPanPrideColors();
        gradientStops = [0.0, 0.33, 0.66, 1.0];
        break;
      case RainbowStyle.acePride:
        colors = _getAcePrideColors();
        gradientStops = [0.0, 0.25, 0.5, 0.75, 1.0];
        break;
    }

    // Apply animation if enabled
    if (_isAnimated && _animation != null) {
      colors = _applyAnimationToColors(colors);
    }

    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
      stops: stops ?? gradientStops,
    );
  }

  /// Get radial rainbow gradient
  RadialGradient getRadialRainbowGradient({
    AlignmentGeometry center = Alignment.center,
    double radius = 0.8,
    List<double>? stops,
  }) {
    if (!_isRainbowEnabled) {
      return RadialGradient(
        colors: [AppColors.primary, AppColors.secondaryLight],
        center: center,
        radius: radius,
        stops: stops,
      );
    }

    List<Color> colors;
    List<double> gradientStops;

    switch (_currentStyle) {
      case RainbowStyle.fullRainbow:
        colors = AppColors.lgbtGradient;
        gradientStops = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];
        break;
      case RainbowStyle.pastelRainbow:
        colors = _getPastelRainbowColors();
        gradientStops = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];
        break;
      case RainbowStyle.vibrantRainbow:
        colors = _getVibrantRainbowColors();
        gradientStops = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];
        break;
      case RainbowStyle.subtleRainbow:
        colors = _getSubtleRainbowColors();
        gradientStops = [0.0, 0.25, 0.5, 0.75, 1.0];
        break;
      case RainbowStyle.transPride:
        colors = _getTransPrideColors();
        gradientStops = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];
        break;
      case RainbowStyle.biPride:
        colors = _getBiPrideColors();
        gradientStops = [0.0, 0.33, 0.66, 1.0];
        break;
      case RainbowStyle.panPride:
        colors = _getPanPrideColors();
        gradientStops = [0.0, 0.33, 0.66, 1.0];
        break;
      case RainbowStyle.acePride:
        colors = _getAcePrideColors();
        gradientStops = [0.0, 0.25, 0.5, 0.75, 1.0];
        break;
    }

    // Apply animation if enabled
    if (_isAnimated && _animation != null) {
      colors = _applyAnimationToColors(colors);
    }

    return RadialGradient(
      colors: colors,
      center: center,
      radius: radius,
      stops: stops ?? gradientStops,
    );
  }

  /// Get rainbow color for specific index
  Color getRainbowColor(int index) {
    if (!_isRainbowEnabled) {
      return AppColors.primary;
    }

    List<Color> colors;
    switch (_currentStyle) {
      case RainbowStyle.fullRainbow:
        colors = AppColors.lgbtGradient;
        break;
      case RainbowStyle.pastelRainbow:
        colors = _getPastelRainbowColors();
        break;
      case RainbowStyle.vibrantRainbow:
        colors = _getVibrantRainbowColors();
        break;
      case RainbowStyle.subtleRainbow:
        colors = _getSubtleRainbowColors();
        break;
      case RainbowStyle.transPride:
        colors = _getTransPrideColors();
        break;
      case RainbowStyle.biPride:
        colors = _getBiPrideColors();
        break;
      case RainbowStyle.panPride:
        colors = _getPanPrideColors();
        break;
      case RainbowStyle.acePride:
        colors = _getAcePrideColors();
        break;
    }

    return colors[index % colors.length];
  }

  /// Get rainbow shimmer effect
  LinearGradient getRainbowShimmer() {
    if (!_isRainbowEnabled) {
      return LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.3),
          AppColors.primary.withOpacity(0.7),
          AppColors.primary.withOpacity(0.3),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
    }

    final colors = _getCurrentRainbowColors();
    return LinearGradient(
      colors: [
        colors[0].withOpacity(0.3),
        colors[2].withOpacity(0.7),
        colors[4].withOpacity(0.3),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  /// Apply animation to colors
  List<Color> _applyAnimationToColors(List<Color> colors) {
    if (_animation == null) return colors;

    final animatedColors = <Color>[];
    final progress = _animation!.value;
    
    for (int i = 0; i < colors.length; i++) {
      final nextIndex = (i + 1) % colors.length;
      final currentColor = colors[i];
      final nextColor = colors[nextIndex];
      
      animatedColors.add(Color.lerp(currentColor, nextColor, progress)!);
    }
    
    return animatedColors;
  }

  /// Get current rainbow colors based on style
  List<Color> _getCurrentRainbowColors() {
    switch (_currentStyle) {
      case RainbowStyle.fullRainbow:
        return AppColors.lgbtGradient;
      case RainbowStyle.pastelRainbow:
        return _getPastelRainbowColors();
      case RainbowStyle.vibrantRainbow:
        return _getVibrantRainbowColors();
      case RainbowStyle.subtleRainbow:
        return _getSubtleRainbowColors();
      case RainbowStyle.transPride:
        return _getTransPrideColors();
      case RainbowStyle.biPride:
        return _getBiPrideColors();
      case RainbowStyle.panPride:
        return _getPanPrideColors();
      case RainbowStyle.acePride:
        return _getAcePrideColors();
    }
  }

  /// Get pastel rainbow colors
  List<Color> _getPastelRainbowColors() {
    return [
      const Color(0xFFFFB3BA), // Pastel Red
      const Color(0xFFFFDFBA), // Pastel Orange
      const Color(0xFFFFFFBA), // Pastel Yellow
      const Color(0xFFBAFFC9), // Pastel Green
      const Color(0xFFBAE1FF), // Pastel Blue
      const Color(0xFFE1BAFF), // Pastel Purple
    ];
  }

  /// Get vibrant rainbow colors
  List<Color> _getVibrantRainbowColors() {
    return [
      const Color(0xFFFF0000), // Vibrant Red
      const Color(0xFFFF8000), // Vibrant Orange
      const Color(0xFFFFFF00), // Vibrant Yellow
      const Color(0xFF00FF00), // Vibrant Green
      const Color(0xFF0080FF), // Vibrant Blue
      const Color(0xFF8000FF), // Vibrant Purple
    ];
  }

  /// Get subtle rainbow colors
  List<Color> _getSubtleRainbowColors() {
    return [
      const Color(0xFFE57373), // Subtle Red
      const Color(0xFFFFB74D), // Subtle Orange
      const Color(0xFFFFF176), // Subtle Yellow
      const Color(0xFF81C784), // Subtle Green
      const Color(0xFF64B5F6), // Subtle Blue
      const Color(0xFFBA68C8), // Subtle Purple
    ];
  }

  /// Get transgender pride colors
  List<Color> _getTransPrideColors() {
    return [
      const Color(0xFF5BCEFA), // Trans Blue
      const Color(0xFFF5A9B8), // Trans Pink
      const Color(0xFFFFFFFF), // White
      const Color(0xFFF5A9B8), // Trans Pink
      const Color(0xFF5BCEFA), // Trans Blue
    ];
  }

  /// Get bisexual pride colors
  List<Color> _getBiPrideColors() {
    return [
      const Color(0xFFD70071), // Bi Pink
      const Color(0xFF9C4F96), // Bi Purple
      const Color(0xFF0035AA), // Bi Blue
    ];
  }

  /// Get pansexual pride colors
  List<Color> _getPanPrideColors() {
    return [
      const Color(0xFFFF1B8D), // Pan Pink
      const Color(0xFFFFD700), // Pan Yellow
      const Color(0xFF1BB3FF), // Pan Blue
    ];
  }

  /// Get asexual pride colors
  List<Color> _getAcePrideColors() {
    return [
      const Color(0xFF000000), // Black
      const Color(0xFFA3A3A3), // Gray
      const Color(0xFFFFFFFF), // White
      const Color(0xFF800080), // Purple
    ];
  }

  /// Dispose service
  void dispose() {
    _animationController?.dispose();
    _animationController = null;
    _animation = null;
  }
}

enum RainbowStyle {
  fullRainbow,
  pastelRainbow,
  vibrantRainbow,
  subtleRainbow,
  transPride,
  biPride,
  panPride,
  acePride,
}

class RainbowThemeWidget extends StatefulWidget {
  final Widget child;
  final RainbowStyle? style;
  final bool enableAnimation;
  final double animationSpeed;

  const RainbowThemeWidget({
    Key? key,
    required this.child,
    this.style,
    this.enableAnimation = true,
    this.animationSpeed = 1.0,
  }) : super(key: key);

  @override
  State<RainbowThemeWidget> createState() => _RainbowThemeWidgetState();
}

class _RainbowThemeWidgetState extends State<RainbowThemeWidget>
    with TickerProviderStateMixin {
  late RainbowThemeService _rainbowService;

  @override
  void initState() {
    super.initState();
    _rainbowService = RainbowThemeService();
    _rainbowService.initialize(this);
    
    if (widget.style != null) {
      _rainbowService.setRainbowStyle(widget.style!);
    }
    
    _rainbowService.setAnimationSpeed(widget.animationSpeed);
    
    if (widget.enableAnimation) {
      _rainbowService.enableRainbow();
    }
  }

  @override
  void dispose() {
    _rainbowService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rainbowService._animation ?? const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        return widget.child;
      },
    );
  }
}

class RainbowButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final RainbowStyle? style;
  final bool enableAnimation;
  final double animationSpeed;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const RainbowButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.style,
    this.enableAnimation = true,
    this.animationSpeed = 1.0,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RainbowThemeWidget(
      style: style,
      enableAnimation: enableAnimation,
      animationSpeed: animationSpeed,
      child: Container(
        decoration: BoxDecoration(
          gradient: RainbowThemeService().getRainbowGradient(),
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class RainbowCard extends StatelessWidget {
  final Widget child;
  final RainbowStyle? style;
  final bool enableAnimation;
  final double animationSpeed;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double? elevation;

  const RainbowCard({
    Key? key,
    required this.child,
    this.style,
    this.enableAnimation = true,
    this.animationSpeed = 1.0,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RainbowThemeWidget(
      style: style,
      enableAnimation: enableAnimation,
      animationSpeed: animationSpeed,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          gradient: RainbowThemeService().getRainbowGradient(),
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          boxShadow: elevation != null
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: elevation!,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
