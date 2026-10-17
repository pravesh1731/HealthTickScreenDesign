import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_tick_demo/presentation/widgets/journey/journey_path_layout.dart';

void main() {
  const width = 390.0;
  final rowSpacing = JourneyPathLayout.rowSpacingFor(width);

  test('places circles centre, left, right, repeating on alternating rows', () {
    final layout = JourneyPathLayout.compute(count: 5, width: width);
    final c = layout.centers;

    const fractions = [0.5, 0.32, 0.68, 0.5, 0.32];
    for (var i = 0; i < c.length; i++) {
      expect(c[i].dx, closeTo(width * fractions[i], 0.001));
    }
    expect(c[1].dy, c[2].dy, reason: 'the pair shares a row');
    expect(c[1].dy - c[0].dy, closeTo(rowSpacing, 0.001));
    expect(c[3].dy - c[2].dy, closeTo(rowSpacing, 0.001));
  });

  test('works for any number of circles', () {
    for (var count = 1; count <= 20; count++) {
      final layout = JourneyPathLayout.compute(count: count, width: width);
      expect(layout.centers, hasLength(count));
      expect(layout.size.height, greaterThan(layout.centers.last.dy));
    }
  });

  test('road stays on screen and ends at the bottom centre for the checkpoint', () {
    for (final count in [1, 2, 3, 4, 7]) {
      final layout = JourneyPathLayout.compute(count: count, width: width);
      final bounds = layout.road.getBounds();
      final metric = layout.road.computeMetrics().last;
      final end = metric.getTangentForOffset(metric.length)!.position;

      expect(bounds.left, greaterThanOrEqualTo(0));
      expect(bounds.right, lessThanOrEqualTo(width));
      expect(end.dx, closeTo(width / 2, 0.01));
      expect(end.dy, closeTo(layout.size.height, 0.01));
    }
  });

  test('U-turns swing out towards the screen edges', () {
    final layout = JourneyPathLayout.compute(count: 4, width: width);
    final bounds = layout.road.getBounds();

    expect(bounds.left, closeTo(width * 0.11, 1)); // left turn: centre -> left circle
    expect(bounds.right, closeTo(width * 0.89, 1)); // right turn: right circle -> centre
  });

  test('road is split into one link per pair of neighbours plus an exit', () {
    for (final count in [1, 2, 3, 7]) {
      final layout = JourneyPathLayout.compute(count: count, width: width);
      expect(layout.links, hasLength(count - 1));

      // Each link runs from one circle to the next, so it can be coloured
      // on its own as soon as the circle it leads to unlocks.
      for (final (i, link) in layout.links.indexed) {
        final metric = link.computeMetrics().single;
        expect(
          (metric.getTangentForOffset(0)!.position - layout.centers[i]).distance,
          lessThan(0.01),
        );
        final end = metric.getTangentForOffset(metric.length)!.position;
        expect((end - layout.centers[i + 1]).distance, lessThan(0.01));
      }

      final exit = layout.exit.computeMetrics().single;
      expect(
        (exit.getTangentForOffset(0)!.position - layout.centers.last).distance,
        lessThan(0.01),
      );
    }
  });

  test('an empty section is a short straight road', () {
    final layout = JourneyPathLayout.compute(count: 0, width: width);

    expect(layout.centers, isEmpty);
    expect(layout.road.getBounds(), const Rect.fromLTRB(width / 2, 0, width / 2, 140));
  });
}
