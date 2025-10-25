import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class LGBTGradientSystem {
  // Private constructor to prevent instantiation
  LGBTGradientSystem._();

  // Rainbow Pride Gradient
  static const LinearGradient rainbowPride = LinearGradient(
    colors: [
      AppColors.prideRed,
      AppColors.prideOrange,
      AppColors.prideYellow,
      AppColors.prideGreen,
      AppColors.prideBlue,
      AppColors.pridePurple,
    ],
    stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Alias for backward compatibility
  static const LinearGradient rainbowGradient = rainbowPride;

  // Trans Pride Gradient
  static const LinearGradient transPride = LinearGradient(
    colors: [
      AppColors.transBlue,
      AppColors.transPink,
      AppColors.transWhite,
      AppColors.transPink,
      AppColors.transBlue,
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Non-binary Pride Gradient
  static const LinearGradient nonBinaryPride = LinearGradient(
    colors: [
      AppColors.nonBinaryYellow,
      AppColors.nonBinaryWhite,
      AppColors.nonBinaryPurple,
      AppColors.nonBinaryBlack,
    ],
    stops: [0.0, 0.33, 0.66, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Lesbian Pride Gradient
  static const LinearGradient lesbianPride = LinearGradient(
    colors: [
      AppColors.lesbianDarkOrange,
      AppColors.lesbianLightOrange,
      AppColors.lesbianWhite,
      AppColors.lesbianPink,
      AppColors.lesbianDarkPink,
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Gay Pride Gradient (Blue tones)
  static const LinearGradient gayPride = LinearGradient(
    colors: [
      AppColors.gayDarkBlue,
      AppColors.gayBlue,
      AppColors.gayLightBlue,
      AppColors.gayLightBlue,
      AppColors.gayBlue,
      AppColors.gayDarkBlue,
    ],
    stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Bisexual Pride Gradient
  static const LinearGradient bisexualPride = LinearGradient(
    colors: [
      AppColors.biPink,
      AppColors.biPurple,
      AppColors.biBlue,
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Pansexual Pride Gradient
  static const LinearGradient pansexualPride = LinearGradient(
    colors: [
      AppColors.panPink,
      AppColors.lgbtYellow,
      AppColors.panBlue,
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Asexual Pride Gradient
  static const LinearGradient asexualPride = LinearGradient(
    colors: [
      AppColors.aceBlack,
      AppColors.aceGray,
      AppColors.aceWhite,
      AppColors.lgbtPurple,
    ],
    stops: [0.0, 0.33, 0.66, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Get gradient by identity type
  static LinearGradient getGradient(LGBTIdentity identity) {
    switch (identity) {
      case LGBTIdentity.rainbow:
        return rainbowPride;
      case LGBTIdentity.trans:
        return transPride;
      case LGBTIdentity.nonBinary:
        return nonBinaryPride;
      case LGBTIdentity.lesbian:
        return lesbianPride;
      case LGBTIdentity.gay:
        return gayPride;
      case LGBTIdentity.bisexual:
        return bisexualPride;
      case LGBTIdentity.pansexual:
        return pansexualPride;
      case LGBTIdentity.asexual:
        return asexualPride;
    }
  }

  // Get gradient by name
  static LinearGradient getGradientByName(String name) {
    switch (name.toLowerCase()) {
      case 'rainbow':
        return rainbowPride;
      case 'trans':
      case 'transgender':
        return transPride;
      case 'nonbinary':
      case 'non-binary':
        return nonBinaryPride;
      case 'lesbian':
        return lesbianPride;
      case 'gay':
        return gayPride;
      case 'bisexual':
        return bisexualPride;
      case 'pansexual':
        return pansexualPride;
      case 'asexual':
        return asexualPride;
      default:
        return rainbowPride;
    }
  }

  // Create custom gradient with specific colors
  static LinearGradient createCustomGradient(List<Color> colors, {
    List<double>? stops,
    Alignment begin = Alignment.centerLeft,
    Alignment end = Alignment.centerRight,
  }) {
    return LinearGradient(
      colors: colors,
      stops: stops,
      begin: begin,
      end: end,
    );
  }

  // Create radial gradient
  static RadialGradient createRadialGradient(List<Color> colors, {
    List<double>? stops,
    Alignment center = Alignment.center,
    double radius = 1.0,
  }) {
    return RadialGradient(
      colors: colors,
      stops: stops,
      center: center,
      radius: radius,
    );
  }

  // Create sweep gradient
  static SweepGradient createSweepGradient(List<Color> colors, {
    List<double>? stops,
    double startAngle = 0.0,
    double endAngle = 6.28,
  }) {
    return SweepGradient(
      colors: colors,
      stops: stops,
      startAngle: startAngle,
      endAngle: endAngle,
    );
  }
}

enum LGBTIdentity {
  rainbow,
  trans,
  nonBinary,
  lesbian,
  gay,
  bisexual,
  pansexual,
  asexual,
}

class GradientWidget extends StatelessWidget {
  final LinearGradient gradient;
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  const GradientWidget({
    Key? key,
    required this.gradient,
    required this.child,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

class PrideFlagWidget extends StatelessWidget {
  final LGBTIdentity identity;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? child;

  const PrideFlagWidget({
    Key? key,
    required this.identity,
    this.width,
    this.height,
    this.borderRadius,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientWidget(
      gradient: LGBTGradientSystem.getGradient(identity),
      width: width,
      height: height,
      borderRadius: borderRadius,
      child: child ?? const SizedBox.shrink(),
    );
  }
}

class AnimatedPrideFlag extends StatefulWidget {
  final LGBTIdentity identity;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? child;
  final Duration animationDuration;

  const AnimatedPrideFlag({
    Key? key,
    required this.identity,
    this.width,
    this.height,
    this.borderRadius,
    this.child,
    this.animationDuration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  State<AnimatedPrideFlag> createState() => _AnimatedPrideFlagState();
}

class _AnimatedPrideFlagState extends State<AnimatedPrideFlag>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: PrideFlagWidget(
            identity: widget.identity,
            width: widget.width,
            height: widget.height,
            borderRadius: widget.borderRadius,
            child: widget.child,
          ),
        );
      },
    );
  }
}
