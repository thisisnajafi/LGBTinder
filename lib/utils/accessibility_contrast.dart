import 'package:flutter/material.dart';
import 'dart:math' as math;

class AccessibilityContrast {
  // Private constructor to prevent instantiation
  AccessibilityContrast._();

  // WCAG contrast ratio thresholds
  static const double normalTextContrast = 4.5; // AA level
  static const double largeTextContrast = 3.0; // AA level for large text
  static const double enhancedContrast = 7.0; // AAA level

  /// Calculate the relative luminance of a color
  static double getRelativeLuminance(Color color) {
    final r = _linearizeColorComponent(color.red / 255.0);
    final g = _linearizeColorComponent(color.green / 255.0);
    final b = _linearizeColorComponent(color.blue / 255.0);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Linearize a color component for luminance calculation
  static double _linearizeColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    } else {
      return math.pow((component + 0.055) / 1.055, 2.4).toDouble();
    }
  }

  /// Calculate contrast ratio between two colors
  static double getContrastRatio(Color color1, Color color2) {
    final luminance1 = getRelativeLuminance(color1);
    final luminance2 = getRelativeLuminance(color2);
    
    final lighter = math.max(luminance1, luminance2);
    final darker = math.min(luminance1, luminance2);
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if contrast ratio meets WCAG AA standards
  static bool meetsAAStandards(Color foreground, Color background, {bool isLargeText = false}) {
    final contrastRatio = getContrastRatio(foreground, background);
    return contrastRatio >= (isLargeText ? largeTextContrast : normalTextContrast);
  }

  /// Check if contrast ratio meets WCAG AAA standards
  static bool meetsAAAStandards(Color foreground, Color background, {bool isLargeText = false}) {
    final contrastRatio = getContrastRatio(foreground, background);
    return contrastRatio >= enhancedContrast;
  }

  /// Get the best text color for a given background
  static Color getBestTextColor(Color background, {
    Color? lightText,
    Color? darkText,
    bool preferDark = true,
  }) {
    lightText ??= Colors.white;
    darkText ??= Colors.black;
    
    final lightContrast = getContrastRatio(lightText, background);
    final darkContrast = getContrastRatio(darkText, background);
    
    if (preferDark && darkContrast >= normalTextContrast) {
      return darkText;
    } else if (lightContrast >= normalTextContrast) {
      return lightText;
    } else {
      return darkContrast > lightContrast ? darkText : lightText;
    }
  }

  /// Adjust color brightness to meet contrast requirements
  static Color adjustColorForContrast(Color foreground, Color background, {
    bool isLargeText = false,
    bool preferLighter = true,
  }) {
    final requiredContrast = isLargeText ? largeTextContrast : normalTextContrast;
    final currentContrast = getContrastRatio(foreground, background);
    
    if (currentContrast >= requiredContrast) {
      return foreground;
    }
    
    // Calculate how much we need to adjust
    final adjustmentFactor = requiredContrast / currentContrast;
    
    // Adjust the color
    final hsl = HSLColor.fromColor(foreground);
    final newLightness = preferLighter 
        ? math.min(1.0, hsl.lightness * adjustmentFactor)
        : math.max(0.0, hsl.lightness / adjustmentFactor);
    
    return hsl.withLightness(newLightness).toColor();
  }

  /// Get accessible color pair
  static AccessibleColorPair getAccessibleColorPair(Color baseColor, {
    bool isLargeText = false,
    bool preferDarkBackground = true,
  }) {
    final background = preferDarkBackground ? Colors.black : Colors.white;
    final foreground = getBestTextColor(background);
    
    // If the base color doesn't meet contrast requirements, adjust it
    final adjustedForeground = adjustColorForContrast(
      baseColor,
      background,
      isLargeText: isLargeText,
    );
    
    return AccessibleColorPair(
      foreground: adjustedForeground,
      background: background,
      contrastRatio: getContrastRatio(adjustedForeground, background),
    );
  }

  /// Generate accessible color palette
  static AccessibleColorPalette generatePalette(Color primaryColor, {
    bool isDarkTheme = true,
  }) {
    final background = isDarkTheme ? Colors.black : Colors.white;
    final surface = isDarkTheme ? Colors.grey[900]! : Colors.grey[100]!;
    
    // Primary colors
    final primaryForeground = getBestTextColor(background);
    final primaryAdjusted = adjustColorForContrast(primaryColor, background);
    
    // Secondary colors
    final secondary = primaryColor.withOpacity(0.7);
    final secondaryForeground = getBestTextColor(background);
    final secondaryAdjusted = adjustColorForContrast(secondary, background);
    
    // Error colors
    final error = Colors.red;
    final errorForeground = getBestTextColor(background);
    final errorAdjusted = adjustColorForContrast(error, background);
    
    // Success colors
    final success = Colors.green;
    final successForeground = getBestTextColor(background);
    final successAdjusted = adjustColorForContrast(success, background);
    
    // Warning colors
    final warning = Colors.orange;
    final warningForeground = getBestTextColor(background);
    final warningAdjusted = adjustColorForContrast(warning, background);
    
    return AccessibleColorPalette(
      primary: primaryAdjusted,
      primaryForeground: primaryForeground,
      secondary: secondaryAdjusted,
      secondaryForeground: secondaryForeground,
      error: errorAdjusted,
      errorForeground: errorForeground,
      success: successAdjusted,
      successForeground: successForeground,
      warning: warningAdjusted,
      warningForeground: warningForeground,
      background: background,
      surface: surface,
    );
  }

  /// Validate color accessibility
  static AccessibilityReport validateAccessibility(Color foreground, Color background) {
    final contrastRatio = getContrastRatio(foreground, background);
    final meetsAA = meetsAAStandards(foreground, background);
    final meetsAAA = meetsAAAStandards(foreground, background);
    
    return AccessibilityReport(
      contrastRatio: contrastRatio,
      meetsAA: meetsAA,
      meetsAAA: meetsAAA,
      recommendation: _getRecommendation(contrastRatio),
    );
  }

  static String _getRecommendation(double contrastRatio) {
    if (contrastRatio >= enhancedContrast) {
      return 'Excellent contrast ratio. Meets AAA standards.';
    } else if (contrastRatio >= normalTextContrast) {
      return 'Good contrast ratio. Meets AA standards.';
    } else if (contrastRatio >= largeTextContrast) {
      return 'Acceptable for large text only. Consider improving for normal text.';
    } else {
      return 'Poor contrast ratio. Does not meet accessibility standards.';
    }
  }
}

