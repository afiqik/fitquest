import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    required this.isDark,
    this.borderRadius = 22.0,
    this.padding = const EdgeInsets.all(18.0),
    this.margin,
    this.color,
    this.borderColor,
    this.borderWidth = 1.2,
    this.onTap,
    this.blur = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget current = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppColors.glassBg(isDark),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? AppColors.glassBorder(isDark),
              width: borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow(isDark),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      current = Padding(padding: margin!, child: current);
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.energeticOrange.withOpacity(0.12),
          highlightColor: AppColors.energeticOrange.withOpacity(0.06),
          child: current,
        ),
      );
    }

    return current;
  }
}
