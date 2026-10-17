import 'content.dart';
import 'journey_config.dart';

enum LessonState { completed, available, locked }

enum DayState { locked, inProgress, completed }

class BuiltLesson {
  const BuiltLesson({
    required this.id,
    required this.template,
    required this.state,
    required this.statusId,
    required this.dayId,
    required this.dayNumber,
    required this.nextLessonId,
  });

  final String id;
  final LessonTemplate template;
  final LessonState state;
  final String statusId;
  final String dayId;
  final int dayNumber;
  final String? nextLessonId;

  Map<String, dynamic> toSummaryJson() => {'id': id, 'title': template.title, 'state': state.name};

  Map<String, dynamic> toDetailJson() => {
    ...toSummaryJson(),
    'statusId': statusId,
    'dayId': dayId,
    'dayNumber': dayNumber,
    'nextLessonId': nextLessonId,
    'pages': [for (final page in template.pages) page.toJson()],
  };
}

class BuiltDay {
  const BuiltDay({
    required this.id,
    required this.dayNumber,
    required this.emoji,
    required this.state,
    required this.lessons,
  });

  final String id;
  final int dayNumber;
  final String emoji;
  final DayState state;
  final List<BuiltLesson> lessons;

  Map<String, dynamic> toJson() => {
    'id': id,
    'dayNumber': dayNumber,
    'emoji': emoji,
    'state': state.name,
    'lessons': [for (final lesson in lessons) lesson.toSummaryJson()],
  };
}

class BuiltStatus {
  const BuiltStatus({required this.config, required this.days});

  final StatusConfig config;
  final List<BuiltDay> days;

  bool get isUnlocked => days.any((day) => day.state != DayState.locked);

  Map<String, dynamic> toJson() => {
    ...config.toJson(),
    'isUnlocked': isUnlocked,
    'days': [for (final day in days) day.toJson()],
  };
}

/// A fully resolved journey for one user at one point in time.
class JourneySnapshot {
  JourneySnapshot(this.statuses)
    : lessonsById = {
        for (final status in statuses)
          for (final day in status.days)
            for (final lesson in day.lessons) lesson.id: lesson,
      };

  final List<BuiltStatus> statuses;
  final Map<String, BuiltLesson> lessonsById;

  Iterable<BuiltDay> get _allDays => statuses.expand((status) => status.days);

  /// The day the user should work on next: the first unlocked day that is not
  /// finished, or the last unlocked day when everything is done.
  BuiltDay? get currentDay {
    final unlocked = _allDays.where((day) => day.state != DayState.locked).toList();
    if (unlocked.isEmpty) return null;
    return unlocked.firstWhere(
      (day) => day.state == DayState.inProgress,
      orElse: () => unlocked.last,
    );
  }
}

/// Pure function from (config, content, progress) to a journey. Keeping it
/// free of I/O makes the unlock rules trivial to unit test.
JourneySnapshot buildJourney({
  required JourneyConfig config,
  required ContentCatalog content,
  required Set<String> completedLessonIds,
  required int unlockedCircles,
}) {
  var dayNumber = 0;
  final statuses = <BuiltStatus>[];

  for (final status in config.statuses) {
    final templates = content.daysFor(status.id);
    final days = <BuiltDay>[];

    for (var index = 0; index < status.circleCount; index++) {
      dayNumber++;
      final dayId = '${status.id}-d${index + 1}';
      final isUnlocked = dayNumber <= unlockedCircles;
      // No authored content for this circle yet: it is drawn, but empty.
      final template = index < templates.length ? templates[index] : null;
      final lessonKeys = template?.lessonKeys ?? const <String>[];

      final lessonIds = [for (var i = 0; i < lessonKeys.length; i++) '$dayId-l${i + 1}'];

      var blocked = !isUnlocked;
      final lessons = <BuiltLesson>[];
      for (var i = 0; i < lessonKeys.length; i++) {
        final id = lessonIds[i];
        final LessonState state;
        if (completedLessonIds.contains(id) && isUnlocked) {
          state = LessonState.completed;
        } else if (blocked) {
          state = LessonState.locked;
        } else {
          state = LessonState.available;
          blocked = true; // Lessons inside a day are unlocked one at a time.
        }
        lessons.add(
          BuiltLesson(
            id: id,
            template: content.lessons[lessonKeys[i]]!,
            state: state,
            statusId: status.id,
            dayId: dayId,
            dayNumber: dayNumber,
            nextLessonId: i + 1 < lessonIds.length ? lessonIds[i + 1] : null,
          ),
        );
      }

      final allDone =
          lessons.isNotEmpty && lessons.every((lesson) => lesson.state == LessonState.completed);
      days.add(
        BuiltDay(
          id: dayId,
          dayNumber: dayNumber,
          emoji: template?.emoji ?? '⭐',
          state: !isUnlocked
              ? DayState.locked
              : (allDone ? DayState.completed : DayState.inProgress),
          lessons: lessons,
        ),
      );
    }
    statuses.add(BuiltStatus(config: status, days: days));
  }
  return JourneySnapshot(statuses);
}
