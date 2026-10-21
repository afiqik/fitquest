import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ai_orb.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/fitness_goal_selector.dart';
import '../../models/fitness_goal.dart';
import '../../providers/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late double _height;
  late double _weight;
  late String _goal;
  late int _days;

  @override
  void initState() {
    super.initState();
    final p = context.read<AppState>().profile;
    _height = p.height;
    _weight = p.weight;
    _goal = p.fitnessGoal;
    _days = p.commitDays;
  }

  double get _liveBmi {
    if (_height <= 0) return 0;
    final hInM = _height / 100.0;
    return _weight / (hInM * hInM);
  }

  String _getChangeDelta(AppState state, bool isEn) {
    final p = state.profile;
    final changes = <String>[];
    if (_weight != p.weight) {
      changes.add('weight ${p.weight.toInt()} → ${_weight.toInt()} kg');
    }
    if (_goal != p.fitnessGoal) {
      changes.add('goal ${p.fitnessGoal} → $_goal');
    }
    if (_days != p.commitDays) {
      changes.add('${p.commitDays} → $_days days/week');
    }
    if (_height != p.height) {
      changes.add('height ${p.height.toInt()} → ${_height.toInt()} cm');
    }

    if (changes.isNotEmpty) {
      return 'You changed ${changes.join(", ")}. Your AI plan will be recalibrated for optimal intensity.';
    }
    return 'No adjustments that affect your current workout plan.';
  }

  Future<void> _pickImage(AppState appState, ImageSource source) async {
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
        if (mounted) {
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
                    _pickImage(appState, ImageSource.camera);
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
                    _pickImage(appState, ImageSource.gallery);
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

  void _saveProfile() async {
    final appState = context.read<AppState>();
    final lang = appState.language;

    await appState.updateProfile(
      height: _height,
      weight: _weight,
      goal: _goal,
      days: _days,
    );
    await appState.generateAndSavePlan();

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.tr('profile_updated_toast', lang)),
        backgroundColor: AppColors.energeticOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;
    final lang = appState.language;
    final isEn = lang == 'en';
    final profile = appState.profile;
    final deltaText = _getChangeDelta(appState, isEn);

    final initial = profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'A';
    final hasPhoto = profile.photoPath != null &&
        profile.photoPath!.isNotEmpty &&
        File(profile.photoPath!).existsSync();

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
              const SizedBox(height: 18),

              // Title & Subtitle
              Text(
                AppLocalizations.tr('edit_profile_title', lang),
                style: AppTextStyles.h1(isDark).copyWith(fontSize: 30),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.tr('edit_profile_sub', lang),
                style: AppTextStyles.muted(isDark),
              ),
              const SizedBox(height: 20),

              // Avatar & Photo Edit Section
              Center(
                child: GestureDetector(
                  onTap: () => _showPhotoOptions(context, appState, isDark),
                  child: Stack(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: hasPhoto
                              ? null
                              : const LinearGradient(
                                  colors: [AppColors.orangeLight, AppColors.energeticOrange],
                                ),
                          border: Border.all(color: AppColors.energeticOrange, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.energeticOrange.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: hasPhoto
                              ? Image.file(
                                  File(profile.photoPath!),
                                  width: 86,
                                  height: 86,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.energeticOrange,
                            border: Border.all(
                              color: isDark ? AppColors.darkBgDeep : Colors.white,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  AppLocalizations.tr('change_photo_title', lang),
                  style: TextStyle(
                    color: AppColors.energeticOrange,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Live BMI Gauge Card
              GlassCard(
                isDark: isDark,
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.tr('current_bmi', lang),
                          style: AppTextStyles.caption(isDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _liveBmi.toStringAsFixed(1),
                          style: AppTextStyles.h1(isDark).copyWith(
                            fontSize: 30,
                            color: AppColors.energeticOrange,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.energeticOrange.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _liveBmi < 18.5
                            ? 'Underweight'
                            : (_liveBmi < 25 ? 'Normal' : (_liveBmi < 30 ? 'Overweight' : 'Obese')),
                        style: const TextStyle(
                          color: AppColors.energeticOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Weight Slider
              GlassCard(
                isDark: isDark,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Weight',
                          style: AppTextStyles.bodySemibold(isDark),
                        ),
                        Text(
                          '${_weight.toInt()} kg',
                          style: AppTextStyles.mono(isDark, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: _weight.clamp(40.0, 150.0),
                      min: 40.0,
                      max: 150.0,
                      activeColor: AppColors.energeticOrange,
                      onChanged: (v) => setState(() => _weight = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Height Slider
              GlassCard(
                isDark: isDark,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Height',
                          style: AppTextStyles.bodySemibold(isDark),
                        ),
                        Text(
                          '${_height.toInt()} cm',
                          style: AppTextStyles.mono(isDark, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: _height.clamp(130.0, 210.0),
                      min: 130.0,
                      max: 210.0,
                      activeColor: AppColors.aiBlue,
                      onChanged: (v) => setState(() => _height = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Goal Selector Section
              Text(
                'Select Fitness Goal',
                style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              FitnessGoalSelector(
                selectedGoal: FitnessGoal.fromString(_goal),
                onGoalSelected: (g) => setState(() => _goal = g.id),
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              // AI Delta Warning Card
              GlassCard(
                isDark: isDark,
                color: AppColors.aiBlue.withOpacity(0.08),
                borderColor: AppColors.aiBlue.withOpacity(0.25),
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AiOrb(size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PLAN IMPACT',
                            style: AppTextStyles.aiTag,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            deltaText,
                            style: AppTextStyles.body(isDark).copyWith(fontSize: 13.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save CTA
              GlassButton(
                text: 'Save & Recalibrate Plan',
                onPressed: _saveProfile,
                variant: GlassButtonVariant.primaryOrange,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
