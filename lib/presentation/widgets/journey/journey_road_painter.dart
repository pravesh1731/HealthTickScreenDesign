import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'journey_path_layout.dart';

/// Paints the road computed by [JourneyPathLayout], plus the connector from
/// the status banner down to the first circle.
///
/// The road shows progress: pieces leading to an unlocked circle are black,
/// the rest grey. So when day 2 unlocks, the road from day 1 to day 2 turns
/// black.
class JourneyRoadPainter extends CustomPainter {
  const JourneyRoadPainter(this.layout, {required this.unlockedCircles, required this.exitReached});

  final JourneyPathLayout layout;

  /// How many circles of this section are unlocked (always the first ones).
  final int unlockedCircles;

  /// Whether the road continues unlocked past this section, i.e. the next
  /// status has started. Colours the piece leading into the checkpoint.
  final bool exitReached;

  static const roadWidth = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final todo = _roadPaint(AppColors.road);
    final done = _roadPaint(AppColors.ink);

    for (final (index, link) in layout.links.indexed) {
      // links[i] leads to circle i + 1.
      canvas.drawPath(link, index + 1 < unlockedCircles ? done : todo);
    }
    canvas.drawPath(layout.exit, exitReached ? done : todo);

    if (layout.centers.isEmpty) return;
    // Stops at the circle's edge so it never shows through the ring.
    final first = layout.centers.first;
    canvas.drawLine(
      Offset(first.dx, 0),
      first.translate(0, -JourneyPathLayout.nodeDiameter / 2),
      Paint()
        ..color = unlockedCircles > 0 ? AppColors.ink : AppColors.road
        ..strokeWidth = 12,
    );
  }

  static Paint _roadPaint(Color color) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = roadWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  bool shouldRepaint(JourneyRoadPainter oldDelegate) =>
      oldDelegate.unlockedCircles != unlockedCircles ||
      oldDelegate.exitReached != exitReached ||
      oldDelegate.layout.size != layout.size ||
      !_sameCenters(oldDelegate.layout.centers, layout.centers);

  static bool _sameCenters(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
