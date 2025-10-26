import 'package:flutter/material.dart';

/// Border radius constants for consistent UI
/// 
/// Standard values: 8, 12, 16, 20, 24, 32
class BorderRadiusConstants {
  // Standard border radius values
  static const double radiusXSmall = 4.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radius2XLarge = 24.0;
  static const double radius3XLarge = 32.0;
  static const double radiusFull = 9999.0; // Circular
  
  // Pre-defined BorderRadius objects for convenience
  static final BorderRadius xSmall = BorderRadius.circular(radiusXSmall);
  static final BorderRadius small = BorderRadius.circular(radiusSmall);
  static final BorderRadius medium = BorderRadius.circular(radiusMedium);
  static final BorderRadius large = BorderRadius.circular(radiusLarge);
  static final BorderRadius xLarge = BorderRadius.circular(radiusXLarge);
  static final BorderRadius xxLarge = BorderRadius.circular(radius2XLarge);
  static final BorderRadius xxxLarge = BorderRadius.circular(radius3XLarge);
  static final BorderRadius full = BorderRadius.circular(radiusFull);
  
  // Top-only border radius
  static BorderRadius topOnly(double radius) => BorderRadius.only(
    topLeft: Radius.circular(radius),
    topRight: Radius.circular(radius),
  );
  
  // Bottom-only border radius
  static BorderRadius bottomOnly(double radius) => BorderRadius.only(
    bottomLeft: Radius.circular(radius),
    bottomRight: Radius.circular(radius),
  );
}


