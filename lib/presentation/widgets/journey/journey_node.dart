import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/journey.dart';
import 'journey_path_layout.dart';

/// One circle on the journey map. Locked days show a padlock; unlocked days
/// show their artwork with a ring that fills as lessons are completed.
class JourneyNode extends StatelessWidget {
  const JourneyNode({super.key, required this.day, required this.onTap});

  final JourneyDay day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Day ${day.dayNumber}, ${_stateLabel(day)}',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox.square(
          dimension: JourneyPathLayout.nodeDiameter,
          child: day.isLocked ? const _LockedFace() : _UnlockedFace(day: day),
        ),
      ),
    );
  }

  static String _stateLabel(JourneyDay day) => switch (day.state) {
    DayState.locked => 'locked',
    DayState.completed => 'completed',
    DayState.inProgress => '${day.completedLessons} of ${day.lessons.length} lessons done',
  };
}

class _LockedFace extends StatelessWidget {
  const _LockedFace();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.nodeRing, shape: BoxShape.circle),
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD0D0D0),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 5),
        ),
        child: const Icon(Icons.lock_rounded, color: AppColors.lockBlue, size: 40),
      ),
    );
  }
}

class _UnlockedFace extends StatelessWidget {
  const _UnlockedFace({required this.day});

  final JourneyDay day;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: day.progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, progress, _) => CustomPaint(painter: _ProgressRingPainter(progress)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFEEF2), Color(0xFFFAD3DD)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(day.emoji, style: const TextStyle(fontSize: 42)),
          ),
        ),
        if (day.isCompleted)
          const Positioned(
            right: -2,
            bottom: 2,
            child: CircleAvatar(
              radius: 13,
              backgroundColor: Colors.white,
              child: Icon(Icons.check_circle_rounded, color: AppColors.checkGreen, size: 24),
            ),
          ),
      ],
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 7.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawCircle(
      rect.center,
      rect.width / 2,
      Paint()
        ..color = AppColors.nodeRing
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (progress <= 0) return;
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress.clamp(0, 1),
      false,
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) => oldDelegate.progress != progress;
}
