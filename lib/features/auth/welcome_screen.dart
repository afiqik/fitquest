import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/app_logo.dart';
import '../../providers/app_state.dart';
import 'login_screen.dart';
import '../onboarding/intake_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppState>().isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
      body: Stack(
        children: [
          // Background Ambience Glows
          Positioned(
            top: -50,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.energeticOrange.withOpacity(isDark ? 0.32 : 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.aiBlue.withOpacity(isDark ? 0.22 : 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // AI Badge Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.energeticOrange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.energeticOrange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'AI-POWERED FITNESS',
                      style: AppTextStyles.mono(
                        isDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.energeticOrange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'FitQuest',
                    style: AppTextStyles.display(isDark).copyWith(
                      fontSize: 54,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Answer a few questions. AI will create a workout plan tailored specifically to your body and goals.',
                    style: AppTextStyles.body(isDark).copyWith(
                      fontSize: 16.5,
                      color: isDark ? AppColors.inkLight.withOpacity(0.7) : AppColors.ink.withOpacity(0.65),
                    ),
                  ),

                  const Spacer(),

                  // Center Branded Logo
                  const Center(
                    child: AppLogo(
                      size: 130,
                      showGlow: true,
                    ),
                  ),

                  const Spacer(),

                  // CTA Buttons
                  GlassButton(
                    text: 'Get Started',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const IntakeScreen()),
                      );
                    },
                    variant: GlassButtonVariant.primaryOrange,
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: AppTextStyles.body(isDark).copyWith(
                            color: AppColors.mutedText(isDark),
                          ),
                          children: [
                            TextSpan(
                              text: 'Log in',
                              style: TextStyle(
                                color: AppColors.energeticOrange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
