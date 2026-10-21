import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_chip.dart';
import '../../core/widgets/ai_model_selector_sheet.dart';
import '../../providers/app_state.dart';
import '../achievements/achievements_screen.dart';
import 'edit_profile_screen.dart';
import '../auth/welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickImage(BuildContext context, AppState appState, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        await appState.updateProfilePhoto(picked.path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.tr('photo_updated_msg', appState.language)),
              backgroundColor: AppColors.energeticOrange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showPhotoOptions(BuildContext context, AppState appState, bool isDark) {
    final lang = appState.language;
    final hasPhoto = appState.profile.photoPath != null &&
        appState.profile.photoPath!.isNotEmpty &&
        File(appState.profile.photoPath!).existsSync();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1917) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.tr('change_photo_title', lang),
                  style: AppTextStyles.h2(isDark).copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.energeticOrange.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.energeticOrange, size: 22),
                  ),
                  title: Text(
                    AppLocalizations.tr('photo_source_camera', lang),
                    style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 15),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(context, appState, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.aiBlue.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.aiBlue, size: 22),
                  ),
                  title: Text(
                    AppLocalizations.tr('photo_source_gallery', lang),
                    style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 15),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(context, appState, ImageSource.gallery);
                  },
                ),
                if (hasPhoto)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed, size: 22),
                    ),
                    title: Text(
                      AppLocalizations.tr('photo_remove', lang),
                      style: AppTextStyles.bodySemibold(isDark).copyWith(
                        fontSize: 15,
                        color: AppColors.errorRed,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await appState.removeProfilePhoto();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.tr('photo_removed_msg', lang)),
                            backgroundColor: AppColors.inkLight,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;
    final lang = appState.language;
    final isEn = lang == 'en';
    final profile = appState.profile;

    final initial = profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'A';
    final hasPhoto = profile.photoPath != null &&
        profile.photoPath!.isNotEmpty &&
        File(profile.photoPath!).existsSync();

    final bodyStats = [
      {'k': 'BMI', 'v': profile.bmi.toStringAsFixed(1)},
      {
        'k': AppLocalizations.tr('profile_height', lang),
        'v': '${profile.height.toInt()} cm',
      },
      {
        'k': AppLocalizations.tr('profile_weight', lang),
        'v': '${profile.weight.toInt()} kg',
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header Row with Photo Upload
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showPhotoOptions(context, appState, isDark),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: hasPhoto
                                ? null
                                : const LinearGradient(
                                    colors: [AppColors.orangeLight, AppColors.energeticOrange],
                                  ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.energeticOrange.withOpacity(0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.energeticOrange,
                              width: 2.5,
                            ),
                          ),
                          child: ClipOval(
                            child: hasPhoto
                                ? Image.file(
                                    File(profile.photoPath!),
                                    width: 76,
                                    height: 76,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        // Camera Edit Badge Icon
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.energeticOrange,
                              border: Border.all(
                                color: isDark ? AppColors.darkBgDeep : Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: AppTextStyles.h2(isDark).copyWith(fontSize: 22),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${profile.age} ${AppLocalizations.tr('profile_years_old', lang)} · ${profile.gender} · ${profile.activityLevel}',
                          style: AppTextStyles.muted(isDark).copyWith(fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),

                  GlassChip(
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Text(
                      AppLocalizations.tr('edit', lang),
                      style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 13.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Body Stats Row
              Row(
                children: bodyStats.map((s) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GlassCard(
                      isDark: isDark,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              s['v']!,
                              style: AppTextStyles.h2(isDark).copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s['k']!,
                            style: AppTextStyles.caption(isDark).copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 14),

              // Fitness Goal Card
              GlassCard(
                isDark: isDark,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.tr('fitness_goal_label', lang),
                            style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 15.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                            );
                          },
                          child: Text(
                            AppLocalizations.tr('change_goal', lang),
                            style: const TextStyle(
                              color: AppColors.energeticOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.energeticOrange.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: const Text('🎯', style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.fitnessGoal,
                                style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 15.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${profile.commitDays} ${AppLocalizations.tr('sessions_per_week', lang)}',
                                style: AppTextStyles.muted(isDark).copyWith(fontSize: 12.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Achievements & Badges Card
              GlassCard(
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                  );
                },
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.energeticOrange.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🏅', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Achievements & Badges',
                            style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 15.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${appState.badges.where((b) => b.isUnlocked).length} of ${appState.badges.length} badges unlocked',
                            style: AppTextStyles.muted(isDark).copyWith(fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.energeticOrange),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Language Selection Card
              GlassCard(
                isDark: isDark,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Text('🌐', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppLocalizations.tr('settings_language', lang),
                                  style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.energeticOrange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isEn ? 'EN' : 'MS',
                            style: const TextStyle(
                              color: AppColors.energeticOrange,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildLanguageOption(
                            isSelected: !isEn,
                            label: 'Bahasa Melayu',
                            flag: '🇲🇾',
                            isDark: isDark,
                            onTap: () => appState.setLanguage('ms'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildLanguageOption(
                            isSelected: isEn,
                            label: 'English',
                            flag: '🇬🇧',
                            isDark: isDark,
                            onTap: () => appState.setLanguage('en'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Settings & Theme Card
              GlassCard(
                isDark: isDark,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.tr('settings_theme', lang),
                            style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          value: isDark,
                          activeColor: AppColors.energeticOrange,
                          onChanged: (_) => appState.toggleTheme(),
                        ),
                      ],
                    ),
                     Divider(color: isDark ? Colors.white.withOpacity(0.08) : AppColors.ink.withOpacity(0.06)),
                    // OpenRouter Multi-Model Selection
                    InkWell(
                      onTap: () => AiModelSelectorSheet.show(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(appState.currentAiModel.icon, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'AI Model (OpenRouter)',
                                      style: AppTextStyles.body(isDark).copyWith(fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  appState.currentAiModel.name,
                                  style: AppTextStyles.bodySemibold(isDark).copyWith(
                                    fontSize: 13,
                                    color: AppColors.energeticOrange,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right, size: 18, color: AppColors.energeticOrange),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(color: isDark ? Colors.white.withOpacity(0.08) : AppColors.ink.withOpacity(0.06)),
                    _buildSettingsRow(
                      'Cloud Database',
                      'Firebase (RTDB & Firestore)',
                      isDark,
                    ),
                    Divider(color: isDark ? Colors.white.withOpacity(0.08) : AppColors.ink.withOpacity(0.06)),
                    _buildSettingsRow(
                      AppLocalizations.tr('app_version', lang),
                      'FitQuest v1.0.0',
                      isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Reset / Logout Session Button
              Center(
                child: GestureDetector(
                  onTap: () async {
                    await appState.resetSession();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (route) => false,
                    );
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.errorRed.withOpacity(0.25)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.tr('logout_btn', lang),
                      style: const TextStyle(
                        color: AppColors.errorRed,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required bool isSelected,
    required String label,
    required String flag,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.energeticOrange
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.energeticOrange
                : (isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 5),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white.withOpacity(0.85) : AppColors.darkBgDeep),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body(isDark).copyWith(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.muted(isDark).copyWith(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
