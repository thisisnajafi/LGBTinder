import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/haptic_feedback_service.dart';
import '../../utils/color_state_manager.dart';

class AccessibleButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final String? semanticLabel;
  final String? semanticHint;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Duration animationDuration;
  final ButtonState state;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const AccessibleButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.semanticLabel,
    this.semanticHint,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 200),
    this.state = ButtonState.normal,
    this.errorMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  State<AccessibleButton> createState() => _AccessibleButtonState();
}

class _AccessibleButtonState extends State<AccessibleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  InteractiveState _currentState = InteractiveState.defaultState;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
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

  void _updateState(InteractiveState newState) {
    setState(() {
      _currentState = newState;
    });
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isDisabled || widget.isLoading) return;
    _updateState(InteractiveState.pressed);
    _controller.forward();
    HapticFeedbackService.light();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isDisabled || widget.isLoading) return;
    _updateState(InteractiveState.hover);
    _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.isDisabled || widget.isLoading) return;
    _updateState(InteractiveState.defaultState);
    _controller.reverse();
  }

  void _onTap() {
    if (widget.isDisabled || widget.isLoading) return;
    widget.onPressed?.call();
    HapticFeedbackService.selection();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final effectiveState = _getEffectiveState();
    
    final buttonColors = _getButtonColors(effectiveState, isDarkTheme);
    final buttonDimensions = _getButtonDimensions();
    final buttonTypography = _getButtonTypography();

    return Semantics(
      label: widget.semanticLabel ?? widget.text,
      hint: widget.semanticHint ?? _getDefaultHint(),
      button: true,
      enabled: effectiveState != InteractiveState.disabled,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTapDown: effectiveState != InteractiveState.disabled ? _onTapDown : null,
          onTapUp: effectiveState != InteractiveState.disabled ? _onTapUp : null,
          onTapCancel: effectiveState != InteractiveState.disabled ? _onTapCancel : null,
          onTap: effectiveState != InteractiveState.disabled ? _onTap : null,
          child: MouseRegion(
            onEnter: effectiveState != InteractiveState.disabled ? (_) => _updateState(InteractiveState.hover) : null,
            onExit: effectiveState != InteractiveState.disabled ? (_) => _updateState(InteractiveState.defaultState) : null,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      width: buttonDimensions.width,
                      height: buttonDimensions.height,
                      padding: widget.padding ?? buttonDimensions.padding,
                      decoration: BoxDecoration(
                        color: buttonColors.backgroundColor,
                        borderRadius: widget.borderRadius ?? buttonDimensions.borderRadius,
                        border: widget.type == ButtonType.outline 
                            ? Border.all(color: buttonColors.borderColor, width: 2)
                            : null,
                        boxShadow: widget.type == ButtonType.elevated
                            ? [
                                BoxShadow(
                                  color: buttonColors.shadowColor,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: _buildButtonContent(buttonColors, buttonTypography),
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

  InteractiveState _getEffectiveState() {
    if (widget.state == ButtonState.disabled || widget.isDisabled) {
      return InteractiveState.disabled;
    }
    if (widget.state == ButtonState.loading || widget.isLoading) {
      return InteractiveState.disabled;
    }
    return _currentState;
  }

  Widget _buildButtonContent(ButtonColors buttonColors, TextStyle buttonTypography) {
    switch (widget.state) {
      case ButtonState.loading:
        return _buildLoadingContent(buttonColors, buttonTypography);
      case ButtonState.error:
        return _buildErrorContent(buttonColors, buttonTypography);
      case ButtonState.success:
        return _buildSuccessContent(buttonColors, buttonTypography);
      default:
        return _buildNormalContent(buttonColors, buttonTypography);
    }
  }

  Widget _buildLoadingContent(ButtonColors buttonColors, TextStyle buttonTypography) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: buttonTypography.fontSize,
          height: buttonTypography.fontSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(buttonColors.textColor),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Loading...',
          style: buttonTypography.copyWith(color: buttonColors.textColor),
        ),
      ],
    );
  }

  Widget _buildErrorContent(ButtonColors buttonColors, TextStyle buttonTypography) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: buttonColors.textColor,
              size: buttonTypography.fontSize,
            ),
            const SizedBox(width: 8),
            Text(
              widget.text,
              style: buttonTypography.copyWith(color: buttonColors.textColor),
            ),
          ],
        ),
        if (widget.errorMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorMessage!,
            style: buttonTypography.copyWith(
              color: buttonColors.textColor.withOpacity(0.8),
              fontSize: buttonTypography.fontSize! * 0.8,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (widget.onRetry != null) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: widget.onRetry,
            child: Text(
              'Tap to retry',
              style: buttonTypography.copyWith(
                color: buttonColors.textColor,
                fontSize: buttonTypography.fontSize! * 0.8,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuccessContent(ButtonColors buttonColors, TextStyle buttonTypography) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline,
          color: buttonColors.textColor,
          size: buttonTypography.fontSize,
        ),
        const SizedBox(width: 8),
        Text(
          'Success!',
          style: buttonTypography.copyWith(color: buttonColors.textColor),
        ),
      ],
    );
  }

  Widget _buildNormalContent(ButtonColors buttonColors, TextStyle buttonTypography) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: buttonColors.textColor,
            size: buttonTypography.fontSize,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: buttonTypography.copyWith(color: buttonColors.textColor),
        ),
      ],
    );
  }

  ButtonColors _getButtonColors(InteractiveState state, bool isDarkTheme) {
    switch (widget.type) {
      case ButtonType.primary:
        return _getPrimaryButtonColors(state, isDarkTheme);
      case ButtonType.secondary:
        return _getSecondaryButtonColors(state, isDarkTheme);
      case ButtonType.outline:
        return _getOutlineButtonColors(state, isDarkTheme);
      case ButtonType.text:
        return _getTextButtonColors(state, isDarkTheme);
      case ButtonType.elevated:
        return _getElevatedButtonColors(state, isDarkTheme);
    }
  }

  ButtonColors _getPrimaryButtonColors(InteractiveState state, bool isDarkTheme) {
    final baseColor = widget.backgroundColor ?? AppColors.primaryLight;
    final backgroundColor = ColorStateManager.getInteractiveColor(state, isDarkTheme: isDarkTheme);
    final textColor = Colors.white;
    
    return ButtonColors(
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: backgroundColor,
      shadowColor: backgroundColor.withOpacity(0.3),
    );
  }

  ButtonColors _getSecondaryButtonColors(InteractiveState state, bool isDarkTheme) {
    final backgroundColor = isDarkTheme 
        ? AppColors.navbarBackground 
        : AppColors.surfaceSecondary;
    final textColor = ColorStateManager.getTextColor(
      state == InteractiveState.disabled ? TextState.disabled : TextState.primary,
      isDarkTheme: isDarkTheme,
    );
    
    return ButtonColors(
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: backgroundColor,
      shadowColor: Colors.black.withOpacity(0.1),
    );
  }

  ButtonColors _getOutlineButtonColors(InteractiveState state, bool isDarkTheme) {
    final borderColor = ColorStateManager.getInteractiveColor(state, isDarkTheme: isDarkTheme);
    final textColor = borderColor;
    final backgroundColor = Colors.transparent;
    
    return ButtonColors(
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
      shadowColor: Colors.transparent,
    );
  }

  ButtonColors _getTextButtonColors(InteractiveState state, bool isDarkTheme) {
    final textColor = ColorStateManager.getInteractiveColor(state, isDarkTheme: isDarkTheme);
    final backgroundColor = Colors.transparent;
    
    return ButtonColors(
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: Colors.transparent,
      shadowColor: Colors.transparent,
    );
  }

  ButtonColors _getElevatedButtonColors(InteractiveState state, bool isDarkTheme) {
    final backgroundColor = ColorStateManager.getInteractiveColor(state, isDarkTheme: isDarkTheme);
    final textColor = Colors.white;
    final shadowColor = backgroundColor.withOpacity(0.3);
    
    return ButtonColors(
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: backgroundColor,
      shadowColor: shadowColor,
    );
  }

  ButtonDimensions _getButtonDimensions() {
    switch (widget.size) {
      case ButtonSize.small:
        return ButtonDimensions(
          width: null,
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          borderRadius: BorderRadius.circular(6),
        );
      case ButtonSize.medium:
        return ButtonDimensions(
          width: null,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: BorderRadius.circular(8),
        );
      case ButtonSize.large:
        return ButtonDimensions(
          width: null,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          borderRadius: BorderRadius.circular(12),
        );
    }
  }

  TextStyle _getButtonTypography() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppTypography.labelMediumStyle;
      case ButtonSize.medium:
        return AppTypography.labelLargeStyle;
      case ButtonSize.large:
        return AppTypography.titleSmallStyle;
    }
  }

  String _getDefaultHint() {
    switch (widget.state) {
      case ButtonState.loading:
        return 'Button is loading';
      case ButtonState.disabled:
        return 'Button is disabled';
      case ButtonState.error:
        return 'Button encountered an error. Tap to retry';
      case ButtonState.success:
        return 'Action completed successfully';
      default:
        return 'Double tap to activate';
    }
  }
}

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  elevated,
}

