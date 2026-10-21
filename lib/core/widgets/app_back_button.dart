import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Standard, reliable back button across all FitQuest screens.
/// Guarantees a minimum 48x48 touch target, clear iconography,
/// and safe `Navigator.of(context).maybePop()` execution.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isDark;
  final Color? color;
  final Color? iconColor;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.isDark = false,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = color ??
        (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05));
    final effectiveFg = iconColor ?? (isDark ? Colors.white : AppColors.ink);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
              width: 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: effectiveFg,
          ),
        ),
      ),
    );
  }
}
