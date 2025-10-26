import 'package:flutter/material.dart';

/// Spacing constants for consistent UI
/// 
/// Standard values based on 4px/8px grid system
class SpacingConstants {
  // Base spacing values (8px system)
  static const double spacing0 = 0.0;
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;
  static const double spacing64 = 64.0;
  static const double spacing80 = 80.0;
  static const double spacing96 = 96.0;
  static const double spacing128 = 128.0;
  
  // Pre-defined SizedBox widgets for convenience
  static const SizedBox sizedBox0 = SizedBox.shrink();
  static const SizedBox sizedBox2 = SizedBox(height: spacing2, width: spacing2);
  static const SizedBox sizedBox4 = SizedBox(height: spacing4, width: spacing4);
  static const SizedBox sizedBox8 = SizedBox(height: spacing8, width: spacing8);
  static const SizedBox sizedBox12 = SizedBox(height: spacing12, width: spacing12);
  static const SizedBox sizedBox16 = SizedBox(height: spacing16, width: spacing16);
  static const SizedBox sizedBox20 = SizedBox(height: spacing20, width: spacing20);
  static const SizedBox sizedBox24 = SizedBox(height: spacing24, width: spacing24);
  static const SizedBox sizedBox32 = SizedBox(height: spacing32, width: spacing32);
  static const SizedBox sizedBox40 = SizedBox(height: spacing40, width: spacing40);
  static const SizedBox sizedBox48 = SizedBox(height: spacing48, width: spacing48);
  static const SizedBox sizedBox56 = SizedBox(height: spacing56, width: spacing56);
  static const SizedBox sizedBox64 = SizedBox(height: spacing64, width: spacing64);
  
  // Vertical spacing helpers
  static const SizedBox verticalSpace2 = SizedBox(height: spacing2);
  static const SizedBox verticalSpace4 = SizedBox(height: spacing4);
  static const SizedBox verticalSpace8 = SizedBox(height: spacing8);
  static const SizedBox verticalSpace12 = SizedBox(height: spacing12);
  static const SizedBox verticalSpace16 = SizedBox(height: spacing16);
  static const SizedBox verticalSpace20 = SizedBox(height: spacing20);
  static const SizedBox verticalSpace24 = SizedBox(height: spacing24);
  static const SizedBox verticalSpace32 = SizedBox(height: spacing32);
  static const SizedBox verticalSpace40 = SizedBox(height: spacing40);
  static const SizedBox verticalSpace48 = SizedBox(height: spacing48);
  static const SizedBox verticalSpace64 = SizedBox(height: spacing64);
  
  // Horizontal spacing helpers
  static const SizedBox horizontalSpace2 = SizedBox(width: spacing2);
  static const SizedBox horizontalSpace4 = SizedBox(width: spacing4);
  static const SizedBox horizontalSpace8 = SizedBox(width: spacing8);
  static const SizedBox horizontalSpace12 = SizedBox(width: spacing12);
  static const SizedBox horizontalSpace16 = SizedBox(width: spacing16);
  static const SizedBox horizontalSpace20 = SizedBox(width: spacing20);
  static const SizedBox horizontalSpace24 = SizedBox(width: spacing24);
  static const SizedBox horizontalSpace32 = SizedBox(width: spacing32);
  static const SizedBox horizontalSpace40 = SizedBox(width: spacing40);
  static const SizedBox horizontalSpace48 = SizedBox(width: spacing48);
  static const SizedBox horizontalSpace64 = SizedBox(width: spacing64);
  
  // EdgeInsets presets
  static const EdgeInsets paddingAll4 = EdgeInsets.all(spacing4);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(spacing8);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(spacing12);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(spacing16);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(spacing20);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(spacing24);
  static const EdgeInsets paddingAll32 = EdgeInsets.all(spacing32);
  
  // Horizontal padding presets
  static const EdgeInsets paddingH4 = EdgeInsets.symmetric(horizontal: spacing4);
  static const EdgeInsets paddingH8 = EdgeInsets.symmetric(horizontal: spacing8);
  static const EdgeInsets paddingH12 = EdgeInsets.symmetric(horizontal: spacing12);
  static const EdgeInsets paddingH16 = EdgeInsets.symmetric(horizontal: spacing16);
  static const EdgeInsets paddingH20 = EdgeInsets.symmetric(horizontal: spacing20);
  static const EdgeInsets paddingH24 = EdgeInsets.symmetric(horizontal: spacing24);
  static const EdgeInsets paddingH32 = EdgeInsets.symmetric(horizontal: spacing32);
  
  // Vertical padding presets
  static const EdgeInsets paddingV4 = EdgeInsets.symmetric(vertical: spacing4);
  static const EdgeInsets paddingV8 = EdgeInsets.symmetric(vertical: spacing8);
  static const EdgeInsets paddingV12 = EdgeInsets.symmetric(vertical: spacing12);
  static const EdgeInsets paddingV16 = EdgeInsets.symmetric(vertical: spacing16);
  static const EdgeInsets paddingV20 = EdgeInsets.symmetric(vertical: spacing20);
  static const EdgeInsets paddingV24 = EdgeInsets.symmetric(vertical: spacing24);
  static const EdgeInsets paddingV32 = EdgeInsets.symmetric(vertical: spacing32);
}


