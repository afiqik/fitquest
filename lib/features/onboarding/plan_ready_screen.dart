import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ai_orb.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/app_state.dart';
import '../home/main_shell.dart';

class PlanReadyScreen extends StatelessWidget {
  const PlanReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;
    final plan = appState.activePlan;
    final profile = appState.profile;

    final stats = [
      {'k': 'Duration', 'v': '4 weeks'},
      {'k': 'Sessions / week', 'v': '${profile.commitDays} days'},
      {'k': 'Focus', 'v': profile.fitnessGoal},
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Generated Badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AiOrb(size: 16),
                  const SizedBox(width: 8),
                  Text('AI GENERATED', style: AppTextStyles.aiTag),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Your 4-week plan is ready',
                style: AppTextStyles.h1(isDark).copyWith(fontSize: 30),
              ),
              const SizedBox(height: 8),
              Text(
                plan?.rationale ?? 'Custom plan tailored for your ${profile.fitnessGoal} goal.',
                style: AppTextStyles.body(isDark).copyWith(
                  color: AppColors.mutedText(isDark),
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 20),

              // Stats Row
              Row(
                children: stats.map((s) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GlassCard(
                      isDark: isDark,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      child: Column(
                        children: [
                          Text(
                            s['v']!,
                            style: AppTextStyles.h3(isDark).copyWith(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s['k']!,
                            style: AppTextStyles.caption(isDark).copyWith(fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
              ),

              const SizedBox(height: 18),
              Text(
                'WEEK 1 SCHEDULE',
                style: AppTextStyles.mono(
                  isDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedText(isDark),
                ),
              ),
              const SizedBox(height: 10),

              // Week Schedule Preview
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: plan?.schedule.length ?? 0,
                  itemBuilder: (context, index) {
                    final day = plan!.schedule[index];
                    final isRest = day.state == 'rest';
                    final isToday = day.state == 'today';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: GlassCard(
                        isDark: isDark,
                        padding: const EdgeInsets.all(12),
                        borderColor: isToday ? AppColors.energeticOrange : null,
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isToday 
                                    ? AppColors.energeticOrange.withOpacity(0.18)
                                    : (isRest ? Colors.grey.withOpacity(0.1) : AppColors.aiBlue.withOpacity(0.14)),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    day.dayOfWeek,
                                    style: AppTextStyles.mono(isDark, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    day.dateNumber,
                                    style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    day.title,
                                    style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 15),
                                  ),
                                  Text(
                                    day.meta,
                                    style: AppTextStyles.muted(isDark).copyWith(fontSize: 12.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Enter FitQuest CTA
              GlassButton(
                text: 'Enter FitQuest',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainShell()),
                    (route) => false,
                  );
                },
                variant: GlassButtonVariant.darkInk,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
