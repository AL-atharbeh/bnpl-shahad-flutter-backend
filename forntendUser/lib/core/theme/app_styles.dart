import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppStyles {
  // Text Styles
  static TextStyle get headlineLarge => GoogleFonts.changa(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get headlineMedium => GoogleFonts.changa(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get headlineSmall => GoogleFonts.changa(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get titleLarge => GoogleFonts.changa(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get titleMedium => GoogleFonts.changa(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get titleSmall => GoogleFonts.changa(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.mada(
    fontSize: 16,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.mada(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  static TextStyle get bodySmall => GoogleFonts.mada(
    fontSize: 12,
    color: AppColors.textHint,
    height: 1.3,
  );
  
  static TextStyle get caption => GoogleFonts.mada(
    fontSize: 12,
    color: AppColors.textSecondary,
    height: 1.2,
  );
  
  // Button Styles
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textLight,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    textStyle: GoogleFonts.changa(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );
  
  static ButtonStyle get secondaryButton => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: BorderSide(color: AppColors.primary),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    textStyle: GoogleFonts.changa(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );
  
  static ButtonStyle get textButton => TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: GoogleFonts.mada(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );
  
  // Input Styles
  static InputDecoration get inputDecoration => InputDecoration(
    filled: true,
    fillColor: AppColors.background,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.error),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: GoogleFonts.mada(
      fontSize: 16,
      color: AppColors.hintText,
    ),
  );
  
  // Card Styles
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.border),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowMedium,
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  // Financial Green Theme Card Styles
  static BoxDecoration get financialGreenCardDecoration => BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.financialGreen200),
    boxShadow: [
      BoxShadow(
        color: AppColors.financialGreenShadowLight,
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration get financialGreenElevatedCardDecoration => BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.financialGreenShadowMedium,
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  // Container Styles
  static BoxDecoration get primaryContainer => BoxDecoration(
    gradient: AppColors.financialGreenGradient,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: AppColors.financialGreenShadowMedium,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration get secondaryContainer => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.financialGreen200),
  );
  
  // Financial Green Theme Container Styles
  static BoxDecoration get financialGreenContainer => BoxDecoration(
    color: AppColors.financialGreen50,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.financialGreen200),
  );
  
  static BoxDecoration get financialGreenGradientContainer => BoxDecoration(
    gradient: AppColors.financialGreenGradientLight,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.financialGreen300),
  );
  
  // Divider Styles
  static Widget get divider => Container(
    height: 1,
    color: AppColors.border,
  );
  
  static Widget get thickDivider => Container(
    height: 2,
    color: AppColors.border,
  );
  
  // Financial Green Divider Styles
  static Widget get financialGreenDivider => Container(
    height: 1,
    color: AppColors.financialGreen200,
  );
  
  static Widget get financialGreenThickDivider => Container(
    height: 2,
    color: AppColors.financialGreen300,
  );
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
}
