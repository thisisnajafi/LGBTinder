import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ColorStateManager {
  // Private constructor to prevent instantiation
  ColorStateManager._();

  /// Get interactive color based on state and theme
  static Color getInteractiveColor(InteractiveState state, {bool isDarkTheme = true}) {
    switch (state) {
      case InteractiveState.defaultState:
        return AppColors.interactiveDefault;
      case InteractiveState.hover:
        return isDarkTheme ? AppColors.interactiveHoverDark : AppColors.interactiveHoverLight;
      case InteractiveState.pressed:
        return isDarkTheme ? AppColors.interactivePressedDark : AppColors.interactivePressedLight;
      case InteractiveState.disabled:
        return isDarkTheme ? AppColors.interactiveDisabledDark : AppColors.interactiveDisabledLight;
      case InteractiveState.focus:
        return isDarkTheme ? AppColors.interactiveFocusDark : AppColors.interactiveFocusLight;
    }
  }

  /// Get feedback color based on type and theme
  static Color getFeedbackColor(FeedbackType type, {bool isDarkTheme = true}) {
    switch (type) {
      case FeedbackType.success:
        return isDarkTheme ? AppColors.feedbackSuccessDark : AppColors.feedbackSuccessLight;
      case FeedbackType.warning:
        return isDarkTheme ? AppColors.feedbackWarningDark : AppColors.feedbackWarningLight;
      case FeedbackType.error:
        return isDarkTheme ? AppColors.feedbackErrorDark : AppColors.feedbackErrorLight;
      case FeedbackType.info:
        return isDarkTheme ? AppColors.feedbackInfoDark : AppColors.feedbackInfoLight;
    }
  }

  /// Get border color based on state and theme
  static Color getBorderColor(BorderState state, {bool isDarkTheme = true}) {
    switch (state) {
      case BorderState.defaultState:
        return isDarkTheme ? AppColors.borderDefaultDark : AppColors.borderDefaultLight;
      case BorderState.hover:
        return isDarkTheme ? AppColors.borderHoverDark : AppColors.borderHoverLight;
      case BorderState.focus:
        return isDarkTheme ? AppColors.borderFocusDark : AppColors.borderFocusLight;
      case BorderState.error:
        return isDarkTheme ? AppColors.borderErrorDark : AppColors.borderErrorLight;
    }
  }

  /// Get surface color based on elevation and theme
  static Color getSurfaceColor(int elevation, {bool isDarkTheme = true}) {
    if (isDarkTheme) {
      switch (elevation) {
        case 0:
          return AppColors.appBackground;
        case 1:
          return AppColors.navbarBackground;
        case 2:
          return AppColors.cardBackgroundDark;
        default:
          return AppColors.cardBackgroundDark;
      }
    } else {
      switch (elevation) {
        case 0:
          return AppColors.backgroundLight;
        case 1:
          return AppColors.surfaceSecondary;
        case 2:
          return AppColors.surfaceTertiary;
        default:
          return AppColors.surfaceTertiary;
      }
    }
  }

  /// Get text color based on state and theme
  static Color getTextColor(TextState state, {bool isDarkTheme = true}) {
    switch (state) {
      case TextState.primary:
        return isDarkTheme ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
      case TextState.secondary:
        return isDarkTheme ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
      case TextState.interactive:
        return AppColors.textInteractive;
      case TextState.interactiveHover:
        return AppColors.textInteractiveHover;
      case TextState.disabled:
        return AppColors.textDisabled;
      case TextState.placeholder:
        return AppColors.textPlaceholder;
    }
  }

  /// Create color scheme for a specific state
  static ColorScheme createColorScheme(InteractiveState state, {bool isDarkTheme = true}) {
    final primary = getInteractiveColor(state, isDarkTheme: isDarkTheme);
    final surface = getSurfaceColor(1, isDarkTheme: isDarkTheme);
    final background = getSurfaceColor(0, isDarkTheme: isDarkTheme);
    
    return ColorScheme.fromSeed(
      seedColor: primary,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      surface: surface,
      background: background,
    );
  }

  /// Get color with opacity based on state
  static Color getColorWithOpacity(Color color, InteractiveState state) {
    switch (state) {
      case InteractiveState.defaultState:
        return color;
      case InteractiveState.hover:
        return color.withOpacity(0.8);
      case InteractiveState.pressed:
        return color.withOpacity(0.6);
      case InteractiveState.disabled:
        return color.withOpacity(0.4);
      case InteractiveState.focus:
        return color.withOpacity(0.9);
    }
  }

  /// Create gradient based on state
  static LinearGradient createStateGradient(InteractiveState state, {bool isDarkTheme = true}) {
    final color = getInteractiveColor(state, isDarkTheme: isDarkTheme);
    
    switch (state) {
      case InteractiveState.hover:
        return LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case InteractiveState.pressed:
        return LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [color, color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}

enum InteractiveState {
  defaultState,
  hover,
  pressed,
  disabled,
  focus,
}

enum FeedbackType {
  success,
  warning,
  error,
  info,
}

enum BorderState {
  defaultState,
  hover,
  focus,
  error,
}

enum TextState {
  primary,
  secondary,
  interactive,
  interactiveHover,
  disabled,
  placeholder,
}

class StatefulColorWidget extends StatefulWidget {
  final Widget child;
  final Color Function(InteractiveState state) colorBuilder;
  final InteractiveState initialState;

  const StatefulColorWidget({
    Key? key,
    required this.child,
    required this.colorBuilder,
    this.initialState = InteractiveState.defaultState,
  }) : super(key: key);

  @override
  State<StatefulColorWidget> createState() => _StatefulColorWidgetState();
}

class _StatefulColorWidgetState extends State<StatefulColorWidget> {
  InteractiveState _currentState = InteractiveState.defaultState;

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;
  }

  void _updateState(InteractiveState newState) {
    setState(() {
      _currentState = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _updateState(InteractiveState.hover),
      onExit: (_) => _updateState(InteractiveState.defaultState),
      child: GestureDetector(
        onTapDown: (_) => _updateState(InteractiveState.pressed),
        onTapUp: (_) => _updateState(InteractiveState.hover),
        onTapCancel: () => _updateState(InteractiveState.defaultState),
        child: Focus(
          onFocusChange: (hasFocus) {
            _updateState(hasFocus ? InteractiveState.focus : InteractiveState.defaultState);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: widget.colorBuilder(_currentState),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
