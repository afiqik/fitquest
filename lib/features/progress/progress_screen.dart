import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/ai_engine_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ai_orb.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/ai_model_selector_sheet.dart';
import '../../models/workout_plan.dart';
import '../../models/workout_session.dart';
import '../../providers/app_state.dart';
import '../workout/workout_detail_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

// Alias for semantic clarity
typedef WorkoutHistoryScreen = ProgressScreen;

class _ProgressScreenState extends State<ProgressScreen> {
  String _timeRange = 'all'; // 'all', 'week', 'month'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppState>().fetchNextWorkoutInsight();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;
    final lang = appState.language;
    final profile = appState.profile;
    final history = appState.workoutHistory;
    final plan = appState.activePlan;

    // Filter history based on selected filter
    final filteredHistory = _getFilteredHistory(history, _timeRange);

    // Calculate aggregated stats
    final totalCompleted = history.length;
    final totalSeconds = history.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    final totalMinutes = (totalSeconds / 60).round();
    final totalCalories = history.fold<int>(0, (sum, s) => sum + s.burnedCalories);

    // AI Reason and Motivation: use live OpenRouter insight from AppState with heuristic fallback
    final aiInsight = appState.cachedAiInsight ??
        AiEngineService.generateNextWorkoutInsight(
          history: history,
          profile: profile,
          language: lang,
          plan: plan,
        );

