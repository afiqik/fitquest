import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class GlassDecorations {
  static BoxDecoration card({
    required bool isDark,
    double borderRadius = 24.0,
    Color? customBg,
    Color? customBorder,
    List<BoxShadow>? customShadow,
  }) {
    return BoxDecoration(
      color: customBg ?? AppColors.glassBg(isDark),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: customBorder ?? AppColors.glassBorder(isDark),
        width: 1.2,
      ),
      boxShadow: customShadow ?? [
        BoxShadow(
          color: AppColors.cardShadow(isDark),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  static Widget glassContainer({
    required Widget child,
    required bool isDark,
    double borderRadius = 24.0,
    double blurSigma = 22.0,
    Color? customBg,
    Color? customBorder,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: card(
            isDark: isDark,
            borderRadius: borderRadius,
            customBg: customBg,
            customBorder: customBorder,
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      content = Padding(padding: margin, child: content);
    }

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
