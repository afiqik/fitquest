import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ai_orb.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_chip.dart';
import '../../core/widgets/exercise_image.dart';
import '../../models/workout_plan.dart';
import '../../providers/app_state.dart';
import 'active_workout_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final ScheduledWorkoutDay workoutDay;

  const WorkoutDetailScreen({super.key, required this.workoutDay});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;

    final heroName = workoutDay.exercises.isNotEmpty ? workoutDay.exercises.first.name : 'stretch';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
      body: Stack(
        children: [
          // Hero Banner (exercise photo)
          SizedBox(
            height: 260,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ExerciseImage(
                  exerciseName: heroName,
                  borderRadius: BorderRadius.zero,
                  animate: true,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.45),
                        Colors.transparent,
                        Colors.black.withOpacity(0.35),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sliding Up Sheet Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 220),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161210) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workoutDay.title,
                    style: AppTextStyles.h1(isDark).copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 12),

                  // Metadata Chips Row
                  Row(
                    children: [
                      GlassChip(
                        isDark: isDark,
                        child: Text('${workoutDay.durationMinutes} min', style: AppTextStyles.caption(isDark)),
                      ),
                      const SizedBox(width: 8),
                      GlassChip(
                        isDark: isDark,
                        child: Text('${workoutDay.exercises.length} moves', style: AppTextStyles.caption(isDark)),
                      ),
                      const SizedBox(width: 8),
                      GlassChip(
                        isDark: isDark,
                        bgColor: AppColors.energeticOrange.withOpacity(0.14),
                        child: Text(
                          '~${workoutDay.estimatedCalories} kcal',
                          style: AppTextStyles.caption(isDark).copyWith(
                            color: AppColors.energeticOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Kenapa Workout Ini (AI Rationale) Card
                  GlassCard(
                    isDark: isDark,
                    color: AppColors.aiBlue.withOpacity(0.08),
                    borderColor: AppColors.aiBlue.withOpacity(0.22),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const AiOrb(size: 15),
                            const SizedBox(width: 8),
                            Text('WHY THIS WORKOUT', style: AppTextStyles.aiTag),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          workoutDay.aiRationale,
                          style: AppTextStyles.body(isDark).copyWith(
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'EXERCISE LIST',
                    style: AppTextStyles.mono(
                      isDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedText(isDark),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Exercise Items List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: workoutDay.exercises.length,
                    itemBuilder: (context, index) {
                      final ex = workoutDay.exercises[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: GestureDetector(
                          onTap: () => _showExercisePreview(context, ex.name, ex.meta, ex.targetMuscle, isDark),
                          child: GlassCard(
                          isDark: isDark,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ExerciseImage(
                                exerciseName: ex.name,
                                width: 72,
                                height: 56,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ex.name,
                                      style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 15.5),
                                    ),
                                    Text(
                                      ex.meta,
                                      style: AppTextStyles.muted(isDark).copyWith(fontSize: 12.5),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                ex.durationText,
                                style: AppTextStyles.mono(
                                  isDark,
                                  fontSize: 12,
                                  color: AppColors.mutedText(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Start Workout CTA
                  if (workoutDay.exercises.isNotEmpty)
                    GlassButton(
                      text: 'Start workout',
                      onPressed: () {
                        appState.startWorkout(workoutDay);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
                        );
                      },
                      variant: GlassButtonVariant.primaryOrange,
                    )
                  else
                    GlassCard(
                      isDark: isDark,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text('🧘', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Rest day — no exercises scheduled. Light stretching and hydration are recommended.',
                              style: AppTextStyles.body(isDark).copyWith(fontSize: 13.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Back button (top layer so it always receives taps)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: Material(
              color: Colors.black.withOpacity(0.35),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExercisePreview(
    BuildContext context,
    String name,
    String meta,
    String muscle,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161210) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.mutedText(isDark).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 3 / 2,
                child: ExerciseImage(
                  exerciseName: name,
                  animate: true,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              const SizedBox(height: 16),
              Text(name, style: AppTextStyles.h1(isDark).copyWith(fontSize: 22)),
              const SizedBox(height: 4),
              Text('$meta · $muscle', style: AppTextStyles.muted(isDark)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
