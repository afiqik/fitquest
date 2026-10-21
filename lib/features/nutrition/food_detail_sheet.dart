import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../models/nutrition_data.dart';
import '../../providers/app_state.dart';

class FoodDetailSheet extends StatefulWidget {
  final MealItem meal;
  final AppState appState;

  const FoodDetailSheet({
    super.key,
    required this.meal,
    required this.appState,
  });

  static Future<void> show(BuildContext context, MealItem meal, AppState appState) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FoodDetailSheet(meal: meal, appState: appState),
    );
  }

  @override
  State<FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<FoodDetailSheet> {
  late MealItem _meal;

  @override
  void initState() {
    super.initState();
    _meal = widget.meal;
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.appState.isDark ? const Color(0xFF1F1A18) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Food Record?'),
        content: Text(
          'Are you sure you want to delete "${_meal.name}" from today\'s food log?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              widget.appState.deleteMeal(_meal.id);
              Navigator.pop(context); // Close sheet
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_meal.name} deleted from log.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openEditDialog() {
    final nameController = TextEditingController(text: _meal.name);
    final calController = TextEditingController(text: _meal.calories.toString());
    final proteinController = TextEditingController(text: _meal.protein.toInt().toString());
    final carbsController = TextEditingController(text: _meal.carbs.toInt().toString());
    final fatController = TextEditingController(text: _meal.fat.toInt().toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.appState.isDark ? const Color(0xFF1F1A18) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Meal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Meal Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: calController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calories (kcal)'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: proteinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Protein (g)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: carbsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Carbs (g)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: fatController,
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
              final newCal = int.tryParse(calController.text) ?? _meal.calories;
              final newP = double.tryParse(proteinController.text) ?? _meal.protein;
              final newC = double.tryParse(carbsController.text) ?? _meal.carbs;
              final newF = double.tryParse(fatController.text) ?? _meal.fat;
              final newName = nameController.text.trim();

              final updated = _meal.copyWith(
                name: newName.isNotEmpty ? newName : _meal.name,
                calories: newCal,
                protein: newP,
                carbs: newC,
                fat: newF,
                meta: '${_meal.formattedTime} · P ${newP.toInt()}g · C ${newC.toInt()}g · F ${newF.toInt()}g',
              );

              widget.appState.editMeal(updated);
              setState(() => _meal = updated);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.appState.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161210) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Food Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.energeticOrange.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: (_meal.imagePath != null && File(_meal.imagePath!).existsSync())
                      ? Image.file(
                          File(_meal.imagePath!),
                          fit: BoxFit.cover,
                          width: 56,
                          height: 56,
                        )
                      : Text(_meal.icon, style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _meal.name,
                        style: AppTextStyles.h2(isDark).copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white12 : AppColors.ink.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _meal.tag,
                              style: AppTextStyles.mono(isDark, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _meal.formattedTime,
                            style: AppTextStyles.muted(isDark).copyWith(fontSize: 12.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Dominant Calorie Card
            GlassCard(
              isDark: isDark,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Calories', style: AppTextStyles.caption(isDark)),
                      const SizedBox(height: 2),
                      Text(
                        '${_meal.calories} kcal',
                        style: AppTextStyles.mono(
                          isDark,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.energeticOrange,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _meal.servingSize,
                    style: AppTextStyles.muted(isDark).copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Macro Breakdown Cards
            Row(
              children: [
                Expanded(
                  child: _buildMacroPill('Protein', '${_meal.protein.toInt()}g', AppColors.energeticOrange, isDark),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMacroPill('Carbs', '${_meal.carbs.toInt()}g', AppColors.aiBlue, isDark),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMacroPill('Fat', '${_meal.fat.toInt()}g', AppColors.orangeLight, isDark),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Action Buttons (Edit / Delete)
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    text: 'Edit Record',
                    prefixIcon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: _openEditDialog,
                    variant: GlassButtonVariant.glassSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed.withValues(alpha: 0.12),
                      foregroundColor: AppColors.errorRed,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.errorRed.withValues(alpha: 0.3)),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _confirmDelete,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroPill(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.ink.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.ink.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.mono(
              isDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption(isDark)),
        ],
      ),
    );
  }
}
