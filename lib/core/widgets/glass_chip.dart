import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class GlassChip extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isDark;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? bgColor;
  final Color? borderColor;

  const GlassChip({
    super.key,
    required this.child,
    this.onTap,
    required this.isDark,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.borderRadius = 14.0,
    this.bgColor,
    this.borderColor,
  });

  factory GlassChip.text({
    required String text,
    required bool isDark,
    VoidCallback? onTap,
    Color? color,
    Color? textColor,
    Color? borderColor,
  }) {
    return GlassChip(
      onTap: onTap,
      isDark: isDark,
      bgColor: color,
      borderColor: borderColor,
      child: Text(
        text,
        style: AppTextStyles.mono(
          isDark,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: bgColor ?? (isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.60)),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? (isDark ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.85)),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }
}
