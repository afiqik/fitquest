import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_button.dart';
import '../../models/achievement_badge.dart';

class BadgeUnlockedDialog extends StatelessWidget {
  final AchievementBadge badge;

  const BadgeUnlockedDialog({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 26),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing Trophy Icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.energeticOrange.withOpacity(0.40),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.orangeLight, AppColors.energeticOrange],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badge.icon,
                      style: const TextStyle(fontSize: 44),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Text(
                'BADGE UNLOCKED',
                style: AppTextStyles.mono(
                  false,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.energeticOrange,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                badge.title,
                style: AppTextStyles.h1(false).copyWith(
                  fontSize: 26,
                  color: AppColors.ink,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                badge.description,
                style: AppTextStyles.body(false).copyWith(
                  color: AppColors.mutedText(false),
                  fontSize: 14.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              GlassButton(
                text: 'Awesome',
                onPressed: () => Navigator.pop(context),
                variant: GlassButtonVariant.darkInk,
                height: 52,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
