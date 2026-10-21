import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum GlassButtonVariant { primaryOrange, darkInk, glassSecondary, outline }

class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final GlassButtonVariant variant;
  final Widget? prefixIcon;
  final double height;
  final double borderRadius;
  final bool isLoading;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = GlassButtonVariant.primaryOrange,
    this.prefixIcon,
    this.height = 58.0,
    this.borderRadius = 20.0,
    this.isLoading = false,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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
    Color bg;
    Color textColor;
    Border? border;
    List<BoxShadow> shadows = [];

    switch (widget.variant) {
      case GlassButtonVariant.primaryOrange:
        bg = AppColors.energeticOrange;
        textColor = Colors.white;
        shadows = [
          BoxShadow(
            color: AppColors.energeticOrange.withOpacity(0.38),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ];
        break;
      case GlassButtonVariant.darkInk:
        bg = AppColors.ink;
        textColor = AppColors.warmWhite;
        shadows = [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.24),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ];
        break;
      case GlassButtonVariant.glassSecondary:
        bg = Colors.white.withOpacity(0.65);
        textColor = AppColors.ink;
        border = Border.all(color: Colors.white.withOpacity(0.85), width: 1.2);
        shadows = [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ];
        break;
      case GlassButtonVariant.outline:
        bg = Colors.transparent;
        textColor = AppColors.energeticOrange;
        border = Border.all(color: AppColors.energeticOrange, width: 1.5);
        break;
    }

    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onPressed != null ? (_) => _controller.reverse() : null,
      onTapCancel: widget.onPressed != null ? () => _controller.reverse() : null,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: border,
            boxShadow: shadows,
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.prefixIcon != null) ...[
                      widget.prefixIcon!,
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        widget.text,
                        style: AppTextStyles.bodySemibold(false).copyWith(
                          color: textColor,
                          fontSize: 16.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
