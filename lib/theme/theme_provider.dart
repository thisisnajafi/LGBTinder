import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      error: AppColors.errorLight,
      background: AppColors.backgroundLight,
      surface: AppColors.cardBackgroundLight,
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLargeStyle.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      displayMedium: AppTypography.displayMediumStyle.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      displaySmall: AppTypography.displaySmallStyle.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      headlineLarge: AppTypography.headlineLargeStyle.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      headlineMedium: AppTypography.headlineMediumStyle.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      headlineSmall: AppTypography.headlineSmallStyle.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      titleLarge: AppTypography.titleLargeStyle.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      titleMedium: AppTypography.titleMediumStyle.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      titleSmall: AppTypography.titleSmallStyle.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      bodyLarge: AppTypography.bodyLargeStyle.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      bodyMedium: AppTypography.bodyMediumStyle.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      bodySmall: AppTypography.bodySmallStyle.copyWith(
        color: AppColors.textSecondaryLight,
      ),
      labelLarge: AppTypography.labelLargeStyle.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      labelMedium: AppTypography.labelMediumStyle.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      labelSmall: AppTypography.labelSmallStyle.copyWith(
        color: AppColors.textSecondaryLight,
      ),
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    cardColor: AppColors.cardBackgroundLight,
    dividerColor: AppColors.borderLight,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
      error: AppColors.errorDark,
      background: AppColors.backgroundDark,
      surface: AppColors.cardBackgroundDark,
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLargeStyle.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      displayMedium: AppTypography.displayMediumStyle.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      displaySmall: AppTypography.displaySmallStyle.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      headlineLarge: AppTypography.headlineLargeStyle.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      headlineMedium: AppTypography.headlineMediumStyle.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      headlineSmall: AppTypography.headlineSmallStyle.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      titleLarge: AppTypography.titleLargeStyle.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      titleMedium: AppTypography.titleMediumStyle.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      titleSmall: AppTypography.titleSmallStyle.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      bodyLarge: AppTypography.bodyLargeStyle.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      bodyMedium: AppTypography.bodyMediumStyle.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      bodySmall: AppTypography.bodySmallStyle.copyWith(
        color: AppColors.textSecondaryDark,
      ),
      labelLarge: AppTypography.labelLargeStyle.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      labelMedium: AppTypography.labelMediumStyle.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      labelSmall: AppTypography.labelSmallStyle.copyWith(
        color: AppColors.textSecondaryDark,
      ),
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.cardBackgroundDark,
    dividerColor: AppColors.borderDark,
  );
} 