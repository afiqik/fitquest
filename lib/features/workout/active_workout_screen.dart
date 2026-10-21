import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/circular_timer.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_chip.dart';
import '../../core/widgets/exercise_image.dart';
import '../../providers/app_state.dart';
import 'incomplete_feedback_screen.dart';
import 'workout_summary_screen.dart';

class ActiveWorkoutScreen extends StatelessWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;
    final currentDay = appState.currentSessionDay;
    final exercises = currentDay?.exercises ?? [];
    final currentIdx = appState.currentExerciseIndex;

    if (exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Center(
          child: Text('No exercises scheduled.', style: AppTextStyles.body(isDark)),
        ),
      );
    }

    final safeIdx = currentIdx.clamp(0, exercises.length - 1);
    final curEx = exercises[safeIdx];
    final nextEx = safeIdx < exercises.length - 1 ? exercises[safeIdx + 1].name : 'Finished';
    final isLastExercise = safeIdx == exercises.length - 1;

    // Check if workout completed naturally
    if (!appState.isWorkoutActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WorkoutSummaryScreen()),
        );
      });
    }

    void openQuitFlow() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const IncompleteFeedbackScreen()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) openQuitFlow();
      },
      child: Scaffold(
      backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
              child: Column(
                children: [
                  // Top Navigation Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GlassChip(
                        isDark: isDark,
                        onTap: openQuitFlow,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Quit',
                          style: AppTextStyles.bodySemibold(isDark).copyWith(
                            fontSize: 13.5,
                            color: AppColors.errorRed,
                          ),
                        ),
                      ),
                      Text(
                        '${(safeIdx + 1).toString().padLeft(2, '0')} / ${exercises.length.toString().padLeft(2, '0')}',
                        style: AppTextStyles.mono(
                          isDark,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mutedText(isDark),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Exercise demonstration photo (animated start/end position)
                  Expanded(
                    child: ExerciseImage(
                      exerciseName: curEx.name,
                      width: double.infinity,
                      animate: appState.isPlaying,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Circular Timer Ring
                  CircularTimer(
                    size: 150,
                    totalSeconds: curEx.durationSeconds,
                    remainingSeconds: appState.remainingSeconds,
                    statusText: 'SET ${appState.currentSet} / ${curEx.sets}',
                    isResting: false,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),

                  // Exercise Name & Metadata
                  Text(
                    curEx.name,
                    style: AppTextStyles.h1(isDark).copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    curEx.meta,
                    style: AppTextStyles.body(isDark).copyWith(
                      color: AppColors.mutedText(isDark),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Next Exercise Pill
                  GlassCard(
                    isDark: isDark,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      'Next: $nextEx',
                      style: AppTextStyles.mono(isDark, fontSize: 13),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Controls
                  Row(
                    children: [
                      // Play / Pause Button
                      GlassChip(
                        isDark: isDark,
                        onTap: () => appState.togglePlayPause(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        child: Icon(
                          appState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 28,
                          color: isDark ? Colors.white : AppColors.ink,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Next / Finish Exercise CTA
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (isLastExercise) {
                              appState.finishWorkout(completed: true);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const WorkoutSummaryScreen()),
                              );
                            } else {
                              appState.nextExerciseManual();
                            }
                          },
                          child: Container(
                            height: 62,
                            decoration: BoxDecoration(
                              color: isLastExercise ? AppColors.energeticOrange : AppColors.ink,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (isLastExercise ? AppColors.energeticOrange : AppColors.ink).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isLastExercise ? 'Finish Workout' : 'Next Exercise',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // Rest Overlay Mode (When timer triggers rest period)
          if (appState.isResting)
            Container(
              color: Colors.black.withOpacity(0.85),
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'REST',
                      style: AppTextStyles.mono(
                        false,
                        fontSize: 14,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.aiBlueLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CircularTimer(
                      size: 200,
                      totalSeconds: 30,
                      remainingSeconds: appState.restSeconds,
                      statusText: 'SECONDS',
                      isResting: true,
                      isDark: true,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Next: ${curEx.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      curEx.meta,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => appState.addRestTime(),
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                '+15s',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => appState.skipRest(),
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.energeticOrange,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.energeticOrange.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Skip rest',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
    );
  }
}
