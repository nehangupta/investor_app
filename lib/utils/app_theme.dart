// ============================================================
// FILE: lib/utils/app_theme.dart
// PURPOSE: Central place for ALL colors and theme settings.
//          Never hardcode colors in widgets — always use these.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// All colors in one place
class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF071A2C); // darkest — scaffold bg
  static const Color surface    = Color(0xFF0F2D4A); // slightly lighter — input bg
  static const Color cardBg     = Color(0xFF112940); // card background
  static const Color divider    = Color(0xFF1E3A5F); // borders/dividers
  static const Color chipBg     = Color(0xFF1A3A5C); // tag/chip background

  // Brand colors
  static const Color primary    = Color(0xFF0A2342); // deep navy
  static const Color accent     = Color(0xFF00C2FF); // cyan — main CTA color
  static const Color gold       = Color(0xFFFFB800); // gold — interests star

  // Risk level colors
  static const Color lowRisk    = Color(0xFF00C896); // green
  static const Color mediumRisk = Color(0xFFFFB800); // amber
  static const Color highRisk   = Color(0xFFFF4D6D); // red

  // Status colors
  static const Color openStatus   = Color(0xFF00C896); // green
  static const Color closedStatus = Color(0xFF8BAFD1); // muted blue

  // Text
  static const Color textPrimary   = Color(0xFFE8F0FE); // white-ish
  static const Color textSecondary = Color(0xFF8BAFD1); // muted blue
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,

      colorScheme: const ColorScheme.dark(
        primary:    AppColors.accent,
        secondary:  AppColors.gold,
        surface:    AppColors.surface,
        background: AppColors.background,
      ),

      // All text styles use Inter font
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
        bodySmall: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // Search bar / text field style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
        hintStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Primary button style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
          elevation: 0,
        ),
      ),
    );
  }
}
