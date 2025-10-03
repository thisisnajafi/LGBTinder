import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/typography.dart';

/// Responsive typography utility for scaling text based on screen size
class ResponsiveTypography {
  // Private constructor to prevent instantiation
  ResponsiveTypography._();

  /// Get responsive font size based on screen width
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate scale factor based on screen size
    double scaleFactor = 1.0;
    
    if (screenWidth < 360) {
      // Small phones (iPhone SE, etc.)
      scaleFactor = 0.85;
    } else if (screenWidth < 414) {
      // Medium phones
      scaleFactor = 0.9;
    } else if (screenWidth < 768) {
      // Large phones
      scaleFactor = 1.0;
    } else if (screenWidth < 1024) {
      // Tablets
      scaleFactor = 1.1;
    } else {
      // Large tablets/desktop
      scaleFactor = 1.2;
    }
    
    // Adjust for accessibility settings
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    scaleFactor *= textScaleFactor;
    
    return baseFontSize * scaleFactor;
  }

  /// Get responsive text style with proper scaling
  static TextStyle getResponsiveTextStyle(
    BuildContext context,
    TextStyle baseStyle, {
    double? customScaleFactor,
  }) {
    final scaleFactor = customScaleFactor ?? 
        _getScaleFactorForStyle(context, baseStyle.fontSize ?? 16);
    
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 16) * scaleFactor,
    );
  }

  /// Get scale factor for specific text style
  static double _getScaleFactorForStyle(BuildContext context, double fontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Different scaling for different font sizes
    if (fontSize >= 24) {
      // Large headings - less scaling
      return screenWidth < 360 ? 0.9 : screenWidth < 768 ? 1.0 : 1.1;
    } else if (fontSize >= 18) {
      // Medium headings
      return screenWidth < 360 ? 0.85 : screenWidth < 768 ? 1.0 : 1.15;
    } else if (fontSize >= 14) {
      // Body text
      return screenWidth < 360 ? 0.9 : screenWidth < 768 ? 1.0 : 1.1;
    } else {
      // Small text
      return screenWidth < 360 ? 0.85 : screenWidth < 768 ? 1.0 : 1.05;
    }
  }

  /// Get responsive display large style
  static TextStyle getDisplayLarge(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.displayLargeStyle,
    );
  }

  /// Get responsive display medium style
  static TextStyle getDisplayMedium(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.displayMediumStyle,
    );
  }

  /// Get responsive display small style
  static TextStyle getDisplaySmall(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.displaySmallStyle,
    );
  }

  /// Get responsive headline large style
  static TextStyle getHeadlineLarge(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.headlineLargeStyle,
    );
  }

  /// Get responsive headline medium style
  static TextStyle getHeadlineMedium(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.headlineMediumStyle,
    );
  }

  /// Get responsive headline small style
  static TextStyle getHeadlineSmall(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.headlineSmallStyle,
    );
  }

  /// Get responsive title large style
  static TextStyle getTitleLarge(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.titleLargeStyle,
    );
  }

  /// Get responsive title medium style
  static TextStyle getTitleMedium(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.titleMediumStyle,
    );
  }

  /// Get responsive title small style
  static TextStyle getTitleSmall(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.titleSmallStyle,
    );
  }

  /// Get responsive body large style
  static TextStyle getBodyLarge(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.bodyLargeStyle,
    );
  }

  /// Get responsive body medium style
  static TextStyle getBodyMedium(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.bodyMediumStyle,
    );
  }

  /// Get responsive body small style
  static TextStyle getBodySmall(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.bodySmallStyle,
    );
  }

  /// Get responsive label large style
  static TextStyle getLabelLarge(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.labelLargeStyle,
    );
  }

  /// Get responsive label medium style
  static TextStyle getLabelMedium(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.labelMediumStyle,
    );
  }

  /// Get responsive label small style
  static TextStyle getLabelSmall(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.labelSmallStyle,
    );
  }

  /// Get responsive button text style
  static TextStyle getButtonText(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.buttonStyle,
    );
  }

  /// Get responsive caption text style
  static TextStyle getCaption(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.captionStyle,
    );
  }

  /// Get responsive overline text style
  static TextStyle getOverline(BuildContext context) {
    return getResponsiveTextStyle(
      context,
      AppTypography.overlineStyle,
    );
  }

  /// Get responsive heading styles (h1-h6)
  static TextStyle getHeading(BuildContext context, int level) {
    switch (level) {
      case 1:
        return getHeadlineLarge(context);
      case 2:
        return getHeadlineMedium(context);
      case 3:
        return getHeadlineSmall(context);
      case 4:
        return getTitleLarge(context);
      case 5:
        return getTitleMedium(context);
      case 6:
        return getTitleSmall(context);
      default:
        return getBodyLarge(context);
    }
  }

  /// Get responsive subtitle styles
  static TextStyle getSubtitle(BuildContext context, int level) {
    switch (level) {
      case 1:
        return getBodyLarge(context);
      case 2:
        return getBodyMedium(context);
      default:
        return getBodyMedium(context);
    }
  }

  /// Check if device is small screen
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  /// Check if device is medium screen
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 360 && width < 768;
  }

  /// Check if device is large screen
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  /// Get device type for responsive design
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 360) {
      return DeviceType.smallPhone;
    } else if (width < 414) {
      return DeviceType.mediumPhone;
    } else if (width < 768) {
      return DeviceType.largePhone;
    } else if (width < 1024) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context, {
    double? small,
    double? medium,
    double? large,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.smallPhone:
        return EdgeInsets.all(small ?? 8.0);
      case DeviceType.mediumPhone:
        return EdgeInsets.all(medium ?? 12.0);
      case DeviceType.largePhone:
        return EdgeInsets.all(medium ?? 16.0);
      case DeviceType.tablet:
        return EdgeInsets.all(large ?? 20.0);
      case DeviceType.desktop:
        return EdgeInsets.all(large ?? 24.0);
    }
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context, {
    double? small,
    double? medium,
    double? large,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.smallPhone:
        return EdgeInsets.all(small ?? 8.0);
      case DeviceType.mediumPhone:
        return EdgeInsets.all(medium ?? 12.0);
      case DeviceType.largePhone:
        return EdgeInsets.all(medium ?? 16.0);
      case DeviceType.tablet:
        return EdgeInsets.all(large ?? 20.0);
      case DeviceType.desktop:
        return EdgeInsets.all(large ?? 24.0);
    }
  }
}

/// Device types for responsive design
enum DeviceType {
  smallPhone,
  mediumPhone,
  largePhone,
  tablet,
  desktop,
}

/// Responsive text widget that automatically scales text
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? customScaleFactor;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.customScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsiveStyle = ResponsiveTypography.getResponsiveTextStyle(
      context,
      style ?? AppTypography.body1,
      customScaleFactor: customScaleFactor,
    );

    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive heading widget
class ResponsiveHeading extends StatelessWidget {
  final String text;
  final int level;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveHeading(
    this.text, {
    Key? key,
    this.level = 1,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsiveStyle = ResponsiveTypography.getHeading(context, level);
    final finalStyle = style != null ? responsiveStyle.merge(style) : responsiveStyle;

    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
