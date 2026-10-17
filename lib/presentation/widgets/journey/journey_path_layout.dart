import 'dart:math';
import 'dart:ui';

/// Geometry of one status section: where each circle goes and the road that
/// connects them. Pure maths (no widgets), so it is easy to unit test.
///
/// Circles follow the original app's pattern, one centred circle then a
/// left/right pair, and the road swings out to the screen edge between rows:
///
/// ```
///          ╭──────( 0 )            row 0  centre
///         │
///          ╰─( 1 )────( 2 )─╮      row 1  left, right (straight between)
///                            │
///             ( 3 )─────────╯      row 2  centre
///    ...
/// ```
class JourneyPathLayout {
  const JourneyPathLayout._({
    required this.centers,
    required this.size,
    required this.links,
    required this.exit,
  });

  static const nodeDiameter = 96.0;
  static const topInset = 100.0;
  static const bottomTail = 70.0;
  static const emptyHeight = 140.0;

  // Horizontal positions as fractions of the width.
  static const _centerX = 0.5;
  static const _leftX = 0.32;
  static const _rightX = 0.68;
  static const _leftTurnX = 0.11; // outermost point of a left U-turn
  static const _rightTurnX = 0.89; // outermost point of a right U-turn

  /// Circle centres, in day order.
  final List<Offset> centers;
  final Size size;

  /// The road between neighbouring circles: `links[i]` joins circle `i` to
  /// circle `i + 1`. Kept as separate pieces so each one can be coloured by
  /// the user's progress.
  final List<Path> links;

  /// The road from the last circle down to the bottom centre, where the
  /// checkpoint (or next status) continues it.
  final Path exit;

  /// The whole road as one path.
  Path get road {
    final road = Path();
    for (final piece in [...links, exit]) {
      road.addPath(piece, Offset.zero);
    }
    return road;
  }

  /// Vertical distance between rows; grows a little on wider screens.
  static double rowSpacingFor(double width) => (width * 0.46).clamp(150.0, 200.0);

  factory JourneyPathLayout.compute({required int count, required double width}) {
    final midX = width * _centerX;

    if (count == 0) {
      return JourneyPathLayout._(
        centers: const [],
        size: Size(width, emptyHeight),
        links: const [],
        exit: Path()
          ..moveTo(midX, 0)
          ..lineTo(midX, emptyHeight),
      );
    }

    final rowSpacing = rowSpacingFor(width);
    final centers = <Offset>[
      for (var index = 0; index < count; index++)
        Offset(
          width * [_centerX, _leftX, _rightX][index % 3],
          topInset + _rowOf(index) * rowSpacing,
        ),
    ];

    // The road must end on the centre line so the checkpoint can continue
    // it. A centred last circle is already there; otherwise the road makes
    // one more U-turn to reach the centre of the next (empty) row.
    final last = centers.last;
    final join = (count - 1) % 3 == 0 ? last : Offset(midX, last.dy + rowSpacing);
    final size = Size(width, join.dy + bottomTail);

    final links = <Path>[];
    for (var i = 1; i < count; i++) {
      final link = Path()..moveTo(centers[i - 1].dx, centers[i - 1].dy);
      _connect(link, centers[i - 1], centers[i], width);
      links.add(link);
    }

    final exit = Path()..moveTo(last.dx, last.dy);
    if (join != last) _connect(exit, last, join, width);
    exit.lineTo(midX, size.height);

    return JourneyPathLayout._(centers: centers, size: size, links: links, exit: exit);
  }

  /// Rows: every group of 3 circles takes 2 rows (centre, then the pair).
  static int _rowOf(int index) => (index ~/ 3) * 2 + (index % 3 == 0 ? 0 : 1);

  /// Extends [road] from [from] (its current end) to [to].
  ///
  /// - Same row (the left/right pair): a straight line.
  /// - Next row: a U-turn around the screen edge. Run horizontally to the
  ///   circle nearest that edge, sweep half an ellipse out to the edge and
  ///   back, then run horizontally into [to]. Every join is horizontal, so
  ///   the road never shows a kink.
  static void _connect(Path road, Offset from, Offset to, double width) {
    if ((from.dy - to.dy).abs() < 1) {
      road.lineTo(to.dx, to.dy);
      return;
    }

    final turnsLeft = from.dx < width / 2 || to.dx < width / 2;
    final pivotX = turnsLeft ? min(from.dx, to.dx) : max(from.dx, to.dx);
    final edgeX = width * (turnsLeft ? _leftTurnX : _rightTurnX);

    road
      ..lineTo(pivotX, from.dy)
      ..arcToPoint(
        Offset(pivotX, to.dy),
        radius: Radius.elliptical((pivotX - edgeX).abs(), (to.dy - from.dy) / 2),
        // Going down: a bulge to the left is anticlockwise on screen.
        clockwise: !turnsLeft,
      )
      ..lineTo(to.dx, to.dy);
  }
}
