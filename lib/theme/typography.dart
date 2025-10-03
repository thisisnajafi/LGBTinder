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

  // Text Styles
  static const TextStyle displayLargeStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: displayLarge,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMediumStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: displayMedium,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmallStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: displaySmall,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );

  static const TextStyle headlineLargeStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: headlineLarge,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );

  static const TextStyle headlineMediumStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: headlineMedium,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );

  static const TextStyle headlineSmallStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: headlineSmall,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );

  static const TextStyle titleLargeStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: titleLarge,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle titleMediumStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: titleMedium,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmallStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: titleSmall,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle bodyLargeStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: bodyLarge,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMediumStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: bodyMedium,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmallStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: bodySmall,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );

  static const TextStyle labelLargeStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: labelLarge,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMediumStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: labelMedium,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmallStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: labelSmall,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  
  // Additional Typography Styles
  static const TextStyle h6 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  static const TextStyle body2 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );
  
  static const TextStyle caption = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );
  
  static const TextStyle button = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
  
  // Additional typography styles
  static const TextStyle headline6 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );
  
  static const TextStyle buttonStyle = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // Additional typography styles for authentication screens
  static const TextStyle h1 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );


  static const TextStyle h5 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  );

  static TextStyle get heading2 => headlineMediumStyle.copyWith(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get heading3 => titleLargeStyle.copyWith(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
  );
} 