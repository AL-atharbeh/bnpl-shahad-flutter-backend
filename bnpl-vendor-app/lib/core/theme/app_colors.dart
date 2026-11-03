import 'package:flutter/material.dart';

/// The customer app's palette, so a merchant and their customer see the same
/// brand on both sides of the counter.
class AppColors {
  static const Color primary = Color(0xFF065F46);
  static const Color primaryLight = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF064E3B);
  static const Color accent = Color(0xFF059669);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF0FDF4);
  static const Color canvas = Color(0xFFF8FAFC);

  static const Color textPrimary = Color(0xFF111827);
  static const Color heading = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  static const Color border = Color(0xFFE5E7EB);
  static const Color hairline = Color(0xFFF1F5F9);

  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color green50 = Color(0xFFECFDF5);
  static const Color green100 = Color(0xFFD1FAE5);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF065F46), Color(0xFF059669), Color(0xFF15803D)],
  );

  static const LinearGradient pillGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );
}