enum ButtonSize {
  small,
  medium,
  large,
}

enum ButtonState {
  normal,
  loading,
  disabled,
  error,
  success,
}

class ButtonColors {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Color shadowColor;

  const ButtonColors({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.shadowColor,
  });
}

class ButtonDimensions {
  final double? width;
  final double height;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const ButtonDimensions({
    this.width,
    required this.height,
    required this.padding,
    required this.borderRadius,
  });
}

class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? semanticHint;
  final ButtonSize size;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool isDisabled;
  final Duration animationDuration;

  const AccessibleIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.semanticLabel,
    this.semanticHint,
    this.size = ButtonSize.medium,
    this.iconColor,
    this.backgroundColor,
    this.isDisabled = false,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? 
        (isDarkTheme ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    final effectiveBackgroundColor = backgroundColor ?? 
        (isDarkTheme ? AppColors.navbarBackground : AppColors.surfaceSecondary);

    return Semantics(
      label: semanticLabel ?? 'Icon button',
      hint: semanticHint ?? 'Double tap to activate',
      button: true,
      enabled: !isDisabled,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: isDisabled ? null : () {
            onPressed?.call();
            HapticFeedbackService.selection();
          },
          child: Container(
            width: _getSize(),
            height: _getSize(),
            decoration: BoxDecoration(
              color: effectiveBackgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: effectiveIconColor,
              size: _getIconSize(),
            ),
          ),
        ),
      ),
    );
  }

  double _getSize() {
    switch (size) {
      case ButtonSize.small:
        return 32;
      case ButtonSize.medium:
        return 40;
      case ButtonSize.large:
        return 48;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}
