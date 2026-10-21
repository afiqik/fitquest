import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/app_state.dart';
import '../home/main_shell.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  const WorkoutSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;
    final p = appState.profile;

    final stats = [
      {'label': 'Total Time', 'val': '32 min', 'icon': '⏱️'},
      {'label': 'Completed Moves', 'val': '6 / 6', 'icon': '💪'},
      {'label': 'Calories Burned', 'val': '~410 kcal', 'icon': '🔥'},
      {'label': 'Streak Increased', 'val': '+1 day', 'icon': '🏅'},
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              // Celebratory Trophy Badge
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.orangeLight, AppColors.energeticOrange],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.energeticOrange.withOpacity(0.40),
                        blurRadius: 36,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text('🎉', style: TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  'Workout Completed!',
                  style: AppTextStyles.h1(isDark).copyWith(fontSize: 32),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Great job ${p.name}! Another step closer to your ${p.fitnessGoal} goal.',
                  style: AppTextStyles.body(isDark).copyWith(
                    color: AppColors.mutedText(isDark),
                    fontSize: 14.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // 4 Recap Metrics
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stats.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final s = stats[index];
                  return GlassCard(
                    isDark: isDark,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(s['icon']!, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s['label']!,
                                style: AppTextStyles.caption(isDark).copyWith(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s['val']!,
                          style: AppTextStyles.h2(isDark).copyWith(
                            fontSize: 18,
                            color: AppColors.energeticOrange,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Spacer(),

              // Return Home Button
              GlassButton(
                text: 'Back to Home',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainShell()),
                    (route) => false,
                  );
                },
                variant: GlassButtonVariant.darkInk,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