class AccessibleColorPair {
  final Color foreground;
  final Color background;
  final double contrastRatio;

  const AccessibleColorPair({
    required this.foreground,
    required this.background,
    required this.contrastRatio,
  });
}

class AccessibleColorPalette {
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color error;
  final Color errorForeground;
  final Color success;
  final Color successForeground;
  final Color warning;
  final Color warningForeground;
  final Color background;
  final Color surface;

  const AccessibleColorPalette({
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.error,
    required this.errorForeground,
    required this.success,
    required this.successForeground,
    required this.warning,
    required this.warningForeground,
    required this.background,
    required this.surface,
  });
}

class AccessibilityReport {
  final double contrastRatio;
  final bool meetsAA;
  final bool meetsAAA;
  final String recommendation;

  const AccessibilityReport({
    required this.contrastRatio,
    required this.meetsAA,
    required this.meetsAAA,
    required this.recommendation,
  });
}

class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? backgroundColor;
  final bool isLargeText;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AccessibleText(
    this.text, {
    Key? key,
    this.style,
    this.backgroundColor,
    this.isLargeText = false,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveStyle = style ?? theme.textTheme.bodyMedium!;
    final effectiveBackground = backgroundColor ?? theme.scaffoldBackgroundColor;
    
    // Get accessible text color
    final accessibleColor = AccessibilityContrast.getBestTextColor(
      effectiveBackground,
      lightText: Colors.white,
      darkText: Colors.black,
    );
    
    // Adjust color if needed
    final adjustedColor = AccessibilityContrast.adjustColorForContrast(
      accessibleColor,
      effectiveBackground,
      isLargeText: isLargeText,
    );
    
    return Text(
      text,
      style: effectiveStyle.copyWith(color: adjustedColor),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
