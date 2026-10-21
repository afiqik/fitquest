import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_chip.dart';
import '../../models/nutrition_data.dart';
import '../../providers/app_state.dart';
import 'food_detail_sheet.dart';
import 'food_scan_screen.dart';
import 'water_tracker_card.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  void _showAddManualMealDialog(BuildContext context, AppState appState) {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final pCtrl = TextEditingController(text: '20');
    final cCtrl = TextEditingController(text: '30');
    final fCtrl = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: appState.isDark ? const Color(0xFF1F1A18) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Meal Manually'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Meal Name',
                  hintText: 'e.g. Boiled Eggs & Toast',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: calCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calories (kcal)'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: pCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Protein (g)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: cCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Carbs (g)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: fCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Fat (g)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.energeticOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final cal = int.tryParse(calCtrl.text) ?? 0;
              final p = double.tryParse(pCtrl.text) ?? 0.0;
              final c = double.tryParse(cCtrl.text) ?? 0.0;
              final f = double.tryParse(fCtrl.text) ?? 0.0;

              if (name.isNotEmpty && cal > 0) {
                appState.logScannedFood(
                  name,
                  cal,
                  'P ${p.toInt()}g · C ${c.toInt()}g · F ${f.toInt()}g',
                  protein: p,
                  carbs: c,
                  fat: f,
                );
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
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;
    final n = appState.nutrition;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.energeticOrange,
          onRefresh: () => appState.refreshNutrition(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nutrition',
                            style: AppTextStyles.h1(isDark).copyWith(fontSize: 32),
                          ),
                          Text(
                            'Daily targets based on weight & goals',
                            style: AppTextStyles.muted(isDark).copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlassChip(
                      isDark: isDark,
                      child: Text(
                        '${n.targetCalories} KCAL',
                        style: AppTextStyles.mono(
                          isDark,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.energeticOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 2. Nutrition Summary Card (Dominant Calories & 3 Macros)
                _buildNutritionSummaryCard(context, n, isDark),
                const SizedBox(height: 16),

                // 3. AI Food Scanner Banner Card
                GlassCard(
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FoodScanScreen()),
                    );
                  },
                  color: AppColors.aiBlue.withValues(alpha: 0.09),
                  borderColor: AppColors.aiBlue.withValues(alpha: 0.28),
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.aiOrbGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.aiBlue.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text('📷', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Food Vision',
                              style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Take a photo of your meal — AI automatically estimates calories & macros.',
                              style: AppTextStyles.muted(isDark).copyWith(fontSize: 12.5),
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
                const SizedBox(height: 16),

                // 4. Interactive Water Tracker Card
                WaterTrackerCard(
                  nutrition: n,
                  appState: appState,
                  isDark: isDark,
                ),
                const SizedBox(height: 22),

                // 5. Today's Food Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "TODAY'S MEALS (${n.meals.length})",
                        style: AppTextStyles.mono(
                          isDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mutedText(isDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _showAddManualMealDialog(context, appState),
                      icon: const Icon(Icons.add, size: 16, color: AppColors.energeticOrange),
                      label: const Text(
                        'Add',
                        style: TextStyle(
                          color: AppColors.energeticOrange,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 6. Food List or Empty State
                if (n.meals.isEmpty)
                  _buildEmptyState(context, isDark)
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: n.meals.length,
                    itemBuilder: (context, index) {
                      final meal = n.meals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: _buildFoodItemCard(context, meal, appState, isDark),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionSummaryCard(BuildContext context, DailyNutrition n, bool isDark) {
    final calRemaining = n.remainingCalories;
    final progress = n.calorieProgress;

    return GlassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dominant Calorie Row
          Row(
            children: [
              // Circular Progress Ring
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppColors.ink.withValues(alpha: 0.08),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.energeticOrange),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$calRemaining',
                          style: AppTextStyles.h1(isDark).copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'KCAL LEFT',
                          style: AppTextStyles.mono(
                            isDark,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mutedText(isDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Consumed vs Target Summary Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CALORIE INTAKE',
                      style: AppTextStyles.mono(
                        isDark,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.energeticOrange,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${n.consumedCalories}',
                            style: AppTextStyles.h2(isDark).copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${n.targetCalories} kcal',
                            style: AppTextStyles.muted(isDark).copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      progress >= 1.0
                          ? 'Daily calorie target reached!'
                          : '${(progress * 100).toInt()}% of daily target.',
                      style: AppTextStyles.muted(isDark).copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: isDark ? Colors.white12 : Colors.black12),
          const SizedBox(height: 12),

          // 3 Macros Progress Bars
          _buildMacroBar('Protein', n.proteinGrams, n.targetProteinGrams, AppColors.energeticOrange, isDark),
          const SizedBox(height: 12),
          _buildMacroBar('Carbs', n.carbsGrams, n.targetCarbsGrams, AppColors.aiBlue, isDark),
          const SizedBox(height: 12),
          _buildMacroBar('Fat', n.fatGrams, n.targetFatGrams, AppColors.orangeLight, isDark),
        ],
      ),
    );
  }

  Widget _buildMacroBar(String name, double current, double target, Color fill, bool isDark) {
    final pct = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 13)),
            Text(
              '${current.toInt()} / ${target.toInt()} g',
              style: AppTextStyles.mono(isDark, fontSize: 11.5, color: AppColors.mutedText(isDark)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.ink.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(fill),
            minHeight: 7,
          ),
        ),
      ],
    );
  }

  Widget _buildFoodItemCard(
    BuildContext context,
    MealItem meal,
    AppState appState,
    bool isDark,
  ) {
    return GlassCard(
      isDark: isDark,
      onTap: () => FoodDetailSheet.show(context, meal, appState),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Icon / Thumbnail Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.energeticOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: (meal.imagePath != null && File(meal.imagePath!).existsSync())
                ? Image.file(
                    File(meal.imagePath!),
                    fit: BoxFit.cover,
                    width: 48,
                    height: 48,
                  )
                : Text(meal.icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),

          // Name, Category, Macros
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : AppColors.ink.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        meal.tag,
                        style: AppTextStyles.mono(isDark, fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      meal.formattedTime,
                      style: AppTextStyles.muted(isDark).copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'P ${meal.protein.toInt()}g · C ${meal.carbs.toInt()}g · F ${meal.fat.toInt()}g',
                  style: AppTextStyles.muted(isDark).copyWith(fontSize: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Calories
          Text(
            '${meal.calories} kcal',
            style: AppTextStyles.mono(
              isDark,
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppColors.energeticOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return GlassCard(
      isDark: isDark,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Center(
        child: Column(
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              'No meals logged today.',
              style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Scan food with AI or add manually to track your calories & macronutrients.',
              style: AppTextStyles.muted(isDark).copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.energeticOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.camera_alt, size: 18),
              label: const Text('Scan Food Now', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FoodScanScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
