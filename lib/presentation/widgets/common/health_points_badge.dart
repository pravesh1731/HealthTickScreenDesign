import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Heart-with-pulse icon and a point count that animates when it changes.
class HealthPointsBadge extends StatelessWidget {
  const HealthPointsBadge({super.key, required this.points, this.size = 26});

  final int points;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$points health points',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.monitor_heart_rounded, color: AppColors.healthGreen, size: size),
          const SizedBox(width: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              '$points',
              key: ValueKey(points),
              style: TextStyle(
                color: AppColors.healthGreen,
                fontSize: size * 0.9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
