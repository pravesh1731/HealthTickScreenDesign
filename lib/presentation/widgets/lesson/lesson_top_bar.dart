import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../common/health_points_badge.dart';

class LessonTopBar extends StatelessWidget {
  const LessonTopBar({
    super.key,
    required this.progress,
    required this.points,
    required this.onBack,
  });

  final double progress;
  final int points;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      child: Row(
        children: [
          IconButton(tooltip: 'Back', onPressed: onBack, icon: const Icon(Icons.arrow_back)),
          const SizedBox(width: 8),
          Expanded(child: _ProgressPill(progress: progress)),
          const SizedBox(width: 16),
          HealthPointsBadge(points: points),
        ],
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  const _ProgressPill({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    // Never fully empty, so the pill is visible on the first page too.
    final visible = progress.clamp(0.08, 1.0);
    return Semantics(
      label: 'Lesson progress ${(progress * 100).round()} percent',
      child: Container(
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFDDDDDD),
          borderRadius: BorderRadius.circular(13),
        ),
        alignment: Alignment.centerLeft,
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          widthFactor: visible,
          heightFactor: 1,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.progressGreen,
              borderRadius: BorderRadius.circular(13),
            ),
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 13),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
