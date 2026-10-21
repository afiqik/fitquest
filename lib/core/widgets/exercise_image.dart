import 'dart:async';
import 'package:flutter/material.dart';

/// Maps exercise names to bundled demonstration photos.
///
/// Images live in `assets/exercises/<key>_0.jpg` (start position) and
/// `<key>_1.jpg` (end position). Source: free-exercise-db (public domain).
class ExerciseMedia {
  static const String _dir = 'assets/exercises';

  /// Returns the image key for a given exercise name, matched by keywords so
  /// that older saved plans (and AI-revised names) still resolve to a picture.
  static String keyFor(String exerciseName) {
    final n = exerciseName.toLowerCase();
    if (n.contains('shoulder tap')) return 'shoulder_tap';
    if (n.contains('plank')) return 'plank';
    if (n.contains('jumping jack') || n.contains('star jump')) return 'jumping_jacks';
    if (n.contains('mountain')) return 'mountain_climber';
    if (n.contains('high knee') || n.contains('skip')) return 'high_knees';
    if (n.contains('lunge')) return 'lunge';
    if (n.contains('bridge') || n.contains('glute')) return 'glute_bridge';
    if (n.contains('push')) return 'incline_pushup';
    if (n.contains('squat')) return 'squat';
    return 'stretch';
  }

  static String startFrame(String exerciseName) => '$_dir/${keyFor(exerciseName)}_0.jpg';
  static String endFrame(String exerciseName) => '$_dir/${keyFor(exerciseName)}_1.jpg';
}

/// Shows an exercise photo. When [animate] is true it alternates between the
/// start and end positions to demonstrate the movement.
class ExerciseImage extends StatefulWidget {
  final String exerciseName;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final bool animate;
  final BoxFit fit;

  const ExerciseImage({
    super.key,
    required this.exerciseName,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.animate = false,
    this.fit = BoxFit.cover,
  });

  @override
  State<ExerciseImage> createState() => _ExerciseImageState();
}

class _ExerciseImageState extends State<ExerciseImage> {
  Timer? _timer;
  bool _showEnd = false;

  @override
  void initState() {
    super.initState();
    _setupTimer();
  }

  @override
  void didUpdateWidget(covariant ExerciseImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate || oldWidget.exerciseName != widget.exerciseName) {
      _setupTimer();
    }
  }

  void _setupTimer() {
    _timer?.cancel();
    _showEnd = false;
    if (widget.animate) {
      _timer = Timer.periodic(const Duration(milliseconds: 1100), (_) {
        if (mounted) setState(() => _showEnd = !_showEnd);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = _showEnd
        ? ExerciseMedia.endFrame(widget.exerciseName)
        : ExerciseMedia.startFrame(widget.exerciseName);

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Image.asset(
            path,
            key: ValueKey(path),
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.black12,
              alignment: Alignment.center,
              child: const Icon(Icons.fitness_center_rounded, color: Colors.black38),
            ),
          ),
        ),
      ),
    );
  }
}
