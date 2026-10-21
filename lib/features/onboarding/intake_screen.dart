import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ai_orb.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_chip.dart';
import '../../core/widgets/fitness_goal_selector.dart';
import '../../models/fitness_goal.dart';
import '../../providers/app_state.dart';
import 'review_screen.dart';

class IntakeScreen extends StatefulWidget {
  final int initialStep;
  const IntakeScreen({super.key, this.initialStep = 0});

  @override
  State<IntakeScreen> createState() => _IntakeScreenState();
}

class _IntakeScreenState extends State<IntakeScreen> {
  late int _step;
  late TextEditingController _nameController;

  // Local state for answers
  late String _name;
  late String _gender;
  late int _age;
  late double _height;
  late double _weight;
  late String _activityLevel;
  late String _fitnessGoal;
  late int _commitDays;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
    final p = context.read<AppState>().profile;
    _name = p.name;
    _gender = p.gender;
    _age = p.age;
    _height = p.height;
    _weight = p.weight;
    _activityLevel = p.activityLevel;
    _fitnessGoal = p.fitnessGoal;
    _commitDays = p.commitDays;

    _nameController = TextEditingController(text: _name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCurrentState() {
    context.read<AppState>().updateIntakeProfile(
      name: _name,
      gender: _gender,
      age: _age,
      height: _height,
      weight: _weight,
      activityLevel: _activityLevel,
      fitnessGoal: _fitnessGoal,
      commitDays: _commitDays,
    );
  }

  void _next() {
    _saveCurrentState();
    if (_step < 7) {
      setState(() => _step++);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ReviewScreen()),
      );
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppState>().isDark;
    final stepPct = ((_step + 1) / 8).clamp(0.0, 1.0);

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _back();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar with Progress Bar
                Row(
                  children: [
                    AppBackButton(
                      isDark: isDark,
                      onPressed: _back,
                    ),
                    const SizedBox(width: 14),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: Container(
                        height: 6,
                        color: isDark ? Colors.white.withOpacity(0.08) : AppColors.ink.withOpacity(0.08),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: stepPct,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.energeticOrange, AppColors.orangeLight],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '${_step + 1} / 8',
                    style: AppTextStyles.mono(
                      isDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedText(isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // AI Intake Badge Tag
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AiOrb(size: 16),
                  const SizedBox(width: 8),
                  Text('AI INTAKE', style: AppTextStyles.aiTag),
                ],
              ),
              const SizedBox(height: 12),

              // Title and Subtitle
              Text(
                _getQuestionTitle(_step),
                style: AppTextStyles.h1(isDark).copyWith(fontSize: 30),
              ),
              const SizedBox(height: 8),
              Text(
                _getQuestionSub(_step),
                style: AppTextStyles.body(isDark).copyWith(
                  color: AppColors.mutedText(isDark),
                ),
              ),

              const Spacer(),

              // Dynamic Question Input
              _buildStepInput(isDark),

              const Spacer(),

              // Next CTA
              GlassButton(
                text: _step == 7 ? 'Review answers' : 'Next',
                onPressed: _next,
                variant: GlassButtonVariant.darkInk,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    ),
  );
}

  String _getQuestionTitle(int step) {
    switch (step) {
      case 0: return 'What is your name?';
      case 1: return 'What is your gender?';
      case 2: return 'How old are you?';
      case 3: return 'What is your height?';
      case 4: return 'Current weight?';
      case 5: return 'How active are you?';
      case 6: return 'What is your main goal?';
      case 7: return 'How many days a week can you commit?';
      default: return '';
    }
  }

  String _getQuestionSub(int step) {
    switch (step) {
      case 0: return 'AI Coach will address you by this name.';
      case 1: return 'Used to calculate your basal metabolic rate (Mifflin-St Jeor).';
      case 2: return 'Determines target workout heart rate zones.';
      case 3: return 'Required for accurate BMI and calorie expenditure.';
      case 4: return 'We will monitor your weight progress weekly.';
      case 5: return 'Be honest — the AI will adjust workout intensity.';
      case 6: return 'This directly shapes your workout plan and exercises.';
      case 7: return 'AI will never schedule more sessions than your commitment.';
      default: return '';
    }
  }

  Widget _buildStepInput(bool isDark) {
    switch (_step) {
      case 0: // Name (Text Field)
        return GlassCard(
          isDark: isDark,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: TextField(
            controller: _nameController,
            style: AppTextStyles.h2(isDark).copyWith(fontSize: 22),
            decoration: const InputDecoration(
              hintText: 'Your full name',
              border: InputBorder.none,
            ),
            onChanged: (val) => _name = val,
          ),
        );

      case 1: // Gender (Choice)
        return _buildChoiceCards([
          {'label': 'Male', 'sub': 'Mifflin BMR formula', 'icon': '♂', 'val': 'Male'},
          {'label': 'Female', 'sub': 'Mifflin BMR formula', 'icon': '♀', 'val': 'Female'},
          {'label': 'Not specified', 'sub': 'Uses neutral average', 'icon': '•', 'val': 'Other'},
        ], _gender, (v) => setState(() => _gender = v), isDark);

      case 2: // Age (Number Slider & + / -)
        return _buildNumberSlider(
          value: _age.toDouble(),
          unit: 'years',
          min: 14,
          max: 75,
          onChanged: (v) => setState(() => _age = v.round()),
          isDark: isDark,
        );

      case 3: // Height (Number Slider)
        return _buildNumberSlider(
          value: _height,
          unit: 'cm',
          min: 130,
          max: 210,
          onChanged: (v) => setState(() => _height = v),
          isDark: isDark,
        );

      case 4: // Weight (Number Slider)
        return _buildNumberSlider(
          value: _weight,
          unit: 'kg',
          min: 35,
          max: 160,
          onChanged: (v) => setState(() => _weight = v),
          isDark: isDark,
        );

      case 5: // Activity Level (Choice)
        return _buildChoiceCards([
          {'label': 'Sedentary', 'sub': 'Sitting for most of the day', 'icon': '🪑', 'val': 'Sedentary'},
          {'label': 'Lightly Active', 'sub': '1–2 workouts per week', 'icon': '🚶', 'val': 'Light'},
          {'label': 'Active', 'sub': '3–5 workouts per week', 'icon': '🏃', 'val': 'Active'},
        ], _activityLevel, (v) => setState(() => _activityLevel = v), isDark);

      case 6: // Goal (FitnessGoalSelector)
        return FitnessGoalSelector(
          selectedGoal: FitnessGoal.fromString(_fitnessGoal),
          onGoalSelected: (g) => setState(() => _fitnessGoal = g.id),
          isDark: isDark,
        );

      case 7: // Commit Days (Number Slider)
        return _buildNumberSlider(
          value: _commitDays.toDouble(),
          unit: 'days',
          min: 2,
          max: 7,
          onChanged: (v) => setState(() => _commitDays = v.round()),
          isDark: isDark,
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildChoiceCards(
    List<Map<String, String>> options,
    String selectedValue,
    ValueChanged<String> onSelect,
    bool isDark,
  ) {
    return Column(
      children: options.map((opt) {
        final isSelected = selectedValue == opt['val'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassCard(
            isDark: isDark,
            onTap: () => onSelect(opt['val']!),
            borderColor: isSelected ? AppColors.energeticOrange : null,
            color: isSelected ? AppColors.energeticOrange.withOpacity(0.08) : null,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.energeticOrange.withOpacity(0.18)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    opt['icon']!,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opt['label']!,
                        style: AppTextStyles.bodySemibold(isDark).copyWith(
                          fontSize: 16.5,
                        ),
                      ),
                      Text(
                        opt['sub']!,
                        style: AppTextStyles.muted(isDark).copyWith(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.energeticOrange : AppColors.mutedText(isDark),
                      width: 2,
                    ),
                    color: isSelected ? AppColors.energeticOrange : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberSlider({
    required double value,
    required String unit,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required bool isDark,
  }) {
    final intDisplay = value.round();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$intDisplay',
              style: AppTextStyles.display(isDark).copyWith(
                fontSize: 82,
                fontWeight: FontWeight.w800,
                color: AppColors.energeticOrange,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              unit,
              style: AppTextStyles.h3(isDark).copyWith(
                color: AppColors.mutedText(isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: AppColors.energeticOrange,
          inactiveColor: AppColors.mutedText(isDark).withOpacity(0.2),
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassChip(
              isDark: isDark,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              onTap: () {
                if (value > min) onChanged(value - 1);
              },
              child: const Text('−', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 20),
            GlassChip(
              isDark: isDark,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              onTap: () {
                if (value < max) onChanged(value + 1);
              },
              child: const Text('+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }
}
