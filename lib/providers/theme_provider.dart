import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.dark;
  bool _isSystemTheme = false;
  
  ThemeMode get themeMode => _themeMode;
  bool get isSystemTheme => _isSystemTheme;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.dark.index; // Default to dark mode
      _themeMode = ThemeMode.values[themeIndex];
      _isSystemTheme = _themeMode == ThemeMode.system;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      _isSystemTheme = mode == ThemeMode.system;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
  
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
  
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
  
  // Light theme
  ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        titleTextStyle: AppTypography.h4.copyWith(
          color: AppColors.textPrimaryLight,
        ),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: AppColors.backgroundLight,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackgroundLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackgroundLight,
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
        labelStyle: AppTypography.body1.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        hintStyle: AppTypography.body1.copyWith(
          color: AppColors.textSecondaryLight,
        ),
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
          color: AppColors.textSecondaryLight,
        ),
        labelSmall: AppTypography.labelSmallStyle.copyWith(
          color: AppColors.textSecondaryLight,
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.cardBackgroundLight,
        background: AppColors.backgroundLight,
        error: AppColors.errorLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onBackground: AppColors.textPrimaryLight,
        onError: Colors.white,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
  
  // Dark theme
  ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.appBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.appBackground,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        titleTextStyle: AppTypography.h4.copyWith(
          color: AppColors.textPrimaryDark,
        ),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: AppColors.appBackground,
      ),
      cardTheme: CardThemeData(
        color: AppColors.navbarBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.navbarBackground,
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
          borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        labelStyle: AppTypography.body1.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        hintStyle: AppTypography.body1.copyWith(
          color: AppColors.textSecondaryDark,
        ),
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
          color: AppColors.textSecondaryDark,
        ),
        labelSmall: AppTypography.labelSmallStyle.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.navbarBackground,
        background: AppColors.appBackground,
        error: AppColors.errorLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
        onBackground: AppColors.textPrimaryDark,
        onError: Colors.white,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
