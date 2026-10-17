import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/journey.dart';
import 'journey_node.dart';
import 'journey_path_layout.dart';
import 'journey_road_painter.dart';

/// Anchors that let the page scroll to a circle and attach the lessons
/// popover to it.
class NodeAnchor {
  final key = GlobalKey();
  final link = LayerLink();
}

/// A status banner followed by its winding path of circles.
class JourneySection extends StatelessWidget {
  const JourneySection({
    super.key,
    required this.status,
    required this.exitReached,
    required this.anchorFor,
    required this.onDayTap,
  });

  final JourneyStatus status;

  /// Whether the next status has started, so the road out of this section
  /// is drawn as travelled (black).
  final bool exitReached;
  final NodeAnchor Function(String dayId) anchorFor;
  final ValueChanged<JourneyDay> onDayTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = JourneyPathLayout.compute(
          count: status.days.length,
          width: constraints.maxWidth,
        );
        const half = JourneyPathLayout.nodeDiameter / 2;

        return SizedBox.fromSize(
          size: layout.size,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: JourneyRoadPainter(
                    layout,
                    unlockedCircles: status.days.where((day) => !day.isLocked).length,
                    exitReached: exitReached,
                  ),
                ),
              ),
              if (status.days.isEmpty)
                const Center(
                  child: Text(
                    'New days are on their way ✨',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              for (final (index, day) in status.days.indexed)
                Positioned(
                  left: layout.centers[index].dx - half,
                  top: layout.centers[index].dy - half,
                  child: CompositedTransformTarget(
                    link: anchorFor(day.id).link,
                    child: JourneyNode(
                      key: anchorFor(day.id).key,
                      day: day,
                      onTap: () => onDayTap(day),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
