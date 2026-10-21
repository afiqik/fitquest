import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_logo.dart';
import '../../providers/app_state.dart';
import '../home/main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _localError;

  void _handleGoogleLogin() async {
    setState(() => _localError = null);
    final appState = context.read<AppState>();
    final success = await appState.signInWithGoogle();

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } else if (mounted && appState.authError != null) {
      setState(() => _localError = appState.authError);
    }
  }

  void _handleGuestLogin() async {
    setState(() => _localError = null);
    final appState = context.read<AppState>();
    await appState.signInAsGuest();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDark;
    final isEn = appState.isEnglish;
    final isLoading = appState.isAuthLoading;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBgDeep : AppColors.warmWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar with Back Button
              Row(
                children: [
                  AppBackButton(isDark: isDark),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 20),

              // Glowing App Logo
              const AppLogo(
                size: 96,
                showGlow: true,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                isEn ? 'Welcome to FitQuest' : 'Selamat Datang ke FitQuest',
                style: AppTextStyles.h1(isDark).copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  isEn
                      ? 'Sign in with your Google account to automatically sync your workouts, AI coaching, and nutrition.'
                      : 'Log masuk dengan akaun Google anda untuk menyelaraskan senaman, AI coach, dan pemakanan secara automatik.',
                  style: AppTextStyles.body(isDark).copyWith(
                    color: AppColors.mutedText(isDark),
                    fontSize: 14.5,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // Feature Highlights Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                  ),
                ),
                child: Column(
                  children: [
                    _FeatureTile(
                      icon: Icons.auto_awesome_rounded,
                      iconColor: AppColors.energeticOrange,
                      title: isEn ? 'AI-Powered Workouts' : 'Pelan Senaman Pintar AI',
                      description: isEn
                          ? 'Personalized adaptive routines customized for you'
                          : 'Rutin senaman adaptif khas mengikut badan anda',
                      isDark: isDark,
                    ),
                    const Divider(height: 24, thickness: 0.5),
                    _FeatureTile(
                      icon: Icons.camera_alt_rounded,
                      iconColor: AppColors.aiBlue,
                      title: isEn ? 'Food Vision Scanner' : 'Pengimbas Makanan AI',
                      description: isEn
                          ? 'Instant photo meal analysis & macro estimation'
                          : 'Kira kalori dan makronutrisi dari gambar makanan',
                      isDark: isDark,
                    ),
                    const Divider(height: 24, thickness: 0.5),
                    _FeatureTile(
                      icon: Icons.cloud_sync_rounded,
                      iconColor: AppColors.successGreen,
                      title: isEn ? 'Instant Cloud Sync' : 'Segerak Awan Automatik',
                      description: isEn
                          ? 'Never lose your workout progress and streak'
                          : 'Data senaman & rekod disimpan selamat di awan',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Error display if any
              if (_localError != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.errorRed.withOpacity(0.35)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.errorRed, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _localError!,
                          style: const TextStyle(
                            color: AppColors.errorRed,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Google Sign-In Button (Primary Action)
              InkWell(
                onTap: isLoading ? null : _handleGoogleLogin,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : const Color(0xFF131314),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? Colors.black : Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const _GoogleGLogo(size: 22),
                              const SizedBox(width: 14),
                              Text(
                                isEn ? 'Continue with Google' : 'Teruskan dengan Google',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF131314) : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Guest Login Button (Secondary Action)
              InkWell(
                onTap: isLoading ? null : _handleGuestLogin,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isEn ? 'Continue as Guest' : 'Masuk sebagai Tetamu',
                      style: TextStyle(
                        color: isDark ? AppColors.inkLight.withOpacity(0.85) : AppColors.ink.withOpacity(0.85),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Footer Note
              Text(
                isEn
                    ? 'By continuing, you agree to our Terms and Privacy Policy.'
                    : 'Dengan meneruskan, anda bersetuju dengan Terma & Dasar Privasi kami.',
                style: AppTextStyles.mono(
                  isDark,
                  fontSize: 11,
                  color: AppColors.subtleText(isDark),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool isDark;

  const _FeatureTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySemibold(isDark).copyWith(fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTextStyles.body(isDark).copyWith(
                  fontSize: 12.5,
                  color: AppColors.mutedText(isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Official 4-color Google "G" logo vector rendering
class _GoogleGLogo extends StatelessWidget {
  final double size;

  const _GoogleGLogo({this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleGLogoPainter(),
      ),
    );
  }
}

class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w / 2;
    final double strokeWidth = w * 0.21;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r - strokeWidth / 2);

    // Blue (Right arc & crossbar)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Red (Top arc)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Yellow (Left arc)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Green (Bottom arc)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Red arc: from -135 deg to -45 deg (~1.57 rad)
    canvas.drawArc(rect, -2.4, 1.4, false, redPaint);

    // Blue arc: from -45 deg to 45 deg
    canvas.drawArc(rect, -1.0, 1.3, false, bluePaint);

    // Green arc: from 45 deg to 135 deg
    canvas.drawArc(rect, 0.3, 1.4, false, greenPaint);

    // Yellow arc: from 135 deg to 225 deg
    canvas.drawArc(rect, 1.7, 1.6, false, yellowPaint);

    // Blue horizontal bar in the middle
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barRect = Rect.fromLTWH(
      cx - strokeWidth * 0.1,
      cy - strokeWidth / 2,
      r * 0.98,
      strokeWidth,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
