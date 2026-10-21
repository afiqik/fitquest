import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/app_state.dart';
import 'bmi_screen.dart';
import 'intake_screen.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;
    final p = appState.profile;

    final reviewItems = [
      {'label': 'Name', 'value': p.name, 'step': 0},
      {'label': 'Gender', 'value': p.gender, 'step': 1},
      {'label': 'Age', 'value': '${p.age} years', 'step': 2},
      {'label': 'Height', 'value': '${p.height.toInt()} cm', 'step': 3},
      {'label': 'Weight', 'value': '${p.weight.toInt()} kg', 'step': 4},
      {'label': 'Activity Level', 'value': p.activityLevel, 'step': 5},
      {'label': 'Goal', 'value': p.fitnessGoal, 'step': 6},
      {'label': 'Commitment', 'value': '${p.commitDays} days a week', 'step': 7},
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackButton(isDark: isDark),
              const SizedBox(height: 24),
              Text(
                'REVIEW BEFORE GENERATING',
                style: AppTextStyles.mono(
                  isDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedText(isDark),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All looking good?',
                style: AppTextStyles.h1(isDark).copyWith(fontSize: 32),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap any row to edit. AI will use these details to build your plan.',
                style: AppTextStyles.body(isDark).copyWith(
                  color: AppColors.mutedText(isDark),
                ),
              ),
              const SizedBox(height: 20),

              // Review Items List
              Expanded(
                child: GlassCard(
                  isDark: isDark,
                  padding: EdgeInsets.zero,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: reviewItems.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDark ? Colors.white.withOpacity(0.08) : AppColors.ink.withOpacity(0.06),
                    ),
                    itemBuilder: (context, index) {
                      final item = reviewItems[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => IntakeScreen(initialStep: item['step'] as int),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item['label'] as String,
                                  style: AppTextStyles.body(isDark).copyWith(
                                    color: AppColors.mutedText(isDark),
                                  ),
                                ),
                              ),
                              Text(
                                item['value'] as String,
                                style: AppTextStyles.bodySemibold(isDark),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: AppColors.mutedText(isDark).withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Continue to BMI
              GlassButton(
                text: 'Looks good, calculate my BMI',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BmiScreen()),
                  );
                },
                variant: GlassButtonVariant.darkInk,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
