import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryLight = Color(0xFFEC4899); // Pink-500
  static const Color primaryDark = Color(0xFFF472B6); // Pink-400

  // Secondary Colors
  static const Color secondaryLight = Color(0xFF8B5CF6); // Purple-500
  static const Color secondaryDark = Color(0xFFA78BFA); // Purple-400

  // Success Colors
  static const Color successLight = Color(0xFF10B981); // Emerald-500
  static const Color successDark = Color(0xFF34D399); // Emerald-400

  // Warning Colors
  static const Color warningLight = Color(0xFFF59E0B); // Amber-500
  static const Color warningDark = Color(0xFFFBBF24); // Amber-400

  // Error Colors
  static const Color errorLight = Color(0xFFEF4444); // Red-500
  static const Color errorDark = Color(0xFFF87171); // Red-400

  // LGBT Pride Flag Colors
  static const Color lgbtRed = Color(0xFFE40303); // Pride Red
  static const Color lgbtOrange = Color(0xFFFF8C00); // Pride Orange
  static const Color lgbtYellow = Color(0xFFFFED00); // Pride Yellow
  static const Color lgbtGreen = Color(0xFF008018); // Pride Green
  static const Color lgbtBlue = Color(0xFF0066FF); // Pride Blue
  static const Color lgbtPurple = Color(0xFF8B00FF); // Pride Purple

  // LGBT Gradient
  static const List<Color> lgbtGradient = [
    lgbtRed,
    lgbtOrange,
    lgbtYellow,
    lgbtGreen,
    lgbtBlue,
    lgbtPurple,
  ];

  // App Background Colors
  static const Color appBackground = Color(0xFF080912); // Main app background
  static const Color navbarBackground = Color(0xFF131725); // Navbar background

  // Card Background Colors
  static const Color cardBackgroundLight = Color(0xFFF8FAFC); // Slate-50
  static const Color cardBackgroundDark = Color(0xFF1E293B); // Slate-800

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF111827); // Gray-900
  static const Color textPrimaryDark = Color(0xFFF9FAFB); // Gray-100
  static const Color textSecondaryLight = Color(0xFF6B7280); // Gray-500
  static const Color textSecondaryDark = Color(0xFF9CA3AF); // Gray-400

  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB); // Gray-200
  static const Color borderDark = Color(0xFF374151); // Gray-700

  // Gradient Colors
  static const List<Color> gradientLight = [
    Color(0xFFEC4899), // Pink-500
    Color(0xFFF59E0B), // Amber-500
  ];

  static const List<Color> gradientDark = [
    Color(0xFF8B5CF6), // Purple-500
    Color(0xFF10B981), // Emerald-500
  ];

  // Status Gradients
  static const List<Color> gradientSuccess = [
    Color(0xFF10B981), // Emerald-500
    Color(0xFF34D399), // Emerald-400
  ];
  static const List<Color> gradientWarning = [
    Color(0xFFF59E0B), // Amber-500
    Color(0xFFFBBF24), // Amber-400
  ];
  static const List<Color> gradientError = [
    Color(0xFFEF4444), // Red-500
    Color(0xFFF87171), // Red-400
  ];
  static const List<Color> gradientInfo = [
    Color(0xFF3B82F6), // Blue-500
    Color(0xFF60A5FA), // Blue-400
  ];
} 