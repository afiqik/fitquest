import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_chip.dart';
import '../../providers/app_state.dart';
import 'badge_unlocked_dialog.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;
    final badges = appState.badges;
    final unlockedCount = badges.where((b) => b.isUnlocked).length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppBackButton(isDark: isDark),
                  GlassChip(
                    isDark: isDark,
                    child: Text(
                      '$unlockedCount / ${badges.length} UNLOCKED',
                      style: AppTextStyles.mono(
                        isDark,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.energeticOrange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Achievements',
                style: AppTextStyles.h1(isDark).copyWith(fontSize: 32),
              ),
              const SizedBox(height: 4),
              Text(
                '24 badges recognizing your training consistency and milestones.',
                style: AppTextStyles.body(isDark).copyWith(
                  color: AppColors.mutedText(isDark),
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 20),

              // 24 Badges Grid
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: badges.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.95,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    return GlassCard(
                      isDark: isDark,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => BadgeUnlockedDialog(badge: badge),
                        );
                      },
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: badge.isUnlocked
                                  ? AppColors.energeticOrange.withOpacity(0.16)
                                  : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              badge.icon,
                              style: TextStyle(
                                fontSize: 26,
                                color: badge.isUnlocked ? null : Colors.grey.withOpacity(0.4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            badge.title,
                            style: AppTextStyles.bodySemibold(isDark).copyWith(
                              fontSize: 14.5,
                              color: badge.isUnlocked ? null : AppColors.mutedText(isDark),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            badge.description,
                            style: AppTextStyles.caption(isDark).copyWith(
                              fontSize: 11,
                              color: badge.isUnlocked ? AppColors.mutedText(isDark) : Colors.grey.withOpacity(0.4),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
