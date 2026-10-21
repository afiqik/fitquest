import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ai_orb.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/app_state.dart';
import 'plan_ready_screen.dart';

class GeneratingScreen extends StatefulWidget {
  const GeneratingScreen({super.key});

  @override
  State<GeneratingScreen> createState() => _GeneratingScreenState();
}

class _GeneratingScreenState extends State<GeneratingScreen> {
  int _pct = 0;
  Timer? _timer;

  final List<String> _steps = [
    'Reading body profile & biometrics',
    'Calculating BMI & safe heart rate zones',
    'Matching 240 exercises with your goals',
    'Balancing cardio & muscle hypertrophy',
    'Structuring 4-week adaptive schedule',
  ];

  @override
  void initState() {
    super.initState();
    _startGenerating();
  }

  void _startGenerating() {
    _timer = Timer.periodic(const Duration(milliseconds: 70), (t) {
      if (_pct < 100) {
        setState(() => _pct += 2);
      } else {
        _timer?.cancel();
        context.read<AppState>().generateAndSavePlan();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PlanReadyScreen()),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppState>().isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated Glowing AI Center Orb
              AiOrb(
                size: 130,
                showGlow: true,
                child: Text(
                  '$_pct%',
                  style: AppTextStyles.mono(
                    false,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 36),
              Text(
                'AI is building your plan',
                style: AppTextStyles.h2(isDark).copyWith(fontSize: 26),
              ),
              const SizedBox(height: 8),
              Text(
                'Tailored to your body profile, schedule, and fitness goals.',
                style: AppTextStyles.body(isDark).copyWith(
                  color: AppColors.mutedText(isDark),
                  fontSize: 14.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 34),

              // 5 Phases Checklist
              Column(
                children: List.generate(_steps.length, (index) {
                  final targetPct = (index + 1) * 20;
                  final isDone = _pct >= targetPct;
                  final isActive = _pct >= targetPct - 20 && _pct < targetPct;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: GlassCard(
                      isDark: isDark,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: isDone 
                          ? AppColors.aiBlue.withOpacity(0.08)
                          : null,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone 
                                  ? AppColors.aiBlue 
                                  : (isActive ? AppColors.energeticOrange : Colors.grey.withOpacity(0.3)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _steps[index],
                              style: AppTextStyles.body(isDark).copyWith(
                                fontSize: 14,
                                fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                                color: isDone 
                                    ? (isDark ? AppColors.inkLight : AppColors.ink)
                                    : AppColors.mutedText(isDark),
                              ),
                            ),
                          ),
                          if (isDone)
                            const Icon(Icons.check, size: 16, color: AppColors.aiBlue),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
