import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';

/// Comprehensive LGBTinder App Theme
/// Supports both Light and Dark modes with LGBT+ pride color accents
class AppTheme {
  // ============================================================================
  // LIGHT THEME
  // ============================================================================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryLight,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight.withOpacity(0.1),
        onPrimaryContainer: AppColors.primaryLight,
        
        secondary: AppColors.secondaryLight,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryLight.withOpacity(0.1),
        onSecondaryContainer: AppColors.secondaryLight,
        
        tertiary: AppColors.accent,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.accent.withOpacity(0.1),
        onTertiaryContainer: AppColors.accent,
        
        error: AppColors.errorLight,
        onError: Colors.white,
        errorContainer: AppColors.errorLight.withOpacity(0.1),
        onErrorContainer: AppColors.errorLight,
        
        background: AppColors.backgroundLight,
        onBackground: AppColors.textPrimaryLight,
        
        surface: AppColors.cardBackgroundLight,
        onSurface: AppColors.textPrimaryLight,
        surfaceVariant: AppColors.surfaceSecondary,
        onSurfaceVariant: AppColors.textSecondaryLight,
        
        outline: AppColors.borderLight,
        outlineVariant: AppColors.borderDefaultLight,
        
        shadow: Colors.black.withOpacity(0.1),
        scrim: Colors.black.withOpacity(0.5),
        
