import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ai_orb.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/ai_engine_service.dart';
import '../../providers/app_state.dart';
import 'generating_screen.dart';

class BmiScreen extends StatelessWidget {
  const BmiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;
    final profile = appState.profile;
    final bmi = profile.bmi;
    final bmiCat = profile.bmiCategory;
    final insight = AiEngineService.generateBmiInsight(profile);

    // Position on indicator bar (range 15 to 40)
    final indicatorPct = ((bmi - 15) / (40 - 15)).clamp(0.05, 0.95);

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
                'STEP 09 · BMI',
                style: AppTextStyles.mono(
                  isDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedText(isDark),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Here is where you stand',
                style: AppTextStyles.h1(isDark).copyWith(fontSize: 30),
              ),
              const SizedBox(height: 24),

              // BMI Score Card
              GlassCard(
                isDark: isDark,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          bmi.toStringAsFixed(1),
                          style: AppTextStyles.display(isDark).copyWith(
                            fontSize: 74,
                            color: AppColors.energeticOrange,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bmiCat,
                              style: AppTextStyles.h2(isDark).copyWith(fontSize: 20),
                            ),
                            Text(
                              'BMI = kg ÷ m²',
                              style: AppTextStyles.muted(isDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Colored Gradient Scale with pointer
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.aiBlue,
                                AppColors.greenLight,
                                AppColors.orangeLight,
                                AppColors.energeticOrange,
                                AppColors.errorRed,
                              ],
                            ),
                          ),
                        ),
                        // Pointer circle
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.72 * indicatorPct,
                          top: -4,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: AppColors.ink, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('15', style: AppTextStyles.mono(isDark, fontSize: 11)),
                        Text('18.5', style: AppTextStyles.mono(isDark, fontSize: 11)),
                        Text('25', style: AppTextStyles.mono(isDark, fontSize: 11)),
                        Text('30', style: AppTextStyles.mono(isDark, fontSize: 11)),
                        Text('40', style: AppTextStyles.mono(isDark, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // AI Reading Card
              GlassCard(
                isDark: isDark,
                color: AppColors.aiBlue.withOpacity(0.08),
                borderColor: AppColors.aiBlue.withOpacity(0.24),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AiOrb(size: 16),
                        const SizedBox(width: 8),
                        Text('AI READING', style: AppTextStyles.aiTag),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      insight,
                      style: AppTextStyles.body(isDark).copyWith(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Generate Plan Button
              GlassButton(
                text: 'Generate my plan',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const GeneratingScreen()),
                  );
                },
                variant: GlassButtonVariant.primaryOrange,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
