import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/app_state.dart';
import 'revised_plan_screen.dart';

class IncompleteFeedbackScreen extends StatefulWidget {
  const IncompleteFeedbackScreen({super.key});

  @override
  State<IncompleteFeedbackScreen> createState() => _IncompleteFeedbackScreenState();
}

class _IncompleteFeedbackScreenState extends State<IncompleteFeedbackScreen> {
  String _selectedReason = 'time';
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _reasons = [
    {
      'v': 'time',
      'label': 'Not enough time',
      'note': 'Busy day & limited availability',
      'icon': '⏱️',
      'color': AppColors.energeticOrange,
    },
    {
      'v': 'fatigue',
      'label': 'Too exhausted',
      'note': 'Body has not fully recovered from previous session',
      'icon': '😮‍💨',
      'color': AppColors.aiBlue,
    },
    {
      'v': 'injury',
      'label': 'Pain / injury',
      'note': 'Joint or muscle discomfort',
      'icon': '🩹',
      'color': AppColors.errorRed,
    },
    {
      'v': 'other',
      'label': 'Other reason',
      'note': 'Add notes for your AI Coach',
      'icon': '✍️',
      'color': Colors.grey,
    },
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submitFeedback() async {
    final appState = context.read<AppState>();
    appState.setIncompleteReason(_selectedReason, _notesController.text);
    await appState.processAdaptiveRevision();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RevisedPlanScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppState>().isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackButton(isDark: isDark),
              const SizedBox(height: 24),
              Text(
                'INCOMPLETE WORKOUT',
                style: AppTextStyles.mono(
                  isDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedText(isDark),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Could not finish?',
                style: AppTextStyles.h1(isDark).copyWith(fontSize: 30),
              ),
              const SizedBox(height: 6),
              Text(
                'Stopping early is completely fine. Select a reason below so AI can adjust your upcoming plan to match your energy.',
                style: AppTextStyles.body(isDark).copyWith(
                  color: AppColors.mutedText(isDark),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Reason Cards
              ..._reasons.map((r) {
                final isSelected = _selectedReason == r['v'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: GlassCard(
                    isDark: isDark,
                    onTap: () => setState(() => _selectedReason = r['v']),
                    borderColor: isSelected ? AppColors.energeticOrange : null,
                    color: isSelected ? AppColors.energeticOrange.withOpacity(0.08) : null,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: (r['color'] as Color).withOpacity(0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(r['icon'] as String, style: const TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r['label'] as String,
                                style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 16),
                              ),
                              Text(
                                r['note'] as String,
                                style: AppTextStyles.muted(isDark).copyWith(fontSize: 12.5),
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
              }),

              if (_selectedReason == 'other') ...[
                const SizedBox(height: 8),
                GlassCard(
                  isDark: isDark,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _notesController,
                    style: AppTextStyles.body(isDark),
                    decoration: InputDecoration(
                      hintText: 'Enter a note for AI Coach...',
                      hintStyle: TextStyle(color: AppColors.mutedText(isDark)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Submit Reason Button
              GlassButton(
                text: 'Submit & Adjust AI Plan',
                onPressed: _submitFeedback,
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
