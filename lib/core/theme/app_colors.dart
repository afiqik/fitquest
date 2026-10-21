import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color energeticOrange = Color(0xFFFF7A00);
  static const Color orangeGradientEnd = Color(0xFFE85D04);
  static const Color orangeLight = Color(0xFFFFB061);
  static const Color peachCream = Color(0xFFFFECDD);
  
  // Surfaces & Backgrounds
  static const Color warmWhite = Color(0xFFFAFAF8);
  static const Color darkBg = Color(0xFF171210);
  static const Color darkBgDeep = Color(0xFF0B0A09);
  
  // Text Colors
  static const Color ink = Color(0xFF1B1512);
  static const Color inkLight = Color(0xFFF7F3EF);
  
  // AI Signature
  static const Color aiBlue = Color(0xFF3B82F6);
  static const Color aiBlueLight = Color(0xFF93C0FF);
  static const Color aiBlueDark = Color(0xFF1D4ED8);
  
  // Status Colors
  static const Color successGreen = Color(0xFF16A34A);
  static const Color greenLight = Color(0xFF4ADE80);
  static const Color errorRed = Color(0xFFE5484D);
  
  // Glassmorphism Light Mode
  static Color glassBg(bool isDark) => isDark 
      ? Colors.white.withOpacity(0.07) 
      : Colors.white.withOpacity(0.62);
      
  static Color glassBorder(bool isDark) => isDark 
      ? Colors.white.withOpacity(0.14) 
      : Colors.white.withOpacity(0.85);

  static Color glassSheetBg(bool isDark) => isDark
      ? const Color(0xFF161210).withOpacity(0.88)
      : Colors.white.withOpacity(0.92);

  static Color mutedText(bool isDark) => isDark 
      ? const Color(0xFFF7F3EF).withOpacity(0.50) 
      : const Color(0xFF1B1512).withOpacity(0.50);

  static Color subtleText(bool isDark) => isDark 
      ? const Color(0xFFF7F3EF).withOpacity(0.35) 
      : const Color(0xFF1B1512).withOpacity(0.35);

  static Color cardShadow(bool isDark) => isDark
      ? Colors.black.withOpacity(0.45)
      : const Color(0xFFBE783C).withOpacity(0.12);

  static LinearGradient orangeGradient = const LinearGradient(
    colors: [energeticOrange, orangeGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient aiOrbGradient = const LinearGradient(
    colors: [aiBlueLight, aiBlue, aiBlueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
