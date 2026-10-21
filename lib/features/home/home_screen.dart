import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ai_orb.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_chip.dart';
import '../../core/widgets/exercise_image.dart';
import '../../providers/app_state.dart';
import '../workout/workout_detail_screen.dart';
import '../workout/active_workout_screen.dart';
import '../nutrition/food_scan_screen.dart';
import '../achievements/achievements_screen.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;
  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;
    final profile = appState.profile;
    final plan = appState.activePlan;
    final today = plan?.todayWorkout;

    final initial = profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'A';

    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Mon, 7 = Sun
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: currentWeekday - 1));
    final dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final barDays = List.generate(7, (i) {
      final dayStart = monday.add(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));
      final sessions = appState.workoutHistory.where((s) {
        return s.completedAt.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
            s.completedAt.isBefore(dayEnd);
      }).toList();

      final isCurrentDay = (i + 1) == currentWeekday;
      double heightRatio = 0.0;
      if (sessions.isNotEmpty) {
        final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + (s.durationSeconds ~/ 60));
        heightRatio = (totalMinutes / 45.0).clamp(0.25, 1.0);
      } else if (isCurrentDay) {
        heightRatio = 0.08;
      }

      return {
        'd': dayLetters[i],
        'h': heightRatio,
        'active': isCurrentDay,
        'count': sessions.length,
      };
    });

    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning,'
        : (hour < 17 ? 'Good afternoon,' : 'Good evening,');

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Greeting & Avatar Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: AppTextStyles.muted(isDark).copyWith(fontSize: 14),
                        ),
                        Text(
                          profile.name,
                          style: AppTextStyles.h1(isDark).copyWith(fontSize: 28),
                        ),
                      ],
                    ),
                  ),
                  // Dark/Light Theme Switch
                  GlassChip(
                    isDark: isDark,
                    onTap: () => appState.toggleTheme(),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Text(
                      isDark ? '☀️' : '🌙',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // User Avatar
                  GestureDetector(
                    onTap: () => onNavigateTab?.call(4), // Go to Profile
                    child: Builder(
                      builder: (context) {
                        final hasPhoto = profile.photoPath != null &&
                            profile.photoPath!.isNotEmpty &&
                            File(profile.photoPath!).existsSync();
                        return Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: hasPhoto
                                ? null
                                : const LinearGradient(
                                    colors: [AppColors.orangeLight, AppColors.energeticOrange],
                                  ),
                            border: Border.all(color: AppColors.energeticOrange, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.energeticOrange.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: hasPhoto
                                ? Image.file(
                                    File(profile.photoPath!),
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Today's AI Pick Card
              GlassCard(
                isDark: isDark,
                onTap: () {
                  if (today != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutDetailScreen(workoutDay: today),
                      ),
                    );
                  }
                },
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AiOrb(size: 16),
                        const SizedBox(width: 8),
                        Text('TODAY · AI PICK', style: AppTextStyles.aiTag),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      today?.title ?? 'Fat-Burn Circuit',
                      style: AppTextStyles.h1(isDark).copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      today?.aiRationale ?? 'Selected for BMI ${profile.bmi.toStringAsFixed(1)} + ${profile.fitnessGoal} goal. Moderate intensity, joint-friendly.',
                      style: AppTextStyles.body(isDark).copyWith(
                        color: AppColors.mutedText(isDark),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${today?.durationMinutes ?? 32} MIN',
                          style: AppTextStyles.mono(isDark, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text('·', style: AppTextStyles.mono(isDark, color: Colors.grey)),
                        Text(
                          '${today?.exercises.length ?? 6} MOVES',
                          style: AppTextStyles.mono(isDark, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text('·', style: AppTextStyles.mono(isDark, color: Colors.grey)),
                        Text(
                          '~${today?.estimatedCalories ?? 410} KCAL',
                          style: AppTextStyles.mono(isDark, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    if (today != null && today.exercises.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 52,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: today.exercises.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final ex = today.exercises[i];
                            return ExerciseImage(
                              exerciseName: ex.name,
                              width: 52,
                              height: 52,
                              borderRadius: BorderRadius.circular(12),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // Start Workout Button
                    GestureDetector(
                      onTap: () {
                        if (today != null) {
                           appState.startWorkout(today);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
                          );
                        }
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.energeticOrange,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.energeticOrange.withOpacity(0.38),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Start workout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Quick Actions Row (Scan Food & Schedule)
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FoodScanScreen()),
                        );
                      },
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.energeticOrange.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Text('◎', style: TextStyle(fontSize: 18, color: AppColors.energeticOrange)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Scan food',
                            style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 15.5),
                          ),
                          Text(
                            'AI calorie calculation',
                            style: AppTextStyles.caption(isDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      isDark: isDark,
                      onTap: () => onNavigateTab?.call(1), // Go to Schedule tab
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.aiBlue.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Text('▤', style: TextStyle(fontSize: 18, color: AppColors.aiBlue)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Schedule',
                            style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 15.5),
                          ),
                          Text(
                            '4-week plan',
                            style: AppTextStyles.caption(isDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Weekly Progress Bar Chart Card
              GlassCard(
                isDark: isDark,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'This week',
                            style: AppTextStyles.h3(isDark).copyWith(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => onNavigateTab?.call(3), // Progress & History tab
                          child: const Text(
                            'History ›',
                            style: TextStyle(
                              color: AppColors.energeticOrange,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: barDays.map((b) {
                          final h = b['h'] as double;
                          final active = b['active'] as bool;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 28,
                                height: 55 * h,
                                decoration: BoxDecoration(
                                  color: h == 0
                                      ? (isDark ? Colors.white.withOpacity(0.06) : AppColors.ink.withOpacity(0.08))
                                      : (active ? AppColors.energeticOrange : AppColors.energeticOrange.withOpacity(0.35)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                b['d'] as String,
                                style: AppTextStyles.mono(
                                  isDark,
                                  fontSize: 11,
                                  color: AppColors.mutedText(isDark),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Streak Card
              GlassCard(
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                  );
                },
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.orangeLight, AppColors.energeticOrange],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🏅', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${profile.streakDays}-day streak active',
                            style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 15.5),
                          ),
                          Text(
                            'Maintain your daily workouts for the Consistency badge.',
                            style: AppTextStyles.caption(isDark),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.mutedText(isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
