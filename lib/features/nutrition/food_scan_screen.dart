import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/ai_orb.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/glass_button.dart';
import '../../providers/app_state.dart';
import 'food_scanner_controller.dart';

class FoodScanScreen extends StatefulWidget {
  const FoodScanScreen({super.key});

  @override
  State<FoodScanScreen> createState() => _FoodScanScreenState();
}

class _FoodScanScreenState extends State<FoodScanScreen> {
  late final FoodScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FoodScannerController();
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _confirmAndAddMeal() {
    final res = _controller.result;
    if (res == null) return;

    final appState = context.read<AppState>();
    appState.addScannedFoodResult(res);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${res.foodName} (${res.calories} kcal) added to your nutrition log.'),
        backgroundColor: AppColors.energeticOrange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppState>().isDark;
    final state = _controller.state;
    final image = _controller.selectedImage;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Viewfinder / Preview Area
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: image != null
                  ? Image.file(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0, -0.2),
                          radius: 0.9,
                          colors: [
                            Color(0xFF2A2320),
                            Color(0xFF0C0A09),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: state == FoodScannerState.analyzing
                                  ? AppColors.aiBlue
                                  : Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: state == FoodScannerState.analyzing
                                ? const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AiOrb(size: 60, showGlow: true),
                                      SizedBox(height: 16),
                                      Text(
                                        'AI is analyzing the meal...',
                                        style: TextStyle(color: Colors.white, fontSize: 13),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        size: 48,
                                        color: Colors.white.withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Select or snap a photo of food',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.6),
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),

          // Dark gradient overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Top Header Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppBackButton(
                    isDark: true,
                    color: Colors.white.withOpacity(0.15),
                    iconColor: Colors.white,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.aiBlue.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AiOrb(size: 14),
                        SizedBox(width: 8),
                        Text(
                          'AI FOOD VISION',
                          style: TextStyle(
                            color: AppColors.aiBlueLight,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Sheet / Result Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.58,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161210) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildBottomContent(context, state, isDark),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomContent(BuildContext context, FoodScannerState state, bool isDark) {
    switch (state) {
      case FoodScannerState.idle:
      case FoodScannerState.cancelled:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Scan Food with AI',
              style: AppTextStyles.h2(isDark).copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Snap a photo of your meal or choose from gallery for automatic calorie & macro calculation.',
              style: AppTextStyles.muted(isDark).copyWith(fontSize: 13.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    text: 'Camera',
                    prefixIcon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: () => _controller.pickImage(ImageSource.camera),
                    variant: GlassButtonVariant.primaryOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassButton(
                    text: 'Gallery',
                    prefixIcon: Icon(
                      Icons.photo_library,
                      color: isDark ? Colors.white : AppColors.ink,
                      size: 20,
                    ),
                    onPressed: () => _controller.pickImage(ImageSource.gallery),
                    variant: GlassButtonVariant.glassSecondary,
                  ),
                ),
              ],
            ),
          ],
        );

      case FoodScannerState.selectingImage:
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.energeticOrange),
                SizedBox(height: 14),
                Text('Opening image picker...', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );

      case FoodScannerState.imageSelected:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Image Selected',
              style: AppTextStyles.h2(isDark).copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Confirm your meal image to start smart AI analysis.',
              style: AppTextStyles.muted(isDark).copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GlassButton(
              text: 'Analyze Food Now',
              prefixIcon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              onPressed: () => _controller.analyzeImage(),
              variant: GlassButtonVariant.primaryOrange,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    text: 'Retake Photo',
                    onPressed: () => _controller.pickImage(ImageSource.camera),
                    variant: GlassButtonVariant.glassSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GlassButton(
                    text: 'Reselect from Gallery',
                    onPressed: () => _controller.pickImage(ImageSource.gallery),
                    variant: GlassButtonVariant.glassSecondary,
                  ),
                ),
              ],
            ),
          ],
        );

      case FoodScannerState.analyzing:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AiOrb(size: 54, showGlow: true),
                const SizedBox(height: 16),
                Text(
                  'Recognizing Meal & Calculating Nutrition...',
                  style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'AI is extracting estimated calories, protein, carbs, and fat.',
                  style: AppTextStyles.muted(isDark).copyWith(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );

      case FoodScannerState.success:
        final res = _controller.result!;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Name & Tag
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        res.foodName,
                        style: AppTextStyles.h2(isDark).copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.energeticOrange.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              res.categoryTag,
                              style: const TextStyle(
                                color: AppColors.energeticOrange,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            res.servingSize,
                            style: AppTextStyles.muted(isDark).copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${res.calories} kcal',
                  style: AppTextStyles.mono(
                    isDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.energeticOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Macro Stats Breakdown Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.ink.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.ink.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNutrientStat('Protein', '${res.protein.toInt()}g', AppColors.energeticOrange, isDark),
                  _buildNutrientStat('Carbs', '${res.carbs.toInt()}g', AppColors.aiBlue, isDark),
                  _buildNutrientStat('Fat', '${res.fat.toInt()}g', AppColors.orangeLight, isDark),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Health Tip / AI Insight
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.aiBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.aiBlue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      res.healthTip,
                      style: AppTextStyles.body(isDark).copyWith(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Confirm & Add CTA
            GlassButton(
              text: 'Add to Today',
              prefixIcon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
              onPressed: _confirmAndAddMeal,
              variant: GlassButtonVariant.primaryOrange,
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => _controller.reset(),
                child: Text(
                  'Scan Again',
                  style: TextStyle(
                    color: AppColors.mutedText(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );

      case FoodScannerState.error:
        final err = _controller.errorMessage ?? 'Unable to analyze this image.';
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.errorRed.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.error_outline, color: AppColors.errorRed, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to Analyze Meal',
              style: AppTextStyles.h3(isDark).copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              err,
              style: AppTextStyles.muted(isDark).copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GlassButton(
              text: 'Try Again',
              prefixIcon: const Icon(Icons.refresh, color: Colors.white, size: 20),
              onPressed: () => _controller.retry(),
              variant: GlassButtonVariant.primaryOrange,
            ),
            const SizedBox(height: 8),
            GlassButton(
              text: 'Choose New Image',
              onPressed: () => _controller.reset(),
              variant: GlassButtonVariant.glassSecondary,
            ),
          ],
        );
    }
  }

  Widget _buildNutrientStat(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.mono(isDark, fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption(isDark)),
      ],
    );
  }
}
