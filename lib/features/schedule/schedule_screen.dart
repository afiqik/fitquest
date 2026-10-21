import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_chip.dart';
import '../../core/widgets/exercise_image.dart';
import '../../providers/app_state.dart';
import '../workout/workout_detail_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedWeek = 1;

  String _getProgressiveTitle(String baseTitle, int week) {
    if (week == 1) return baseTitle;
    if (baseTitle.toLowerCase().contains('rest')) return baseTitle;
    switch (week) {
      case 2:
        return '$baseTitle II';
      case 3:
        return '$baseTitle III';
      case 4:
        return '$baseTitle IV';
      default:
        return baseTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;
    final plan = appState.activePlan;
    final baseSchedule = plan?.schedule ?? [];
    final currentWeek = plan?.currentWeek ?? 1;

    final startDay = (_selectedWeek - 1) * 7 + 1;
    final endDay = _selectedWeek * 7;

    // Dynamically build the 7-day schedule for the selected week with accurate date numbers (1-7, 8-14, 15-21, 22-28)
    final weekSchedule = List.generate(baseSchedule.length, (index) {
      final baseDay = baseSchedule[index];
      final dateNumber = '${startDay + index}';
      final title = _getProgressiveTitle(baseDay.title, _selectedWeek);

      String state;
      if (_selectedWeek == currentWeek) {
        state = baseDay.state;
      } else if (_selectedWeek < currentWeek) {
        state = baseDay.state == 'rest' ? 'rest' : 'done';
      } else {
        state = baseDay.state == 'rest' ? 'rest' : 'next';
      }

      return baseDay.copyWith(
        dateNumber: dateNumber,
        title: title,
        state: state,
      );
    });

    final activeWorkoutDays = weekSchedule.where((d) => d.state != 'rest').toList();
    final completedCount = weekSchedule.where((d) => d.state == 'done').length;
    final totalSessions = activeWorkoutDays.isNotEmpty ? activeWorkoutDays.length : 1;
    final pct = (completedCount / totalSessions).clamp(0.0, 1.0);
    final pctString = '${(pct * 100).round()}%';

    String progressSubtitle;
    if (_selectedWeek == currentWeek) {
      progressSubtitle = completedCount == totalSessions && totalSessions > 0
          ? "Awesome! You hit all planned sessions."
          : "Stay on track for this week's goal.";
    } else if (_selectedWeek < currentWeek) {
      progressSubtitle = "Completed! Target achieved for Week $_selectedWeek.";
    } else {
      progressSubtitle = "Upcoming week · Days $startDay–$endDay scheduled.";
    }

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
              Text(
                'Schedule',
                style: AppTextStyles.h1(isDark).copyWith(fontSize: 32),
              ),
              const SizedBox(height: 4),
              Text(
                'AI-generated · adapts to feedback & recovery',
                style: AppTextStyles.body(isDark).copyWith(
                  color: AppColors.mutedText(isDark),
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 16),

              // Weeks Selector Chips with explicit date ranges (1–7, 8–14, 15–21, 22–28)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(4, (index) {
                    final weekNum = index + 1;
                    final isSelected = _selectedWeek == weekNum;
                    final wStart = (weekNum - 1) * 7 + 1;
                    final wEnd = weekNum * 7;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GlassChip(
                        isDark: isDark,
                        onTap: () => setState(() => _selectedWeek = weekNum),
                        bgColor: isSelected ? AppColors.energeticOrange : null,
                        child: Text(
                          'Week $weekNum ($wStart–$wEnd)',
                          style: AppTextStyles.bodySemibold(isDark).copyWith(
                            fontSize: 13.5,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),

              // Weekly Progress Ring Summary Card
              GlassCard(
                isDark: isDark,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$completedCount of $totalSessions sessions completed',
                            style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            progressSubtitle,
                            style: AppTextStyles.muted(isDark).copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.energeticOrange.withOpacity(0.14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        pctString,
                        style: AppTextStyles.mono(
                          isDark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.energeticOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 7-day Schedule List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: weekSchedule.length,
                itemBuilder: (context, index) {
                  final day = weekSchedule[index];
                  final isToday = day.state == 'today';
                  final isDone = day.state == 'done';
                  final isRest = day.state == 'rest';

                  Color badgeBg;
                  Color badgeFg;
                  String badgeText;

                  if (isDone) {
                    badgeBg = AppColors.greenLight.withOpacity(0.18);
                    badgeFg = AppColors.successGreen;
                    badgeText = 'DONE';
                  } else if (isToday) {
                    badgeBg = AppColors.energeticOrange.withOpacity(0.16);
                    badgeFg = AppColors.energeticOrange;
                    badgeText = 'TODAY';
                  } else if (isRest) {
                    badgeBg = Colors.grey.withOpacity(0.12);
                    badgeFg = AppColors.mutedText(isDark);
                    badgeText = 'REST';
                  } else {
                    badgeBg = AppColors.aiBlue.withOpacity(0.14);
                    badgeFg = AppColors.aiBlue;
                    badgeText = 'UPCOMING';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: GlassCard(
                      isDark: isDark,
                      borderColor: isToday ? AppColors.energeticOrange : null,
                      onTap: () {
                        if (!isRest) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkoutDetailScreen(workoutDay: day),
                            ),
                          );
                        }
                      },
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // Day/Date badge with real dynamic dateNumber (1-7, 8-14, 15-21, 22-28)
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isToday 
                                  ? AppColors.energeticOrange
                                  : (isDone 
                                      ? AppColors.greenLight.withOpacity(0.2) 
                                      : (isRest ? Colors.grey.withOpacity(0.1) : AppColors.aiBlue.withOpacity(0.14))),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  day.dayOfWeek,
                                  style: AppTextStyles.mono(
                                    isDark,
                                    fontSize: 10.5,
                                    color: isToday ? Colors.white : null,
                                  ),
                                ),
                                Text(
                                  day.dateNumber,
                                  style: AppTextStyles.bodySemibold(isDark).copyWith(
                                    fontSize: 15,
                                    color: isToday ? Colors.white : null,
                                  ),
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
                                  style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 15.5),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  day.meta,
                                  style: AppTextStyles.muted(isDark).copyWith(fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                          if (!isRest && day.exercises.isNotEmpty) ...[
                            ExerciseImage(
                              exerciseName: day.exercises.first.name,
                              width: 42,
                              height: 42,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badgeText,
                              style: AppTextStyles.mono(
                                isDark,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: badgeFg,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
