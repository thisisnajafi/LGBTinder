import 'package:flutter/material.dart';
import 'colors.dart';

/// Semantic color utility class for consistent UI state colors
class SemanticColors {
  // Private constructor to prevent instantiation
  SemanticColors._();

  /// Get surface color based on elevation level
  static Color getSurfaceColor(BuildContext context, {int elevation = 0}) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    switch (elevation) {
      case 0:
        return brightness == Brightness.dark 
            ? AppColors.navbarBackground 
            : AppColors.surfacePrimary;
      case 1:
        return brightness == Brightness.dark 
            ? AppColors.cardBackgroundDark 
            : AppColors.surfaceSecondary;
      case 2:
        return brightness == Brightness.dark 
            ? AppColors.cardBackgroundDark.withOpacity(0.8)
            : AppColors.surfaceTertiary;
      default:
        return theme.cardColor;
    }
  }

  /// Get interactive color based on state
  static Color getInteractiveColor(BuildContext context, {
    required InteractiveState state,
  }) {
    switch (state) {
      case InteractiveState.defaultState:
        return AppColors.interactiveDefault;
      case InteractiveState.hover:
        return AppColors.interactiveHover;
      case InteractiveState.pressed:
        return AppColors.interactivePressed;
      case InteractiveState.disabled:
        return AppColors.interactiveDisabled;
      case InteractiveState.focus:
        return AppColors.interactiveFocus;
    }
  }

  /// Get feedback color based on type
  static Color getFeedbackColor(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        return AppColors.feedbackSuccess;
      case FeedbackType.warning:
        return AppColors.feedbackWarning;
      case FeedbackType.error:
        return AppColors.feedbackError;
      case FeedbackType.info:
        return AppColors.feedbackInfo;
    }
  }

  /// Get border color based on state
  static Color getBorderColor(BuildContext context, {
    required BorderState state,
  }) {
    switch (state) {
      case BorderState.defaultState:
        return AppColors.borderDefault;
      case BorderState.hover:
        return AppColors.borderHover;
      case BorderState.focus:
        return AppColors.borderFocus;
      case BorderState.error:
        return AppColors.borderError;
    }
  }

  /// Get text color based on state
  static Color getTextColor(BuildContext context, {
    required TextState state,
  }) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    switch (state) {
      case TextState.primary:
        return brightness == Brightness.dark 
            ? AppColors.textPrimaryDark 
            : AppColors.textPrimaryLight;
      case TextState.secondary:
        return brightness == Brightness.dark 
            ? AppColors.textSecondaryDark 
            : AppColors.textSecondaryLight;
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

  /// Get LGBT pride color based on identity
  static Color getPrideColor(PrideIdentity identity) {
    switch (identity) {
      case PrideIdentity.rainbow:
        return AppColors.primaryLight; // Use primary as rainbow representative
      case PrideIdentity.trans:
        return AppColors.transBlue;
      case PrideIdentity.nonBinary:
        return AppColors.nonBinaryPurple;
      case PrideIdentity.lesbian:
        return AppColors.prideOrange;
      case PrideIdentity.gay:
        return AppColors.prideBlue;
      case PrideIdentity.bisexual:
        return AppColors.pridePurple;
      case PrideIdentity.pansexual:
        return AppColors.prideYellow;
      case PrideIdentity.asexual:
        return AppColors.pridePurple;
    }
  }

  /// Get LGBT pride gradient colors
  static List<Color> getPrideGradient(PrideIdentity identity) {
    switch (identity) {
      case PrideIdentity.rainbow:
        return [
          AppColors.prideRed,
          AppColors.prideOrange,
          AppColors.prideYellow,
          AppColors.prideGreen,
          AppColors.prideBlue,
          AppColors.pridePurple,
        ];
      case PrideIdentity.trans:
        return [
          AppColors.transBlue,
          AppColors.transPink,
          AppColors.transWhite,
          AppColors.transPink,
          AppColors.transBlue,
        ];
      case PrideIdentity.nonBinary:
        return [
          AppColors.nonBinaryYellow,
          AppColors.nonBinaryWhite,
          AppColors.nonBinaryPurple,
          AppColors.nonBinaryBlack,
        ];
      default:
        return [getPrideColor(identity)];
    }
  }

  /// Get background color based on context
  static Color getBackgroundColor(BuildContext context, {
    BackgroundType type = BackgroundType.primary,
  }) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    switch (type) {
      case BackgroundType.primary:
        return brightness == Brightness.dark 
            ? AppColors.appBackground 
            : AppColors.backgroundLight;
      case BackgroundType.secondary:
        return brightness == Brightness.dark 
            ? AppColors.navbarBackground 
            : AppColors.surfaceSecondary;
      case BackgroundType.overlay:
        return AppColors.backgroundOverlay;
      case BackgroundType.modal:
        return AppColors.backgroundModal;
      case BackgroundType.tooltip:
        return AppColors.backgroundTooltip;
    }
  }
}

/// Enums for semantic color states
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

enum PrideIdentity {
  rainbow,
  trans,
  nonBinary,
  lesbian,
  gay,
  bisexual,
  pansexual,
  asexual,
}

enum BackgroundType {
  primary,
  secondary,
  overlay,
  modal,
  tooltip,
}
