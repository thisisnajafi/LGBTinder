import 'package:flutter/material.dart';

class AppTypography {
  // Font Families
  static const String primaryFont = 'Nunito';
  static const String secondaryFont = 'Inter';

  // Font Sizes
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;

  // Font Weight Hierarchy - Comprehensive
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;
  
  // Font Weight Variants for Different Contexts
  static const FontWeight headingWeight = FontWeight.w700; // Bold for headings
  static const FontWeight subheadingWeight = FontWeight.w600; // Semi-bold for subheadings
  static const FontWeight bodyWeight = FontWeight.w400; // Regular for body text
  static const FontWeight captionWeight = FontWeight.w400; // Regular for captions
  static const FontWeight buttonWeight = FontWeight.w600; // Semi-bold for buttons
  static const FontWeight labelWeight = FontWeight.w500; // Medium for labels
  static const FontWeight overlineWeight = FontWeight.w500; // Medium for overlines

  // Text Styles
  static const TextStyle displayLargeStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: displayLarge,
    fontWeight: headingWeight,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMediumStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: displayMedium,
    fontWeight: headingWeight,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmallStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: displaySmall,
    fontWeight: headingWeight,
    letterSpacing: -0.25,
  );

  static const TextStyle headlineLargeStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: headlineLarge,
    fontWeight: headingWeight,
    letterSpacing: -0.25,
  );

  static const TextStyle headlineMediumStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: headlineMedium,
    fontWeight: headingWeight,
    letterSpacing: -0.25,
  );

  static const TextStyle headlineSmallStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: headlineSmall,
    fontWeight: headingWeight,
    letterSpacing: -0.25,
  );

  static const TextStyle titleLargeStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: titleLarge,
    fontWeight: subheadingWeight,
    letterSpacing: 0,
  );

  static const TextStyle titleMediumStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: titleMedium,
    fontWeight: subheadingWeight,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmallStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: titleSmall,
    fontWeight: subheadingWeight,
    letterSpacing: 0.1,
  );

  static const TextStyle bodyLargeStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: bodyLarge,
    fontWeight: bodyWeight,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMediumStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: bodyMedium,
    fontWeight: bodyWeight,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmallStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: bodySmall,
    fontWeight: bodyWeight,
    letterSpacing: 0.4,
  );

  static const TextStyle labelLargeStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: labelLarge,
    fontWeight: labelWeight,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMediumStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: labelMedium,
    fontWeight: labelWeight,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmallStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: labelSmall,
    fontWeight: labelWeight,
    letterSpacing: 0.5,
  );
  
  // Consolidated Typography Styles - Use Material Design 3 naming
  static const TextStyle h6 = titleLargeStyle; // 22.0
  static const TextStyle subtitle2 = titleSmallStyle; // 14.0
  static const TextStyle body2 = bodyMediumStyle; // 14.0
  static const TextStyle caption = labelSmallStyle; // 11.0
  static const TextStyle button = labelLargeStyle; // 14.0
  
  // Additional typography styles - Consolidated
  static const TextStyle headline6 = h6; // Alias for h6
  static const TextStyle buttonStyle = button; // Alias for button

  // Additional typography styles for authentication screens - Consolidated
  static const TextStyle h1 = headlineLargeStyle; // 32.0
  static const TextStyle h2 = headlineMediumStyle; // 28.0
  static const TextStyle h4 = headlineSmallStyle; // 24.0
  static const TextStyle h5 = titleLargeStyle; // 22.0
  static const TextStyle subtitle1 = bodyLargeStyle; // 16.0
  static const TextStyle body1 = bodyLargeStyle; // 16.0

  static TextStyle get heading2 => headlineMediumStyle.copyWith(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get heading3 => titleLargeStyle.copyWith(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
  );

  // Font Weight Utility Methods
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withThin(TextStyle style) {
    return style.copyWith(fontWeight: thin);
  }

  static TextStyle withLight(TextStyle style) {
    return style.copyWith(fontWeight: light);
  }

  static TextStyle withRegular(TextStyle style) {
    return style.copyWith(fontWeight: regular);
  }

  static TextStyle withMedium(TextStyle style) {
    return style.copyWith(fontWeight: medium);
  }

  static TextStyle withSemiBold(TextStyle style) {
    return style.copyWith(fontWeight: semiBold);
  }

  static TextStyle withBold(TextStyle style) {
    return style.copyWith(fontWeight: bold);
  }

  static TextStyle withExtraBold(TextStyle style) {
    return style.copyWith(fontWeight: extraBold);
  }

  static TextStyle withBlack(TextStyle style) {
    return style.copyWith(fontWeight: black);
  }

  // Context-specific font weight methods
  static TextStyle forHeading(TextStyle style) {
    return style.copyWith(fontWeight: headingWeight);
  }

  static TextStyle forSubheading(TextStyle style) {
    return style.copyWith(fontWeight: subheadingWeight);
  }

  static TextStyle forBody(TextStyle style) {
    return style.copyWith(fontWeight: bodyWeight);
  }

  static TextStyle forButton(TextStyle style) {
    return style.copyWith(fontWeight: buttonWeight);
  }

  static TextStyle forLabel(TextStyle style) {
    return style.copyWith(fontWeight: labelWeight);
  }

  static TextStyle forCaption(TextStyle style) {
    return style.copyWith(fontWeight: captionWeight);
  }

  static TextStyle forOverline(TextStyle style) {
    return style.copyWith(fontWeight: overlineWeight);
  }
} 