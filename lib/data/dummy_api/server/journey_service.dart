import 'dart:async';

import 'content.dart';
import 'errors.dart';
import 'journey_builder.dart';
import 'journey_config.dart';

/// The dummy API's business logic. Combines the hard-coded config and
/// content with the user's progress, which is kept in memory (restarting the
/// app starts from scratch).
class JourneyService {
  JourneyService({required this.config, required this.content})
    : _unlockedCircles = config.unlockedCircles;

  final JourneyConfig config;
  final ContentCatalog content;

  final Set<String> _completedLessonIds = {};
  int _healthPoints = 0;
  int _unlockedCircles;
  final _changes = StreamController<void>.broadcast();

  /// Fires whenever the journey changes, so the app can reload it.
  Stream<void> get changes => _changes.stream;

  JourneySnapshot _snapshot() => buildJourney(
    config: config,
    content: content,
    completedLessonIds: _completedLessonIds,
    unlockedCircles: _unlockedCircles,
  );

  Map<String, dynamic> journeyJson() {
    final snapshot = _snapshot();
    return {
      'user': {'name': config.userName, 'healthPoints': _healthPoints},
      'unlockedCircles': _unlockedCircles,
      'currentDayId': snapshot.currentDay?.id,
      'statuses': [for (final status in snapshot.statuses) status.toJson()],
    };
  }

  BuiltLesson lesson(String id) {
    final lesson = _snapshot().lessonsById[id];
    if (lesson == null) throw NotFoundException('Lesson "$id" does not exist.');
    if (lesson.state == LessonState.locked) throw LessonLockedException(id);
    return lesson;
  }

  /// Marks a lesson as done. Each page is worth 1 health point, awarded only
  /// the first time. Finishing a whole circle unlocks the next one.
  Map<String, dynamic> completeLesson(String id) {
    final lesson = this.lesson(id);
    final points = lesson.template.pages.length;

    final firstCompletion = _completedLessonIds.add(id);
    if (firstCompletion) {
      _healthPoints += points;
      _unlockNextCircleIfFinished(lesson);
      _changes.add(null);
    }
    return {
      'pointsEarned': firstCompletion ? points : 0,
      'totalHealthPoints': _healthPoints,
      'firstCompletion': firstCompletion,
    };
  }

  /// When every lesson of the newest unlocked circle is done, unlock the next
  /// circle. Circles are numbered across statuses, so the last Beginner circle
  /// leads to the first Insider circle.
  void _unlockNextCircleIfFinished(BuiltLesson lesson) {
    if (lesson.dayNumber != _unlockedCircles) return;
    final day = _snapshot().statuses
        .expand((status) => status.days)
        .firstWhere((day) => day.id == lesson.dayId);
    if (day.state == DayState.completed) _unlockedCircles++;
  }

  Future<void> dispose() => _changes.close();
}
