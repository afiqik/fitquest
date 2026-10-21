import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ai_orb.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/exercise_image.dart';
import '../../models/exercise_item.dart';
import '../../providers/app_state.dart';
import '../home/main_shell.dart';

class RevisedPlanScreen extends StatelessWidget {
  const RevisedPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;
    final rev = appState.latestRevision;

    final detection = rev?['detection'] as String? ?? 'AI detected a need to adjust training load.';
    final adjustment = rev?['adjustment'] as String? ?? 'Intensity and sets have been recalibrated for optimal recovery.';
    final revisedExercises = (rev?['revisedExercises'] as List<ExerciseItem>?) ?? [];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AiOrb(size: 16),
                  const SizedBox(width: 8),
                  Text('AI ADAPTIVE REVISION', style: AppTextStyles.aiTag),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                "This week's plan has been adjusted",
                style: AppTextStyles.h1(isDark).copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                'Your streak remains safe. There are no penalties for rest or schedule constraints.',
                style: AppTextStyles.body(isDark).copyWith(
                  color: AppColors.mutedText(isDark),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // AI Analysis Card
              GlassCard(
                isDark: isDark,
                color: AppColors.aiBlue.withOpacity(0.08),
                borderColor: AppColors.aiBlue.withOpacity(0.24),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detection,
                      style: AppTextStyles.bodySemibold(isDark).copyWith(
                        color: AppColors.aiBlue,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      adjustment,
                      style: AppTextStyles.body(isDark).copyWith(
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'REVISED EXERCISES',
                style: AppTextStyles.mono(
                  isDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedText(isDark),
                ),
              ),
              const SizedBox(height: 10),

              // Revised Exercises
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: revisedExercises.length,
                  itemBuilder: (context, index) {
                    final ex = revisedExercises[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: GlassCard(
                        isDark: isDark,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ExerciseImage(
                              exerciseName: ex.name,
                              width: 44,
                              height: 44,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.name,
                                    style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 15),
                                  ),
                                  Text(
                                    ex.meta,
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
              const SizedBox(height: 14),

              // Save & Return to Home
              GlassButton(
                text: 'Save New Plan',
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
