import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings (Outfit)
  static TextStyle display(bool isDark) => GoogleFonts.outfit(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
    color: isDark ? AppColors.inkLight : AppColors.ink,
  );

  static TextStyle h1(bool isDark) => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: isDark ? AppColors.inkLight : AppColors.ink,
  );

  static TextStyle h2(bool isDark) => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: isDark ? AppColors.inkLight : AppColors.ink,
  );

  static TextStyle h3(bool isDark) => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: isDark ? AppColors.inkLight : AppColors.ink,
  );

  // Body Text (Outfit)
  static TextStyle body(bool isDark) => GoogleFonts.outfit(
    fontSize: 15.5,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: isDark ? AppColors.inkLight : AppColors.ink,
  );

  static TextStyle bodyMedium(bool isDark) => GoogleFonts.outfit(
    fontSize: 15.5,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: isDark ? AppColors.inkLight : AppColors.ink,
  );

  static TextStyle bodySemibold(bool isDark) => GoogleFonts.outfit(
    fontSize: 15.5,
    fontWeight: FontWeight.w600,
    color: isDark ? AppColors.inkLight : AppColors.ink,
  );

  static TextStyle muted(bool isDark) => GoogleFonts.outfit(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.mutedText(isDark),
  );

  static TextStyle caption(bool isDark) => GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedText(isDark),
  );

  // Technical & Numbers (JetBrains Mono)
  static TextStyle mono(bool isDark, {double fontSize = 12.5, FontWeight fontWeight = FontWeight.w500, Color? color, double? letterSpacing}) => GoogleFonts.jetBrainsMono(
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing ?? 0.2,
    color: color ?? (isDark ? AppColors.inkLight : AppColors.ink),
  );

  static TextStyle aiTag = GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    color: AppColors.aiBlue,
  );

  static TextStyle timer(bool isDark) => GoogleFonts.jetBrainsMono(
    fontSize: 58,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    color: isDark ? AppColors.inkLight : AppColors.ink,
  );
}