        inverseSurface: AppColors.gray800,
        onInverseSurface: Colors.white,
        inversePrimary: AppColors.primaryDark,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: AppColors.backgroundLight,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLargeStyle.copyWith(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.cardBackgroundLight,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primaryLight.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.labelLargeStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.labelLargeStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: BorderSide(color: AppColors.primaryLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.labelLargeStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.errorLight),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.errorLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: AppTypography.bodyMediumStyle.copyWith(
          color: AppColors.textPlaceholder,
        ),
        labelStyle: AppTypography.bodyMediumStyle.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        floatingLabelStyle: AppTypography.bodySmallStyle.copyWith(
          color: AppColors.primaryLight,
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundLight,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textSecondaryLight,
        selectedLabelStyle: AppTypography.labelSmallStyle.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelSmallStyle,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceSecondary,
        selectedColor: AppColors.primaryLight.withOpacity(0.2),
        labelStyle: AppTypography.labelMediumStyle,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.backgroundLight,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: AppTypography.titleLargeStyle.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        contentTextStyle: AppTypography.bodyMediumStyle.copyWith(
          color: AppColors.textPrimaryLight,
        ),
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.backgroundLight,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: AppColors.textPrimaryLight,
        size: 24,
      ),
      
      // Text Theme
      textTheme: _buildTextTheme(AppColors.textPrimaryLight, AppColors.textSecondaryLight),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return AppColors.gray400;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.gray300;
        }),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
        linearTrackColor: AppColors.primaryLight.withOpacity(0.2),
        circularTrackColor: AppColors.primaryLight.withOpacity(0.2),
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryLight,
        inactiveTrackColor: AppColors.primaryLight.withOpacity(0.3),
        thumbColor: AppColors.primaryLight,
        overlayColor: AppColors.primaryLight.withOpacity(0.2),
      ),
    );
  }
  
  // ============================================================================
  // DARK THEME
  // ============================================================================
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: Colors.black,
        primaryContainer: AppColors.primaryDark.withOpacity(0.2),
        onPrimaryContainer: AppColors.primaryDark,
        
        secondary: AppColors.secondaryDark,
        onSecondary: Colors.black,
        secondaryContainer: AppColors.secondaryDark.withOpacity(0.2),
        onSecondaryContainer: AppColors.secondaryDark,
        
        tertiary: AppColors.accent,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.accent.withOpacity(0.2),
        onTertiaryContainer: AppColors.accent,
        
        error: AppColors.errorDark,
        onError: Colors.black,
        errorContainer: AppColors.errorDark.withOpacity(0.2),
        onErrorContainer: AppColors.errorDark,
        
        background: AppColors.backgroundDark,
        onBackground: AppColors.textPrimaryDark,
        
        surface: AppColors.cardBackgroundDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceVariant: AppColors.gray800,
        onSurfaceVariant: AppColors.textSecondaryDark,
        
        outline: AppColors.borderDark,
        outlineVariant: AppColors.borderDefaultDark,
        
        shadow: Colors.black.withOpacity(0.3),
        scrim: Colors.black.withOpacity(0.7),
        
        inverseSurface: AppColors.gray100,
        onInverseSurface: Colors.black,
        inversePrimary: AppColors.primaryLight,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: AppColors.backgroundDark,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLargeStyle.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.cardBackgroundDark,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.black,
          elevation: 2,
          shadowColor: AppColors.primaryDark.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.labelLargeStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.labelLargeStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: BorderSide(color: AppColors.primaryDark, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.labelLargeStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.errorDark),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.errorDark, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: AppTypography.bodyMediumStyle.copyWith(
          color: AppColors.textPlaceholder,
        ),
        labelStyle: AppTypography.bodyMediumStyle.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        floatingLabelStyle: AppTypography.bodySmallStyle.copyWith(
          color: AppColors.primaryDark,
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.black,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackgroundDark,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textSecondaryDark,
        selectedLabelStyle: AppTypography.labelSmallStyle.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelSmallStyle,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gray800,
        selectedColor: AppColors.primaryDark.withOpacity(0.3),
        labelStyle: AppTypography.labelMediumStyle,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.cardBackgroundDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: AppTypography.titleLargeStyle.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        contentTextStyle: AppTypography.bodyMediumStyle.copyWith(
          color: AppColors.textPrimaryDark,
        ),
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.cardBackgroundDark,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: AppColors.textPrimaryDark,
        size: 24,
      ),
      
      // Text Theme
      textTheme: _buildTextTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.black;
          }
          return AppColors.gray600;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryDark;
          }
          return AppColors.gray700;
        }),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryDark,
        linearTrackColor: AppColors.primaryDark.withOpacity(0.3),
        circularTrackColor: AppColors.primaryDark.withOpacity(0.3),
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryDark,
        inactiveTrackColor: AppColors.primaryDark.withOpacity(0.3),
        thumbColor: AppColors.primaryDark,
        overlayColor: AppColors.primaryDark.withOpacity(0.2),
      ),
    );
  }
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      displayLarge: AppTypography.displayLargeStyle.copyWith(color: primaryColor),
      displayMedium: AppTypography.displayMediumStyle.copyWith(color: primaryColor),
      displaySmall: AppTypography.displaySmallStyle.copyWith(color: primaryColor),
      headlineLarge: AppTypography.headlineLargeStyle.copyWith(color: primaryColor),
      headlineMedium: AppTypography.headlineMediumStyle.copyWith(color: primaryColor),
      headlineSmall: AppTypography.headlineSmallStyle.copyWith(color: primaryColor),
      titleLarge: AppTypography.titleLargeStyle.copyWith(color: primaryColor),
      titleMedium: AppTypography.titleMediumStyle.copyWith(color: primaryColor),
      titleSmall: AppTypography.titleSmallStyle.copyWith(color: primaryColor),
      bodyLarge: AppTypography.bodyLargeStyle.copyWith(color: primaryColor),
      bodyMedium: AppTypography.bodyMediumStyle.copyWith(color: primaryColor),
      bodySmall: AppTypography.bodySmallStyle.copyWith(color: secondaryColor),
      labelLarge: AppTypography.labelLargeStyle.copyWith(color: primaryColor),
      labelMedium: AppTypography.labelMediumStyle.copyWith(color: primaryColor),
      labelSmall: AppTypography.labelSmallStyle.copyWith(color: secondaryColor),
    );
  }
  
  // LGBT+ Pride Gradient
  static LinearGradient get prideGradient {
    return LinearGradient(
      colors: AppColors.lgbtGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  // Standard App Gradient (Light)
  static LinearGradient get appGradientLight {
    return LinearGradient(
      colors: AppColors.gradientLight,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  // Standard App Gradient (Dark)
  static LinearGradient get appGradientDark {
    return LinearGradient(
      colors: AppColors.gradientDark,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

