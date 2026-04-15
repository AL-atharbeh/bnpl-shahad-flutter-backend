import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Professional Dark Green Theme
  static const Color primary = Color(0xFF065F46); // Dark Green (Tailwind Green 800)
  static const Color primaryLight = Color(0xFF10B981); // Emerald 500
  static const Color primaryDark = Color(0xFF064E3B); // Darker Green (Tailwind Green 900)
  
  // Secondary Colors
  static const Color secondary = Color(0xFF15803D); // Green 700
  static const Color secondaryLight = Color(0xFF22C55E); // Green 500
  static const Color secondaryDark = Color(0xFF166534); // Green 800
  
  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surface = Color(0xFFF0FDF4); // Light Green Background
  static const Color surfaceDark = Color(0xFF1E293B);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color hintText = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);
  
  // Status Colors
  static const Color success = Color(0xFF059669); // Emerald 600
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue
  
  // Social Media Colors
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color facebookBlue = Color(0xFF1877F2);
  static const Color appleBlack = Color(0xFF000000);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary,
      Color(0xFF059669),
      secondary,
    ],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      background,
      surface,
    ],
  );
  
  // Financial Green Theme Gradients
  static const LinearGradient financialGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF065F46), 
      Color(0xFF059669),
      Color(0xFF15803D),
    ],
  );
  
  static const LinearGradient financialGreenGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFECFDF5), // Emerald 50
      Color(0xFFD1FAE5), // Emerald 100
      Color(0xFF10B981), // Emerald 500
    ],
  );
  
  // Shadow Colors
  static Color shadowLight = Colors.black.withOpacity(0.05);
  static Color shadowMedium = Colors.black.withOpacity(0.1);
  static Color shadowDark = Colors.black.withOpacity(0.2);
  
  // Financial Green Shadow Colors
  static Color financialGreenShadowLight = const Color(0xFF065F46).withOpacity(0.1);
  static Color financialGreenShadowMedium = const Color(0xFF065F46).withOpacity(0.2);
  static Color financialGreenShadowDark = const Color(0xFF065F46).withOpacity(0.3);
  
  // Overlay Colors
  static Color overlayLight = Colors.black.withOpacity(0.3);
  static Color overlayMedium = Colors.black.withOpacity(0.5);
  static Color overlayDark = Colors.black.withOpacity(0.7);
  
  // Additional Financial Green Shades
  static const Color financialGreen50 = Color(0xFFECFDF5);
  static const Color financialGreen100 = Color(0xFFD1FAE5);
  static const Color financialGreen200 = Color(0xFFA7F3D0);
  static const Color financialGreen300 = Color(0xFF6EE7B7);
  static const Color financialGreen400 = Color(0xFF34D399);
  static const Color financialGreen500 = Color(0xFF10B981);
  static const Color financialGreen600 = Color(0xFF059669);
  static const Color financialGreen700 = Color(0xFF047857);
  static const Color financialGreen800 = Color(0xFF065F46);
  static const Color financialGreen900 = Color(0xFF064E3B);
}
