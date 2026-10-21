import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../providers/app_state.dart';

class AiModelSelectorSheet extends StatefulWidget {
  const AiModelSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AiModelSelectorSheet(),
    );
  }

  @override
  State<AiModelSelectorSheet> createState() => _AiModelSelectorSheetState();
}

class _AiModelSelectorSheetState extends State<AiModelSelectorSheet> {
  bool _showApiKeyInput = false;
  late TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _apiKeyController = TextEditingController(text: appState.openRouterService.apiKey);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;
    final models = appState.availableAiModels;
    final currentModelId = appState.selectedAiModel;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1917) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pill handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.energeticOrange,
                          AppColors.orangeGradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('🤖', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose AI Model (OpenRouter)',
                          style: AppTextStyles.h2(isDark).copyWith(fontSize: 18),
                        ),
                        Text(
                          'Select artificial intelligence for AI Coach & Analysis',
                          style: AppTextStyles.muted(isDark).copyWith(fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Model list
              ...models.map((model) {
                final isSelected = model.id == currentModelId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () async {
                      await appState.setAiModel(model.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Model switched to ${model.name} (${model.provider})'),
                            backgroundColor: AppColors.energeticOrange,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.energeticOrange.withOpacity(isDark ? 0.18 : 0.12)
                            : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.energeticOrange
                              : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
                          width: isSelected ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.energeticOrange.withOpacity(0.2)
                                  : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(model.icon, style: const TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        model.name,
                                        style: AppTextStyles.bodySemibold(isDark).copyWith(
                                          fontSize: 15,
                                          color: isSelected ? AppColors.energeticOrange : null,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        model.provider,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white70 : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  model.description,
                                  style: AppTextStyles.muted(isDark).copyWith(fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isSelected)
                            Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: AppColors.energeticOrange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 16),
                            )
                          else
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? Colors.white30 : Colors.black26,
                                  width: 1.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),

              // API Key Configuration toggle
              InkWell(
                onTap: () => setState(() => _showApiKeyInput = !_showApiKeyInput),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.key_rounded,
                        size: 18,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Configure OpenRouter API Key',
                          style: AppTextStyles.body(isDark).copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.energeticOrange,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _showApiKeyInput ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 18,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),

              if (_showApiKeyInput) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.10),
                    ),
                  ),
                  child: TextField(
                    controller: _apiKeyController,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'sk-or-v1-...',
                      hintStyle: const TextStyle(fontSize: 12),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save_rounded, size: 20, color: AppColors.energeticOrange),
                        onPressed: () async {
                          await appState.setOpenRouterApiKey(_apiKeyController.text);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('OpenRouter API key saved successfully.'),
                                backgroundColor: AppColors.successGreen,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'A default key is pre-configured for free access to all models.',
                  style: AppTextStyles.muted(isDark).copyWith(fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
