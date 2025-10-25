import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFEC4899); // Pink-500 (default primary)
  static const Color primaryLight = Color(0xFFEC4899); // Pink-500
  static const Color primaryDark = Color(0xFFF472B6); // Pink-400

  // Secondary Colors
  static const Color secondary = Color(0xFF8B5CF6); // Purple-500
  static const Color secondaryLight = Color(0xFF8B5CF6); // Purple-500
  static const Color secondaryDark = Color(0xFFA78BFA); // Purple-400

  // Success Colors
  static const Color successLight = Color(0xFF10B981); // Emerald-500
  static const Color successDark = Color(0xFF34D399); // Emerald-400

  // Warning Colors
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color warningLight = Color(0xFFF59E0B); // Amber-500
  static const Color warningDark = Color(0xFFFBBF24); // Amber-400

  // Accent Colors
  static const Color accent = Color(0xFF8B5CF6); // Purple-500
  
  // Super Like Colors
  static const Color superLikeOrangeRed = Color(0xFFFF6B35); // Orange-red for super like
  static const Color superLikeOrange = Color(0xFFFF8C42); // Orange for super like
  static const Color superLikeGold = Color(0xFFFFD700); // Gold for super like
  
  // Image Filter Colors
  static const Color sepiaBrown = Color(0xFF8B4513); // Brown for sepia filter
  
  // Info Colors
  static const Color info = Color(0xFF3B82F6); // Blue-500

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
  
  // Lesbian Pride Flag Colors
  static const Color lesbianDarkOrange = Color(0xFFD62900);
  static const Color lesbianLightOrange = Color(0xFFFF9A56);
  static const Color lesbianWhite = Color(0xFFFFFFFF);
  static const Color lesbianPink = Color(0xFFD462A6);
  static const Color lesbianDarkPink = Color(0xFFA50062);
  
  // Gay/MLM Pride Flag Colors
  static const Color gayDarkBlue = Color(0xFF0038A8);
  static const Color gayBlue = Color(0xFF004CFF);
  static const Color gayLightBlue = Color(0xFF00A8FF);
  
  // Bisexual Pride Flag Colors
  static const Color biPink = Color(0xFFD70070);
  static const Color biPurple = Color(0xFF9C4F96);
  static const Color biBlue = Color(0xFF0038A8);
  
  // Pansexual Pride Flag Colors
  static const Color panPink = Color(0xFFFF1B8D);
  static const Color panBlue = Color(0xFF1BB3FF);
  
  // Asexual Pride Flag Colors
  static const Color aceBlack = Color(0xFF000000);
  static const Color aceGray = Color(0xFFA3A3A3);
  static const Color aceWhite = Color(0xFFFFFFFF);

  // App Background Colors
  static const Color appBackground = Color(0xFF080912); // Main app background
  static const Color navbarBackground = Color(0xFF131725); // Navbar background
  
  // Splash Screen Gradient Colors
  static const Color splashNavy = Color(0xFF1a1a2e);
  static const Color splashDarkNavy = Color(0xFF16213e);
  static const Color splashPurpleNavy = Color(0xFF0f3460);
  static const Color splashPurple = Color(0xFF533483);
  
  // Onboarding Gradient Colors
  static const Color onboardingBlack = Color(0xFF000000);
  static const Color onboardingDarkNavy = Color(0xFF0D0D1A);
  static const Color onboardingDarkPurple = Color(0xFF1A0D1A);
  static const Color onboardingDeepPurple = Color(0xFF2D1B2D);

  // Theme Background Colors
  static const Color backgroundLight = Color(0xFFF8F9FA); // Light background
  static const Color backgroundDark = Color(0xFF121212); // Dark background

  // Card Background Colors
  static const Color cardBackgroundLight = Color(0xFFF8FAFC); // Slate-50
  static const Color cardBackgroundDark = Color(0xFF1E293B); // Slate-800

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF111827); // Gray-900
  static const Color textPrimaryDark = Color(0xFFF9FAFB); // Gray-100
  static const Color textSecondaryLight = Color(0xFF6B7280); // Gray-500
  static const Color textSecondaryDark = Color(0xFF9CA3AF); // Gray-400
  
  // Semantic Color Tokens - UI States
  static const Color surfacePrimary = Color(0xFFFFFFFF); // White
  static const Color surfaceSecondary = Color(0xFFF8F9FA); // Light gray
  static const Color surfaceTertiary = Color(0xFFE9ECEF); // Medium gray
  
  // Interactive States - Enhanced with variants
  static const Color interactiveDefault = primaryLight; // Default interactive color
  static const Color interactiveHover = Color(0xFF7C3AED); // Purple-600
  static const Color interactivePressed = Color(0xFF6D28D9); // Purple-700
  static const Color interactiveDisabled = Color(0xFF9CA3AF); // Gray-400
  static const Color interactiveFocus = Color(0xFF8B5CF6); // Purple-500
  
  // Interactive State Variants - Hover
  static const Color interactiveHoverLight = Color(0xFF8B5CF6); // Purple-500
  static const Color interactiveHoverDark = Color(0xFF5B21B6); // Purple-800
  
  // Interactive State Variants - Pressed
  static const Color interactivePressedLight = Color(0xFF6D28D9); // Purple-700
  static const Color interactivePressedDark = Color(0xFF4C1D95); // Purple-900
  
  // Interactive State Variants - Disabled
  static const Color interactiveDisabledLight = Color(0xFFD1D5DB); // Gray-300
  static const Color interactiveDisabledDark = Color(0xFF6B7280); // Gray-500
  
  // Interactive State Variants - Focus
  static const Color interactiveFocusLight = Color(0xFF8B5CF6); // Purple-500
  static const Color interactiveFocusDark = Color(0xFF5B21B6); // Purple-800
  
  // Feedback States - Enhanced with variants
  static const Color feedbackSuccess = Color(0xFF10B981); // Emerald-500
  static const Color feedbackWarning = Color(0xFFF59E0B); // Amber-500
  static const Color feedbackError = Color(0xFFEF4444); // Red-500
  static const Color feedbackInfo = Color(0xFF3B82F6); // Blue-500
  
  // Feedback State Variants - Success
  static const Color feedbackSuccessLight = Color(0xFF34D399); // Emerald-400
  static const Color feedbackSuccessDark = Color(0xFF059669); // Emerald-600
  
  // Feedback State Variants - Warning
  static const Color feedbackWarningLight = Color(0xFFFBBF24); // Amber-400
  static const Color feedbackWarningDark = Color(0xFFD97706); // Amber-600
  
  // Feedback State Variants - Error
  static const Color feedbackErrorLight = Color(0xFFF87171); // Red-400
  static const Color feedbackErrorDark = Color(0xFFDC2626); // Red-600
  
  // Feedback State Variants - Info
  static const Color feedbackInfoLight = Color(0xFF60A5FA); // Blue-400
  static const Color feedbackInfoDark = Color(0xFF2563EB); // Blue-600
  
  // Background States
  static const Color backgroundOverlay = Color(0x80000000); // Black with 50% opacity
  static const Color backgroundModal = Color(0xFFFFFFFF); // White for modals
  static const Color backgroundTooltip = Color(0xFF1F2937); // Gray-800
  
  // Border States - Enhanced with variants
  static const Color borderDefault = Color(0xFFE5E7EB); // Gray-200
  static const Color borderHover = Color(0xFFD1D5DB); // Gray-300
  static const Color borderFocus = primaryLight; // Primary color
  static const Color borderError = feedbackError; // Error color
  
  // Border State Variants - Default
  static const Color borderDefaultLight = Color(0xFFF3F4F6); // Gray-100
  static const Color borderDefaultDark = Color(0xFF9CA3AF); // Gray-400
  
  // Border State Variants - Hover
  static const Color borderHoverLight = Color(0xFFE5E7EB); // Gray-200
  static const Color borderHoverDark = Color(0xFF6B7280); // Gray-500
  
  // Border State Variants - Focus
  static const Color borderFocusLight = Color(0xFF8B5CF6); // Purple-500
  static const Color borderFocusDark = Color(0xFF5B21B6); // Purple-800
  
  // Border State Variants - Error
  static const Color borderErrorLight = Color(0xFFF87171); // Red-400
  static const Color borderErrorDark = Color(0xFFDC2626); // Red-600
  
  // Text States
  static const Color textInteractive = primaryLight; // Interactive text
  static const Color textInteractiveHover = interactiveHover; // Hover state
  static const Color textDisabled = Color(0xFF9CA3AF); // Gray-400
  static const Color textPlaceholder = Color(0xFF6B7280); // Gray-500
  
  // LGBT Pride Colors - Semantic Tokens
  static const Color prideRed = Color(0xFFE70000); // Red
  static const Color prideOrange = Color(0xFFFF8C00); // Orange
  static const Color prideYellow = Color(0xFFFFD700); // Gold
  static const Color prideGreen = Color(0xFF00811F); // Green
  static const Color prideBlue = Color(0xFF004CFF); // Blue
  static const Color pridePurple = Color(0xFF760089); // Purple
  
  // Trans Pride Colors
  static const Color transBlue = Color(0xFF5BCEFA); // Light blue
  static const Color transPink = Color(0xFFF5A9B8); // Light pink
  static const Color transWhite = Color(0xFFFFFFFF); // White
  
  // Non-binary Pride Colors
  static const Color nonBinaryYellow = Color(0xFFFFF700); // Yellow
  static const Color nonBinaryWhite = Color(0xFFFFFFFF); // White
  static const Color nonBinaryPurple = Color(0xFF9C59D1); // Purple
  static const Color nonBinaryBlack = Color(0xFF2C2C2C); // Black
  
  // Additional UI Colors
  static const Color greyLight = Color(0xFFF3F4F6); // Gray-100
  static const Color greyMedium = Color(0xFFD1D5DB); // Gray-300

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

  // UI Surface Colors
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color border = Color(0xFFE5E7EB); // Gray-200

  // Background Colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF); // White
  static const Color backgroundSecondary = Color(0xFFF9FAFB); // Gray-50
  
  // Legacy color aliases for backward compatibility
  static const Color textPrimary = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
  // Backward compatibility aliases
  static const Color background = backgroundDark; // Default to dark background
  static const Color success = feedbackSuccess;
  static const Color error = feedbackError;
} 