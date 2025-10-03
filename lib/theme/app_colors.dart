import 'package:flutter/material.dart';

/// Application-wide color definitions
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6B46C1); // Purple
  static const Color secondary = Color(0xFFE53E3E); // Red
  static const Color accent = Color(0xFF38A169); // Green
  
  // Status Colors
  static const Color success = Color(0xFF48BB78); // Success green
  static const Color warning = Color(0xFFED8936); // Warning orange
  static const Color error = Color(0xFFE53E3E); // Error red
  static const Color info = Color(0xFF3182CE); // Info blue
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray50 = Color(0xFFF7FAFC);
  static const Color gray100 = Color(0xFFEDF2F7);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E0);
  static const Color gray400 = Color(0xFFA0AEC0);
  static const Color gray500 = Color(0xFF718096);
  static const Color gray600 = Color(0xFF4A5568);
  static const Color gray700 = Color(0xFF2D3748);
  static const Color gray800 = Color(0xFF1A202C);
  static const Color gray900 = Color(0xFF171923);
  
  // Background Colors
  static const Color appBackground = Color(0xFF1A202C); // Dark gray
  static const Color navbarBackground = Color(0xFF2D3748); // Gray700
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0AEC0); // Gray400
  static const Color textDisabled = Color(0xFF718096); // Gray500
  
  // Border Colors
  static const Color borderPrimary = Color(0xFF4A5568); // Gray600
  static const Color borderSecondary = Color(0xFF718096); // Gray500
  
  // Gradient Colors
  static const Color gradientStart = Color(0xFF6B46C1); // Primary
  static const Color gradientEnd = Color(0xFFE53E3E); // Secondary
  
  // Social Colors
  static const Color facebook = Color(0xFF1877F2);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color instagram = Color(0xFFE4405F);
  
  // Material Design Colors
  static const Color red = Color(0xFFE53E3E);
  static const Color orange = Color(0xFFED8936);
  static const Color yellow = Color(0xFFF6E05E);
  static const Color green = Color(0xFF48BB78);
  static const Color teal = Color(0xFF38B2AC);
  static const Color blue = Color(0xFF3182CE);
  static const Color cyan = Color(0xFF0BC5EA);
  static const Color purple = Color(0xFF805AD5);
  static const Color pink = Color(0xFFD53F8C);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF171923); // Gray900
  static const Color darkSurface = Color(0xFF1A202C); // AppBackground
  static const Color darkOnSurface = Color(0xFFE2E8F0); // Gray200
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFFFFFF); // White
  static const Color lightSurface = Color(0xFFF7FAFC); // Gray50
  static const Color lightOnSurface = Color(0xFF2D3748); // Gray700
  
  // Helper methods
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  static Color blendColors(Color color1, Color color2, double factor) {
    return Color.lerp(color1, color2, factor) ?? color1;
  }
  
  static MaterialColor toMaterialColor(Color color) {
    final Map<int, Color> shades = {
      50: color.withOpacity(0.1),
      100: color.withOpacity(0.2),
      200: color.withOpacity(0.3),
      300: color.withOpacity(0.4),
      400: color.withOpacity(0.5),
      500: color,
      600: color.withOpacity(0.7),
      700: color.withOpacity(0.8),
      800: color.withOpacity(0.9),
      900: color.withOpacity(1.0),
    };
    
    return MaterialColor(color.value, shades);
  }
}
