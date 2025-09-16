import 'package:flutter/material.dart';
import '../../services/rainbow_theme_service.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class RainbowAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final RainbowStyle? style;
  final bool enableAnimation;
  final double animationSpeed;

  const RainbowAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.style,
    this.enableAnimation = true,
    this.animationSpeed = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RainbowThemeWidget(
      style: style,
      enableAnimation: enableAnimation,
      animationSpeed: animationSpeed,
      child: Container(
        decoration: BoxDecoration(
          gradient: RainbowThemeService().getRainbowGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: AppBar(
          title: Text(
            title,
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: actions,
          leading: leading,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class RainbowButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final RainbowStyle? style;
  final bool enableAnimation;
  final double animationSpeed;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? elevation;

  const RainbowButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.style,
    this.enableAnimation = true,
    this.animationSpeed = 1.0,
    this.padding,
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
        decoration: BoxDecoration(
          gradient: RainbowThemeService().getRainbowGradient(),
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          boxShadow: elevation != null
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: elevation!,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            child: Padding(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
  final Color? backgroundColor;

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
    this.backgroundColor,
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
          gradient: RainbowThemeService().getRainbowGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.navbarBackground.withOpacity(0.9),
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
          child: child,
        ),
      ),
    );
  }
}

class RainbowFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final RainbowStyle? style;
  final bool enableAnimation;
  final double animationSpeed;

  const RainbowFloatingActionButton({
    Key? key,
    this.onPressed,
    required this.child,
    this.tooltip,
    this.style,
    this.enableAnimation = true,
    this.animationSpeed = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RainbowThemeWidget(
      style: style,
      enableAnimation: enableAnimation,
      animationSpeed: animationSpeed,
      child: Container(
        decoration: BoxDecoration(
          gradient: RainbowThemeService().getRadialRainbowGradient(),
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          tooltip: tooltip,
          child: child,
        ),
      ),
    );
  }
}

class RainbowChip extends StatelessWidget {
  final Widget label;
  final VoidCallback? onDeleted;
  final RainbowStyle? style;
  final bool enableAnimation;
  final double animationSpeed;
  final EdgeInsetsGeometry? padding;

  const RainbowChip({
    Key? key,
    required this.label,
    this.onDeleted,
    this.style,
    this.enableAnimation = true,
    this.animationSpeed = 1.0,
    this.padding,
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
          borderRadius: BorderRadius.circular(16),
        ),
        child: Chip(
          label: label,
          onDeleted: onDeleted,
          backgroundColor: Colors.transparent,
          labelStyle: AppTypography.body2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          deleteIconColor: Colors.white,
          padding: padding,
        ),
      ),
    );
  }
}

class RainbowDivider extends StatelessWidget {
  final double? height;
  final double? thickness;
  final RainbowStyle? style;
  final bool enableAnimation;
  final double animationSpeed;

  const RainbowDivider({
    Key? key,
    this.height,
    this.thickness,
    this.style,
    this.enableAnimation = true,
    this.animationSpeed = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RainbowThemeWidget(
      style: style,
      enableAnimation: enableAnimation,
      animationSpeed: animationSpeed,
      child: Container(
        height: height ?? thickness ?? 2,
        decoration: BoxDecoration(
          gradient: RainbowThemeService().getRainbowGradient(),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

class RainbowProgressIndicator extends StatelessWidget {
  final double? value;
  final RainbowStyle? style;
  final bool enableAnimation;
  final double animationSpeed;
  final double strokeWidth;

  const RainbowProgressIndicator({
    Key? key,
    this.value,
    this.style,
    this.enableAnimation = true,
    this.animationSpeed = 1.0,
    this.strokeWidth = 4.0,
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
          shape: BoxShape.circle,
        ),
        child: CircularProgressIndicator(
          value: value,
          strokeWidth: strokeWidth,
          backgroundColor: Colors.transparent,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}

class RainbowLinearProgressIndicator extends StatelessWidget {
  final double? value;
  final RainbowStyle? style;
  final bool enableAnimation;
  final double animationSpeed;
  final double minHeight;

  const RainbowLinearProgressIndicator({
    Key? key,
    this.value,
    this.style,
    this.enableAnimation = true,
    this.animationSpeed = 1.0,
    this.minHeight = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RainbowThemeWidget(
      style: style,
      enableAnimation: enableAnimation,
      animationSpeed: animationSpeed,
      child: Container(
        height: minHeight,
        decoration: BoxDecoration(
          gradient: RainbowThemeService().getRainbowGradient(),
          borderRadius: BorderRadius.circular(minHeight / 2),
        ),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.transparent,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}

class RainbowBadge extends StatelessWidget {
  final Widget child;
  final Widget? badge;
  final RainbowStyle? style;
  final bool enableAnimation;
  final double animationSpeed;
  final Alignment badgeAlignment;

  const RainbowBadge({
    Key? key,
    required this.child,
    this.badge,
    this.style,
    this.enableAnimation = true,
    this.animationSpeed = 1.0,
    this.badgeAlignment = Alignment.topRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RainbowThemeWidget(
      style: style,
      enableAnimation: enableAnimation,
      animationSpeed: animationSpeed,
      child: Stack(
        children: [
          child,
          if (badge != null)
            Positioned.fill(
              child: Align(
                alignment: badgeAlignment,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RainbowThemeService().getRainbowGradient(),
                    shape: BoxShape.circle,
                  ),
                  child: badge,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RainbowIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final RainbowStyle? style;
  final bool enableAnimation;
  final double animationSpeed;

  const RainbowIcon(
    this.icon, {
    Key? key,
    this.size,
    this.style,
    this.enableAnimation = true,
    this.animationSpeed = 1.0,
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
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: size,
          color: Colors.white,
        ),
      ),
    );
  }
}

class RainbowText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final RainbowStyle? rainbowStyle;
  final bool enableAnimation;
  final double animationSpeed;

  const RainbowText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.rainbowStyle,
    this.enableAnimation = true,
    this.animationSpeed = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RainbowThemeWidget(
      style: rainbowStyle,
      enableAnimation: enableAnimation,
      animationSpeed: animationSpeed,
      child: ShaderMask(
        shaderCallback: (bounds) {
          return RainbowThemeService().getRainbowGradient().createShader(bounds);
        },
        child: Text(
          text,
          style: style ?? AppTypography.body1.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        ),
      ),
    );
  }
}

class RainbowContainer extends StatelessWidget {
  final Widget? child;
  final RainbowStyle? style;
  final bool enableAnimation;
  final double animationSpeed;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  const RainbowContainer({
    Key? key,
    this.child,
    this.style,
    this.enableAnimation = true,
    this.animationSpeed = 1.0,
    this.padding,
    this.margin,
    this.borderRadius,
    this.width,
    this.height,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RainbowThemeWidget(
      style: style,
      enableAnimation: enableAnimation,
      animationSpeed: animationSpeed,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        alignment: alignment,
        decoration: BoxDecoration(
          gradient: RainbowThemeService().getRainbowGradient(),
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}
