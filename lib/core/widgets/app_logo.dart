import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Modern branded FitQuest App Logo with AI energy glow & squircle framing.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showGlow;
  final bool animateGlow;
  final VoidCallback? onTap;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showGlow = true,
    this.animateGlow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(size * 0.24);

    Widget logoImage = ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        'assets/images/fitquest_logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback vector representation if asset not loaded
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1410), Color(0xFF0D0A08)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.energeticOrange.withOpacity(0.4),
                width: size * 0.025,
              ),
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.energeticOrange, AppColors.aiBlueLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Icon(
                  Icons.fitness_center_rounded,
                  size: size * 0.52,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );

    Widget content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.energeticOrange.withOpacity(0.35),
                  blurRadius: size * 0.35,
                  offset: Offset(0, size * 0.12),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: AppColors.aiBlue.withOpacity(0.20),
                  blurRadius: size * 0.40,
                  offset: Offset(-size * 0.08, -size * 0.08),
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: logoImage,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