    // Next workout day to launch
    ScheduledWorkoutDay? nextDay;
    if (plan != null && plan.schedule.isNotEmpty) {
      nextDay = plan.schedule.firstWhere(
        (d) => d.state == 'today' || d.state == 'next',
        orElse: () => plan.schedule.first,
      );
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
              // Header
              Text(
                AppLocalizations.tr('history_title', lang),
                style: AppTextStyles.h1(isDark).copyWith(fontSize: 30),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.tr('history_subtitle', lang),
                style: AppTextStyles.body(isDark).copyWith(
                  color: AppColors.mutedText(isDark),
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 18),

              // Overview Metrics Cards Grid
              _buildMetricsGrid(
                isDark: isDark,
                lang: lang,
                totalCompleted: totalCompleted,
                totalMinutes: totalMinutes,
                totalCalories: totalCalories,
                streakDays: profile.streakDays,
              ),
              const SizedBox(height: 18),

              // AI Reason & Motivation Card for Next Workout
              _buildAiReasonMotivationCard(
                context: context,
                isDark: isDark,
                lang: lang,
                aiInsight: aiInsight,
                nextDay: nextDay,
              ),
              const SizedBox(height: 22),

              // Filter Tabs (Semua / Minggu Ini / Bulan Ini)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Workout Logs',
                          style: AppTextStyles.h2(isDark).copyWith(fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${filteredHistory.length} sessions',
                        style: AppTextStyles.muted(isDark).copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('all', AppLocalizations.tr('history_filter_all', lang), isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('week', AppLocalizations.tr('history_filter_week', lang), isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('month', AppLocalizations.tr('history_filter_month', lang), isDark),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Workout History List
              if (filteredHistory.isEmpty)
                _buildEmptyState(isDark: isDark, lang: lang)
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredHistory.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final session = filteredHistory[index];
                    return _buildWorkoutSessionCard(
                      context: context,
                      session: session,
                      isDark: isDark,
                      lang: lang,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<WorkoutSession> _getFilteredHistory(List<WorkoutSession> list, String filter) {
    if (filter == 'all') return list;
    final now = DateTime.now();
    if (filter == 'week') {
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      return list.where((s) => s.completedAt.isAfter(sevenDaysAgo)).toList();
    }
    if (filter == 'month') {
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      return list.where((s) => s.completedAt.isAfter(thirtyDaysAgo)).toList();
    }
    return list;
  }

  Widget _buildFilterChip(String key, String label, bool isDark) {
    final isSelected = _timeRange == key;
    return GestureDetector(
      onTap: () => setState(() => _timeRange = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.energeticOrange
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.energeticOrange
                : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : AppColors.darkBgDeep),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid({
    required bool isDark,
    required String lang,
    required int totalCompleted,
    required int totalMinutes,
    required int totalCalories,
    required int streakDays,
  }) {
    final items = [
      {
        'title': '$totalCompleted',
        'sub': 'Workouts Done',
        'icon': '🏋️',
        'color': AppColors.energeticOrange,
      },
      {
        'title': totalMinutes >= 60
            ? '${(totalMinutes / 60).toStringAsFixed(1)} hrs'
            : '$totalMinutes min',
        'sub': 'Total Time',
        'icon': '⏱️',
        'color': AppColors.aiBlue,
      },
      {
        'title': NumberFormat('#,###').format(totalCalories),
        'sub': 'Kcal Burned',
        'icon': '🔥',
        'color': AppColors.orangeLight,
      },
      {
        'title': '$streakDays days',
        'sub': 'Active Streak',
        'icon': '⚡',
        'color': AppColors.successGreen,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return GlassCard(
          isDark: isDark,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['icon'] as String,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item['color'] as Color,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  item['title'] as String,
                  style: AppTextStyles.h1(isDark).copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item['sub'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(isDark).copyWith(fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAiReasonMotivationCard({
    required BuildContext context,
    required bool isDark,
    required String lang,
    required Map<String, String> aiInsight,
    ScheduledWorkoutDay? nextDay,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E1714),
                  const Color(0xFF261912),
                  const Color(0xFF1B1824),
                ]
              : [
                  Colors.white.withOpacity(0.95),
                  const Color(0xFFFFF4EC),
                  const Color(0xFFF3F7FF),
                ],
        ),
        border: Border.all(
          color: AppColors.energeticOrange.withOpacity(isDark ? 0.35 : 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.energeticOrange.withOpacity(isDark ? 0.15 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const AiOrb(size: 18, showGlow: true),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        AppLocalizations.tr('ai_insight_badge', lang),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppColors.energeticOrange,
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                          letterSpacing: 0.6,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => AiModelSelectorSheet.show(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.aiBlue.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.aiBlue.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.watch<AppState>().currentAiModel.icon, style: const TextStyle(fontSize: 10)),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 88),
                        child: Text(
                          context.watch<AppState>().currentAiModel.name,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.aiBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down, size: 14, color: AppColors.aiBlue),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => context.read<AppState>().fetchNextWorkoutInsight(forceRefresh: true),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.energeticOrange.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: context.watch<AppState>().isInsightLoading
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.energeticOrange,
                          ),
                        )
                      : const Icon(
                          Icons.refresh_rounded,
                          size: 14,
                          color: AppColors.energeticOrange,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            AppLocalizations.tr('ai_insight_header', lang),
            style: AppTextStyles.h2(isDark).copyWith(fontSize: 17),
          ),
          const SizedBox(height: 10),

          // REASON BOX (Sebab)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.28) : Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📋', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        AppLocalizations.tr('ai_reason_label', lang),
                        style: AppTextStyles.bodySemibold(isDark).copyWith(
                          fontSize: 13,
                          color: AppColors.energeticOrange,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  aiInsight['reason'] ?? '',
                  style: AppTextStyles.body(isDark).copyWith(
                    fontSize: 12.5,
                    height: 1.45,
                    color: isDark ? Colors.white.withOpacity(0.90) : AppColors.darkBgDeep,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // MOTIVATION BOX (Motivasi)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.energeticOrange.withOpacity(isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.energeticOrange.withOpacity(0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        AppLocalizations.tr('ai_motivation_label', lang),
                        style: AppTextStyles.bodySemibold(isDark).copyWith(
                          fontSize: 13,
                          color: AppColors.energeticOrange,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '"${aiInsight['motivation'] ?? ''}"',
                  style: AppTextStyles.body(isDark).copyWith(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                    color: isDark ? Colors.white.withOpacity(0.92) : AppColors.darkBgDeep,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Next Recommended Workout Action Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.tr('ai_next_session', lang),
                        style: AppTextStyles.caption(isDark).copyWith(fontSize: 10.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        aiInsight['nextWorkoutTitle'] ?? '',
                        style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        aiInsight['nextWorkoutMeta'] ?? '',
                        style: AppTextStyles.muted(isDark).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (nextDay != null)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(workoutDay: nextDay),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.energeticOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.tr('btn_start_next_workout', lang),
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, size: 13),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSessionCard({
    required BuildContext context,
    required WorkoutSession session,
    required bool isDark,
    required String lang,
  }) {
    final isEn = lang == 'en';
    final dateStr = _formatSessionDate(session.completedAt, isEn);
    final durationMins = (session.durationSeconds / 60).round();

    return GlassCard(
      isDark: isDark,
      onTap: () => _showSessionDetailsSheet(context, session, isDark, lang),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workout Type Icon Box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.energeticOrange.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  _getWorkoutEmoji(session.workoutTitle),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),

              // Title and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.workoutTitle,
                      style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: AppTextStyles.muted(isDark).copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.greenLight.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.successGreen,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.tr('workout_completed_badge', lang),
                      style: const TextStyle(
                        color: AppColors.successGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Session stats row (Duration, Calories, Moves)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildStatChip(
                icon: Icons.timer_outlined,
                label: '$durationMins min',
                isDark: isDark,
              ),
              _buildStatChip(
                icon: Icons.local_fire_department_outlined,
                label: '${session.burnedCalories} kcal',
                isDark: isDark,
              ),
              _buildStatChip(
                icon: Icons.fitness_center_rounded,
                label: '${session.completedExercises}/${session.totalExercises} ${AppLocalizations.tr('exercises_done', lang)}',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.mutedText(isDark)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.darkBgDeep,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionDetailsSheet(
    BuildContext context,
    WorkoutSession session,
    bool isDark,
    String lang,
  ) {
    final dateStr = DateFormat('EEEE, d MMMM yyyy · h:mm a').format(session.completedAt);
    final durationMins = (session.durationSeconds / 60).round();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1917) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Text(
                      _getWorkoutEmoji(session.workoutTitle),
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.workoutTitle,
                            style: AppTextStyles.h2(isDark).copyWith(fontSize: 20),
                          ),
                          Text(
                            dateStr,
                            style: AppTextStyles.muted(isDark).copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Metrics Breakdown Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildModalMetric(
                        title: '$durationMins min',
                        label: 'Duration',
                        isDark: isDark,
                      ),
                      Container(width: 1, height: 32, color: Colors.grey.withOpacity(0.3)),
                      _buildModalMetric(
                        title: '${session.burnedCalories} kcal',
                        label: 'Calories',
                        isDark: isDark,
                      ),
                      Container(width: 1, height: 32, color: Colors.grey.withOpacity(0.3)),
                      _buildModalMetric(
                        title: '${session.completedExercises}',
                        label: 'Exercises',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // AI Recovery & Physiological Note
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.energeticOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.energeticOrange.withOpacity(0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Recovery Note',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.energeticOrange,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Session completed successfully. Remember to hydrate with at least 500ml water and consume 20-30g of protein for muscle tissue repair.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: isDark ? Colors.white70 : AppColors.darkBgDeep,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.energeticOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.tr('close', lang),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalMetric({
    required String title,
    required String label,
    required bool isDark,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: AppTextStyles.h2(isDark).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption(isDark).copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildEmptyState({required bool isDark, required String lang}) {
    return GlassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.energeticOrange.withOpacity(0.12),
            ),
            alignment: Alignment.center,
            child: const Text('📜', style: TextStyle(fontSize: 30)),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.tr('history_empty_title', lang),
            style: AppTextStyles.h2(isDark).copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.tr('history_empty_desc', lang),
            style: AppTextStyles.muted(isDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatSessionDate(DateTime date, bool isEn) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 12 && now.day == date.day) {
      final timeStr = DateFormat('h:mm a').format(date);
      return 'Today, $timeStr';
    } else if (diff.inHours < 36 && now.day - date.day == 1) {
      final timeStr = DateFormat('h:mm a').format(date);
      return 'Yesterday, $timeStr';
    } else {
      return DateFormat('d MMM yyyy · h:mm a').format(date);
    }
  }

  String _getWorkoutEmoji(String title) {
    final t = title.toLowerCase();
    if (t.contains('upper') || t.contains('dada') || t.contains('strength')) return '💪';
    if (t.contains('lower') || t.contains('kaki') || t.contains('squat')) return '🦵';
    if (t.contains('core') || t.contains('mobiliti')) return '🧘';
    if (t.contains('fat') || t.contains('hiit') || t.contains('cardio')) return '🔥';
    return '🏋️';
  }
}
