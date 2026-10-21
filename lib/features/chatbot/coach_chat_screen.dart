import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ai_orb.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/ai_model_selector_sheet.dart';
import '../../providers/app_state.dart';

class CoachChatScreen extends StatefulWidget {
  const CoachChatScreen({super.key});

  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestedPrompts = [
    'How many grams of protein should I eat daily?',
    'My knees ache when squatting, are there alternatives?',
    'If I miss a workout day, does my plan adjust?',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _textController.text;
    if (text.trim().isEmpty) return;

    _textController.clear();
    context.read<AppState>().sendChatMessage(text);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;
    final messages = appState.chatMessages;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Coach Identity
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  AppBackButton(isDark: isDark),
                  const SizedBox(width: 14),
                  const AiOrb(size: 38, showGlow: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Coach FitQuest',
                          style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 16),
                        ),
                        Text(
                          'Based on BMI ${appState.profile.bmi.toStringAsFixed(1)} & goal ${appState.profile.fitnessGoal}',
                          style: AppTextStyles.caption(isDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Model Selector Chip
                  InkWell(
                    onTap: () => AiModelSelectorSheet.show(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.energeticOrange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.energeticOrange.withOpacity(0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(appState.currentAiModel.icon, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 85),
                            child: Text(
                              appState.currentAiModel.name,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.energeticOrange,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.energeticOrange),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? Colors.white.withOpacity(0.08) : AppColors.ink.withOpacity(0.06)),

            // Suggested Quick Prompts
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _suggestedPrompts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () => _sendMessage(_suggestedPrompts[index]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.aiBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: AppColors.aiBlue.withOpacity(0.2)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _suggestedPrompts[index],
                          style: AppTextStyles.caption(isDark).copyWith(
                            color: AppColors.aiBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Messages Stream
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isUser = msg.isUser;

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.78,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: isUser
                            ? AppColors.energeticOrange
                            : (isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.9)),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(22),
                          topRight: const Radius.circular(22),
                          bottomLeft: Radius.circular(isUser ? 22 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 22),
                        ),
                        border: isUser
                            ? null
                            : Border.all(
                                color: isDark ? Colors.white.withOpacity(0.12) : Colors.white,
                                width: 1.2,
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: isUser ? Colors.white : (isDark ? AppColors.inkLight : AppColors.ink),
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (appState.isChatLoading)
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 8),
                child: Row(
                  children: [
                    const AiOrb(size: 14),
                    const SizedBox(width: 8),
                    Text(
                      'AI is typing...',
                      style: AppTextStyles.caption(isDark).copyWith(color: AppColors.aiBlue),
                    ),
                  ],
                ),
              ),

            // Chat Input Field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: GlassCard(
                isDark: isDark,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: 26,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: AppTextStyles.body(isDark),
                        decoration: InputDecoration(
                          hintText: 'Ask anything to AI Coach...',
                          hintStyle: TextStyle(color: AppColors.mutedText(isDark)),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.energeticOrange),
                      onPressed: () => _sendMessage(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
