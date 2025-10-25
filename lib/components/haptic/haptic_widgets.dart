import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/haptic_feedback_service.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

enum HapticType {
  light,
  medium,
  heavy,
  selection,
  impact,
  buttonPress,
}

class HapticButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final HapticType hapticType;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Widget? child;
  final Color? foregroundColor;

  const HapticButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.hapticType = HapticType.buttonPress,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.child,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _triggerHapticFeedback();
        onPressed?.call();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primaryLight,
        foregroundColor: foregroundColor ?? textColor ?? AppColors.textPrimaryLight,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
      child: child ?? Text(
        text,
        style: AppTypography.button.copyWith(
          color: textColor ?? AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  void _triggerHapticFeedback() {
    switch (hapticType) {
      case HapticType.light:
        HapticFeedbackService.light();
        break;
      case HapticType.medium:
        HapticFeedbackService.medium();
        break;
      case HapticType.heavy:
        HapticFeedbackService.heavy();
        break;
      case HapticType.selection:
        HapticFeedbackService.selection();
        break;
      case HapticType.impact:
        HapticFeedbackService.impact();
        break;
      case HapticType.buttonPress:
        HapticFeedbackService.light();
        break;
    }
  }
}

class HapticSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? title;
  final String? subtitle;
  final Color? activeColor;
  final Color? inactiveColor;

  const HapticSwitch({
    Key? key,
    required this.value,
    this.onChanged,
    this.title,
    this.subtitle,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: (newValue) {
        HapticFeedbackService.selection();
        onChanged?.call(newValue);
      },
      title: title != null ? Text(title!) : null,
      subtitle: subtitle != null ? Text(subtitle!) : null,
      activeColor: activeColor ?? AppColors.primaryLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class HapticSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int divisions;
  final String? label;
  final Color? activeColor;

  const HapticSlider({
    Key? key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions = 100,
    this.label,
    this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value,
      onChanged: (newValue) {
        HapticFeedbackService.light();
        onChanged?.call(newValue);
      },
      min: min,
      max: max,
      divisions: divisions,
      label: label,
      activeColor: activeColor ?? AppColors.primaryLight,
      inactiveColor: AppColors.borderDefault,
    );
  }
}
