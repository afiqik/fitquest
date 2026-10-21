import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CircularTimer extends StatelessWidget {
  final double size;
  final int totalSeconds;
  final int remainingSeconds;
  final String statusText;
  final bool isResting;
  final bool isDark;

  const CircularTimer({
    super.key,
    this.size = 250.0,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.statusText,
    this.isResting = false,
    required this.isDark,
  });

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 
        ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    final ringColor = isResting ? AppColors.aiBlue : AppColors.energeticOrange;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: size * 0.9,
            height: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  ringColor.withOpacity(isDark ? 0.28 : 0.20),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Custom Ring Painter
          CustomPaint(
            size: Size(size, size),
            painter: _TimerRingPainter(
              progress: progress,
              ringColor: ringColor,
              trackColor: isDark 
                  ? Colors.white.withOpacity(0.08) 
                  : AppColors.ink.withOpacity(0.07),
              strokeWidth: 14.0,
            ),
          ),
          // Center Text Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(remainingSeconds),
                style: AppTextStyles.timer(isDark).copyWith(
                  fontSize: size * 0.24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                statusText.toUpperCase(),
                style: AppTextStyles.mono(
                  isDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedText(isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color trackColor;
  final double strokeWidth;

  _TimerRingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Active Arc
    final activePaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.trackColor != trackColor;
  }
}
