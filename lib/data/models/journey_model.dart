import '../../core/utils/json_reader.dart';
import '../../domain/entities/journey.dart';

/// Maps the `/journey` payload to domain entities. Required fields throw a
/// [FormatException] (-> ParsingFailure); cosmetic fields fall back to
/// defaults so a small backend change cannot blank out the whole map.
abstract final class JourneyModel {
  static Journey fromJson(Map<String, dynamic> json) {
    final user = json.object('user');
    return Journey(
      user: UserSummary(
        name: user.optional<String>('name') ?? '',
        healthPoints: user.optional<int>('healthPoints') ?? 0,
      ),
      unlockedCircles: json.optional<int>('unlockedCircles') ?? 0,
      currentDayId: json.optional<String>('currentDayId'),
      statuses: json.list('statuses', _status),
    );
  }

  static JourneyStatus _status(Map<String, dynamic> json) => JourneyStatus(
    id: json.require<String>('id'),
    title: json.require<String>('title'),
    level: json.optional<int>('level') ?? 0,
    subtitle: json.optional<String>('subtitle') ?? '',
    icon: json.optional<String>('icon') ?? '',
    colorHex: json.optional<String>('color') ?? '',
    isUnlocked: json.optional<bool>('isUnlocked') ?? false,
    days: json.list('days', _day),
  );

  static JourneyDay _day(Map<String, dynamic> json) => JourneyDay(
    id: json.require<String>('id'),
    dayNumber: json.require<int>('dayNumber'),
    emoji: json.optional<String>('emoji') ?? '⭐',
    // An unknown state is treated as locked: the safe default.
    state: enumByName(DayState.values, json['state'], fallback: DayState.locked),
    lessons: json.list('lessons', lessonSummaryFromJson),
  );

  static LessonSummary lessonSummaryFromJson(Map<String, dynamic> json) => LessonSummary(
    id: json.require<String>('id'),
    title: json.require<String>('title'),
    state: enumByName(LessonState.values, json['state'], fallback: LessonState.locked),
  );
}
