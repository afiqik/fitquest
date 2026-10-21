import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../models/nutrition_data.dart';
import '../../providers/app_state.dart';

class WaterTrackerCard extends StatelessWidget {
  final DailyNutrition nutrition;
  final AppState appState;
  final bool isDark;

  const WaterTrackerCard({
    super.key,
    required this.nutrition,
    required this.appState,
    required this.isDark,
  });

  void _showCustomWaterDialog(BuildContext context) {
    final controller = TextEditingController(text: '300');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F1A18) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Custom Water Intake'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Amount (ml)',
            suffixText: 'ml',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aiBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                appState.addWater(val, source: 'custom_input');
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLiters = (nutrition.waterCurrentMl / 1000.0).toStringAsFixed(1);
    final targetLiters = (nutrition.waterTargetMl / 1000.0).toStringAsFixed(1);
    final progress = nutrition.waterProgress;
    final percentage = nutrition.waterPercentage;

    return GlassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.aiBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text('💧', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WATER',
                            style: AppTextStyles.mono(
                              isDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.aiBlue,
                            ),
                          ),
                          Text(
                            '$currentLiters L of $targetLiters L',
                            style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Percentage Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.aiBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.aiBlue.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$percentage%',
                  style: AppTextStyles.mono(
                    isDark,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.aiBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Animated Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: progress),
              builder: (context, val, _) {
                return LinearProgressIndicator(
                  value: val,
                  minHeight: 12,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.ink.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.aiBlue),
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // Stepper Row: [-] 250 ml [+]
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.ink.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.ink.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: nutrition.waterCurrentMl >= 250
                      ? () => appState.removeWater(250)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: nutrition.waterCurrentMl >= 250
                          ? (isDark ? Colors.white12 : Colors.black12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.remove,
                      size: 20,
                      color: nutrition.waterCurrentMl >= 250
                          ? (isDark ? Colors.white : AppColors.ink)
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                Text(
                  '250 ml',
                  style: AppTextStyles.mono(
                    isDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () => appState.addWater(250),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.aiBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.add,
                      size: 20,
                      color: AppColors.aiBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Quick Add Pills: +150 ml, +250 ml, +500 ml & Custom
          Row(
            children: [
              _buildQuickAddButton(
                context,
                label: '+150 ml',
                amount: 150,
                onTap: () => appState.addWater(150),
              ),
              const SizedBox(width: 8),
              _buildQuickAddButton(
                context,
                label: '+250 ml',
                amount: 250,
                isPrimary: true,
                onTap: () => appState.addWater(250),
              ),
              const SizedBox(width: 8),
              _buildQuickAddButton(
                context,
                label: '+500 ml',
                amount: 500,
                onTap: () => appState.addWater(500),
              ),
              const SizedBox(width: 6),
              // Custom Input Button
              Tooltip(
                message: 'Add Custom Water',
                child: InkWell(
                  onTap: () => _showCustomWaterDialog(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.ink.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    child: const Icon(Icons.tune, size: 16),
                  ),
                ),
              ),
              if (nutrition.waterIntakes.isNotEmpty) ...[
                const SizedBox(width: 6),
                Tooltip(
                  message: 'Undo Last Intake',
                  child: InkWell(
                    onTap: () {
                      final lastAmount = nutrition.waterIntakes.last.amountMl;
                      appState.undoLastWater();
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Undone: $lastAmount ml water removed.'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.ink.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      ),
                      child: const Icon(Icons.undo, size: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(
    BuildContext context, {
    required String label,
    required int amount,
    bool isPrimary = false,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isPrimary
                ? AppColors.aiBlue.withValues(alpha: 0.16)
                : (isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.ink.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary
                  ? AppColors.aiBlue.withValues(alpha: 0.4)
                  : (isDark ? Colors.white12 : Colors.black12),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.mono(
              isDark,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPrimary ? AppColors.aiBlue : (isDark ? AppColors.inkLight : AppColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}
