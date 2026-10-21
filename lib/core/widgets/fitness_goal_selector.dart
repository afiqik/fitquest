import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../models/fitness_goal.dart';
import 'glass_card.dart';

class FitnessGoalSelector extends StatelessWidget {
  final FitnessGoal selectedGoal;
  final ValueChanged<FitnessGoal> onGoalSelected;
  final bool isDark;

  const FitnessGoalSelector({
    super.key,
    required this.selectedGoal,
    required this.onGoalSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: FitnessGoal.values.map((goal) {
        final isSelected = goal == selectedGoal;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassCard(
            isDark: isDark,
            onTap: () => onGoalSelected(goal),
            borderColor: isSelected ? AppColors.energeticOrange : null,
            borderWidth: isSelected ? 2.0 : 1.0,
            color: isSelected
                ? AppColors.energeticOrange.withValues(alpha: 0.12)
                : null,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Goal Icon Badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.energeticOrange.withValues(alpha: 0.22)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.ink.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.energeticOrange.withValues(alpha: 0.5)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    goal.icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 16),

                // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              goal.title,
                              style: AppTextStyles.bodySemibold(isDark).copyWith(
                                fontSize: 16,
                                color: isSelected
                                    ? AppColors.energeticOrange
                                    : (isDark ? AppColors.inkLight : AppColors.ink),
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.energeticOrange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        goal.description,
                        style: AppTextStyles.muted(isDark).copyWith(
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Selection Radio Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.energeticOrange
                          : (isDark ? Colors.white38 : Colors.black26),
                      width: 2,
                    ),
                    color: isSelected ? AppColors.energeticOrange : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
