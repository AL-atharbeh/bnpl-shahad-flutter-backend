import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Changa Font - For Headlines and Titles
  static TextStyle get changaH1 => GoogleFonts.changa(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get changaH2 => GoogleFonts.changa(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get changaH3 => GoogleFonts.changa(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get changaH4 => GoogleFonts.changa(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get changaH5 => GoogleFonts.changa(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get changaH6 => GoogleFonts.changa(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  // Mada Font - For Body Text and Labels
  static TextStyle get madaBodyLarge => GoogleFonts.mada(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get madaBodyMedium => GoogleFonts.mada(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get madaBodySmall => GoogleFonts.mada(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get madaLabelLarge => GoogleFonts.mada(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get madaLabelMedium => GoogleFonts.mada(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get madaLabelSmall => GoogleFonts.mada(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textHint,
        height: 1.3,
      );

  // Specialized Styles
  static TextStyle get madaCaption => GoogleFonts.mada(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textHint,
        height: 1.3,
      );

  static TextStyle get madaButton => GoogleFonts.mada(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get madaButtonSmall => GoogleFonts.mada(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.2,
      );

  static TextStyle get madaHint => GoogleFonts.mada(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
        height: 1.4,
      );

  // Dark Theme Variants
  static TextStyle get changaH1Dark => changaH1.copyWith(color: Colors.white);
  static TextStyle get changaH2Dark => changaH2.copyWith(color: Colors.white);
  static TextStyle get changaH3Dark => changaH3.copyWith(color: Colors.white);
  static TextStyle get changaH4Dark => changaH4.copyWith(color: Colors.white);
  static TextStyle get changaH5Dark => changaH5.copyWith(color: Colors.white);
  static TextStyle get changaH6Dark => changaH6.copyWith(color: Colors.white);

  static TextStyle get madaBodyLargeDark => madaBodyLarge.copyWith(color: Colors.white);
  static TextStyle get madaBodyMediumDark => madaBodyMedium.copyWith(color: Colors.white);
  static TextStyle get madaBodySmallDark => madaBodySmall.copyWith(color: Colors.white70);
  static TextStyle get madaLabelLargeDark => madaLabelLarge.copyWith(color: Colors.white);
  static TextStyle get madaLabelMediumDark => madaLabelMedium.copyWith(color: Colors.white70);
  static TextStyle get madaLabelSmallDark => madaLabelSmall.copyWith(color: Colors.white60);
  static TextStyle get madaCaptionDark => madaCaption.copyWith(color: Colors.white60);
  static TextStyle get madaHintDark => madaHint.copyWith(color: Colors.white60);

  // Primary Color Variants
  static TextStyle get changaH1Primary => changaH1.copyWith(color: AppColors.primary);
  static TextStyle get changaH2Primary => changaH2.copyWith(color: AppColors.primary);
  static TextStyle get changaH3Primary => changaH3.copyWith(color: AppColors.primary);
  static TextStyle get changaH4Primary => changaH4.copyWith(color: AppColors.primary);
  static TextStyle get changaH5Primary => changaH5.copyWith(color: AppColors.primary);
  static TextStyle get changaH6Primary => changaH6.copyWith(color: AppColors.primary);

  static TextStyle get madaBodyPrimary => madaBodyMedium.copyWith(color: AppColors.primary);
  static TextStyle get madaLabelPrimary => madaLabelMedium.copyWith(color: AppColors.primary);
}
