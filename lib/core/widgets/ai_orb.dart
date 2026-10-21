import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AiOrb extends StatefulWidget {
  final double size;
  final bool showGlow;
  final Widget? child;

  const AiOrb({
    super.key,
    this.size = 20.0,
    this.showGlow = false,
    this.child,
  });

  @override
  State<AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<AiOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            if (widget.showGlow)
              Container(
                width: widget.size * 1.5 * _pulseAnimation.value,
                height: widget.size * 1.5 * _pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.aiBlue.withOpacity(0.40),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.35, -0.32),
                  radius: 0.85,
                  colors: [
                    AppColors.aiBlueLight,
                    AppColors.aiBlue,
                    AppColors.aiBlueDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.aiBlue.withOpacity(0.45),
                    blurRadius: widget.size * 0.5,
                    offset: Offset(0, widget.size * 0.2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: widget.child,
            ),
          ],
        );
      },
    );
  }
}
