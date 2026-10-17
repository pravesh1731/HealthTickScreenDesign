import 'validation.dart';

/// The journey's setup, read from `hardcoded/journey_config_data.dart`: the
/// statuses (levels), how many circles each has, and how many circles are
/// unlocked at the start.
class JourneyConfig {
  const JourneyConfig({
    required this.userName,
    required this.unlockedCircles,
    required this.statuses,
  });

  static const maxCirclesPerStatus = 60;

  final String userName;

  /// Circles unlocked at the start, counted across statuses in order.
  final int unlockedCircles;
  final List<StatusConfig> statuses;

  int get totalCircles => statuses.fold(0, (sum, status) => sum + status.circleCount);

  factory JourneyConfig.fromJson(Map<String, dynamic> json) {
    const path = 'config';
    final statuses = json
        .readList('statuses', path)
        .indexed
        .map(
          (entry) => StatusConfig.fromJson(
            (entry.$2 as Map).cast<String, dynamic>(),
            '$path.statuses[${entry.$1}]',
          ),
        )
        .toList();

    final ids = <String>{};
    for (final status in statuses) {
      if (!ids.add(status.id)) {
        throw ValidationException('$path.statuses', 'duplicate id "${status.id}"');
      }
    }

    return JourneyConfig(
      userName: json.readOptional<String>('userName', path) ?? 'there',
      unlockedCircles: requireRange(
        json.read<int>('unlockedCircles', path),
        '$path.unlockedCircles',
        min: 0,
        max: maxCirclesPerStatus * 10,
      ),
      statuses: statuses,
    );
  }
}

class StatusConfig {
  const StatusConfig({
    required this.id,
    required this.title,
    required this.level,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.circleCount,
  });

  final String id;
  final String title;
  final int level;
  final String subtitle;

  /// Name of a Material icon (e.g. "eco"); the app maps it to IconData.
  final String icon;
  final String color;
  final int circleCount;

  factory StatusConfig.fromJson(Map<String, dynamic> json, String path) {
    return StatusConfig(
      id: json.read<String>('id', path),
      title: json.read<String>('title', path),
      level: json.read<int>('level', path),
      subtitle: json.readOptional<String>('subtitle', path) ?? '',
      icon: json.readOptional<String>('icon', path) ?? '',
      color: json.readOptional<String>('color', path) ?? '#F2F2F2',
      circleCount: _validCircleCount(json.read<int>('circleCount', path), path),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'level': level,
    'subtitle': subtitle,
    'icon': icon,
    'color': color,
    'circleCount': circleCount,
  };

  static int _validCircleCount(int value, String path) =>
      requireRange(value, '$path.circleCount', min: 0, max: JourneyConfig.maxCirclesPerStatus);
}
