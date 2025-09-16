import 'package:flutter/material.dart';
import '../../services/animation_service.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final AnimationType animationType;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AnimatedButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.style,
    this.animationDuration,
    this.animationCurve,
    this.animationType = AnimationType.scale,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 150),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve ?? Curves.easeInOut,
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
      onTapDown: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = true);
          _controller.forward();
        }
      },
      onTapUp: (_) {
        if (_isPressed) {
          setState(() => _isPressed = false);
          _controller.reverse();
          widget.onPressed?.call();
        }
      },
      onTapCancel: () {
        if (_isPressed) {
          setState(() => _isPressed = false);
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          Widget button = Container(
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: widget.style?.backgroundColor?.resolve({}) ?? AppColors.primary,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            ),
            child: widget.child,
          );

          switch (widget.animationType) {
            case AnimationType.scale:
              return Transform.scale(
                scale: _animation.value,
                child: button,
              );
            case AnimationType.fade:
              return Opacity(
                opacity: _animation.value,
                child: button,
              );
            case AnimationType.bounce:
              return Transform.translate(
                offset: Offset(0, (1 - _animation.value) * 5),
                child: button,
              );
            case AnimationType.rotate:
              return Transform.rotate(
                angle: (1 - _animation.value) * 0.1,
                child: button,
              );
          }
        },
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final double? elevation;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final AnimationType animationType;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
    this.animationDuration,
    this.animationCurve,
    this.animationType = AnimationType.scale,
  }) : super(key: key);

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve ?? Curves.easeInOut,
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
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _controller.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _controller.reverse();
        },
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            Widget card = Container(
              margin: widget.margin,
              padding: widget.padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? AppColors.navbarBackground,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                boxShadow: widget.elevation != null
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: widget.elevation!,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: widget.child,
            );

            switch (widget.animationType) {
              case AnimationType.scale:
                return Transform.scale(
                  scale: _animation.value,
                  child: card,
                );
              case AnimationType.fade:
                return Opacity(
                  opacity: 0.8 + (_animation.value - 1.0) * 0.2,
                  child: card,
                );
              case AnimationType.bounce:
                return Transform.translate(
                  offset: Offset(0, (1 - _animation.value) * 5),
                  child: card,
                );
              case AnimationType.rotate:
                return Transform.rotate(
                  angle: (_animation.value - 1.0) * 0.05,
                  child: card,
                );
            }
          },
        ),
      ),
    );
  }
}

class AnimatedIcon extends StatefulWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final AnimationType animationType;
  final VoidCallback? onTap;

  const AnimatedIcon(
    this.icon, {
    Key? key,
    this.size,
    this.color,
    this.animationDuration,
    this.animationCurve,
    this.animationType = AnimationType.scale,
    this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<AnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 150),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve ?? Curves.easeInOut,
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
      onTapDown: (_) {
        if (widget.onTap != null) {
          setState(() => _isPressed = true);
          _controller.forward();
        }
      },
      onTapUp: (_) {
        if (_isPressed) {
          setState(() => _isPressed = false);
          _controller.reverse();
          widget.onTap?.call();
        }
      },
      onTapCancel: () {
        if (_isPressed) {
          setState(() => _isPressed = false);
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          Widget icon = Icon(
            widget.icon,
            size: widget.size,
            color: widget.color,
          );

          switch (widget.animationType) {
            case AnimationType.scale:
              return Transform.scale(
                scale: _animation.value,
                child: icon,
              );
            case AnimationType.fade:
              return Opacity(
                opacity: _animation.value,
                child: icon,
              );
            case AnimationType.bounce:
              return Transform.translate(
                offset: Offset(0, (1 - _animation.value) * 5),
                child: icon,
              );
            case AnimationType.rotate:
              return Transform.rotate(
                angle: (1 - _animation.value) * 0.2,
                child: icon,
              );
          }
        },
      ),
    );
  }
}

class AnimatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final AnimationType animationType;
  final bool animateOnMount;

  const AnimatedText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.animationDuration,
    this.animationCurve,
    this.animationType = AnimationType.fade,
    this.animateOnMount = true,
  }) : super(key: key);

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve ?? Curves.easeInOut,
    ));

    if (widget.animateOnMount) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.reset();
      _controller.forward();
    }
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
        Widget text = Text(
          widget.text,
          style: widget.style,
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
        );

        switch (widget.animationType) {
          case AnimationType.scale:
            return Transform.scale(
              scale: _animation.value,
              child: text,
            );
          case AnimationType.fade:
            return Opacity(
              opacity: _animation.value,
              child: text,
            );
          case AnimationType.bounce:
            return Transform.translate(
              offset: Offset(0, (1 - _animation.value) * 20),
              child: text,
            );
          case AnimationType.rotate:
            return Transform.rotate(
              angle: (1 - _animation.value) * 0.1,
              child: text,
            );
        }
      },
    );
  }
}

class AnimatedContainer extends StatefulWidget {
  final Widget? child;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final AnimationType animationType;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  const AnimatedContainer({
    Key? key,
    this.child,
    this.animationDuration,
    this.animationCurve,
    this.animationType = AnimationType.fade,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.width,
    this.height,
    this.alignment,
  }) : super(key: key);

  @override
  State<AnimatedContainer> createState() => _AnimatedContainerState();
}

class _AnimatedContainerState extends State<AnimatedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve ?? Curves.easeInOut,
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
        Widget container = Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          padding: widget.padding,
          alignment: widget.alignment,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius,
          ),
          child: widget.child,
        );

        switch (widget.animationType) {
          case AnimationType.scale:
            return Transform.scale(
              scale: _animation.value,
              child: container,
            );
          case AnimationType.fade:
            return Opacity(
              opacity: _animation.value,
              child: container,
            );
          case AnimationType.bounce:
            return Transform.translate(
              offset: Offset(0, (1 - _animation.value) * 20),
              child: container,
            );
          case AnimationType.rotate:
            return Transform.rotate(
              angle: (1 - _animation.value) * 0.1,
              child: container,
            );
        }
      },
    );
  }
}

class AnimatedListTile extends StatefulWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final AnimationType animationType;

  const AnimatedListTile({
    Key? key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
    this.animationDuration,
    this.animationCurve,
    this.animationType = AnimationType.slide,
  }) : super(key: key);

  @override
  State<AnimatedListTile> createState() => _AnimatedListTileState();
}

class _AnimatedListTileState extends State<AnimatedListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve ?? Curves.easeInOut,
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
        Widget listTile = ListTile(
          leading: widget.leading,
          title: widget.title,
          subtitle: widget.subtitle,
          trailing: widget.trailing,
          onTap: widget.onTap,
          contentPadding: widget.contentPadding,
        );

        switch (widget.animationType) {
          case AnimationType.scale:
            return Transform.scale(
              scale: _animation.value.dx,
              child: listTile,
            );
          case AnimationType.fade:
            return Opacity(
              opacity: _animation.value.dx,
              child: listTile,
            );
          case AnimationType.bounce:
            return Transform.translate(
              offset: Offset(0, (1 - _animation.value.dx) * 20),
              child: listTile,
            );
          case AnimationType.rotate:
            return Transform.rotate(
              angle: (1 - _animation.value.dx) * 0.1,
              child: listTile,
            );
          case AnimationType.slide:
            return SlideTransition(
              position: _animation,
              child: listTile,
            );
        }
      },
    );
  }
}

class AnimatedFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final AnimationType animationType;

  const AnimatedFloatingActionButton({
    Key? key,
    this.onPressed,
    required this.child,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.animationDuration,
    this.animationCurve,
    this.animationType = AnimationType.scale,
  }) : super(key: key);

  @override
  State<AnimatedFloatingActionButton> createState() => _AnimatedFloatingActionButtonState();
}

class _AnimatedFloatingActionButtonState extends State<AnimatedFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 150),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve ?? Curves.easeInOut,
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
      onTapDown: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = true);
          _controller.forward();
        }
      },
      onTapUp: (_) {
        if (_isPressed) {
          setState(() => _isPressed = false);
          _controller.reverse();
          widget.onPressed?.call();
        }
      },
      onTapCancel: () {
        if (_isPressed) {
          setState(() => _isPressed = false);
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          Widget fab = FloatingActionButton(
            onPressed: null, // Handled by GestureDetector
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            tooltip: widget.tooltip,
            child: widget.child,
          );

          switch (widget.animationType) {
            case AnimationType.scale:
              return Transform.scale(
                scale: _animation.value,
                child: fab,
              );
            case AnimationType.fade:
              return Opacity(
                opacity: _animation.value,
                child: fab,
              );
            case AnimationType.bounce:
              return Transform.translate(
                offset: Offset(0, (1 - _animation.value) * 5),
                child: fab,
              );
            case AnimationType.rotate:
              return Transform.rotate(
                angle: (1 - _animation.value) * 0.1,
                child: fab,
              );
            case AnimationType.slide:
              return fab;
          }
        },
      ),
    );
  }
}

enum AnimationType {
  scale,
  fade,
  bounce,
  rotate,
  slide,
}
