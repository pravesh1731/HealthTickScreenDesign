import 'package:equatable/equatable.dart';

enum LessonState { completed, available, locked }

enum DayState { locked, inProgress, completed }

class Journey extends Equatable {
  const Journey({
    required this.user,
    required this.unlockedCircles,
    required this.currentDayId,
    required this.statuses,
  });

  final UserSummary user;
  final int unlockedCircles;
  final String? currentDayId;
  final List<JourneyStatus> statuses;

  Iterable<JourneyDay> get allDays => statuses.expand((status) => status.days);

  JourneyDay? dayById(String id) {
    for (final day in allDays) {
      if (day.id == id) return day;
    }
    return null;
  }

  JourneyDay? get currentDay => currentDayId == null ? null : dayById(currentDayId!);

  /// True when every lesson available so far is done (the "You have
  /// completed your journey!" state on the Today screen). Unlocked circles
  /// without lessons yet don't count against it.
  bool get isUnlockedJourneyComplete {
    final lessons = allDays.where((day) => !day.isLocked).expand((day) => day.lessons);
    return lessons.isNotEmpty && lessons.every((lesson) => lesson.state == LessonState.completed);
  }

  @override
  List<Object?> get props => [user, unlockedCircles, currentDayId, statuses];
}

class UserSummary extends Equatable {
  const UserSummary({required this.name, required this.healthPoints});

  final String name;
  final int healthPoints;

  @override
  List<Object?> get props => [name, healthPoints];
}

/// A status section on the journey map (Beginner, Insider, ...).
class JourneyStatus extends Equatable {
  const JourneyStatus({
    required this.id,
    required this.title,
    required this.level,
    required this.subtitle,
    required this.icon,
    required this.colorHex,
    required this.isUnlocked,
    required this.days,
  });

  final String id;
  final String title;
  final int level;
  final String subtitle;

  /// Icon name chosen by the backend (e.g. "eco"); the UI maps it to an icon.
  final String icon;
  final String colorHex;
  final bool isUnlocked;
  final List<JourneyDay> days;

  @override
  List<Object?> get props => [id, title, level, subtitle, icon, colorHex, isUnlocked, days];
}

/// One circle on the map.
class JourneyDay extends Equatable {
  const JourneyDay({
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
  final List<LessonSummary> lessons;

  bool get isLocked => state == DayState.locked;
  bool get isCompleted => state == DayState.completed;

  int get completedLessons =>
      lessons.where((lesson) => lesson.state == LessonState.completed).length;

  double get progress => lessons.isEmpty ? 0 : completedLessons / lessons.length;

  /// What the main button of the day card opens: the next lesson to do, or
  /// the first lesson again when the day is finished ("Do it again").
  LessonSummary? get lessonToPlay {
    if (isLocked || lessons.isEmpty) return null;
    for (final lesson in lessons) {
      if (lesson.state == LessonState.available) return lesson;
    }
    return lessons.first;
  }

  @override
  List<Object?> get props => [id, dayNumber, emoji, state, lessons];
}

class LessonSummary extends Equatable {
  const LessonSummary({required this.id, required this.title, required this.state});

  final String id;
  final String title;
  final LessonState state;

  bool get canOpen => state != LessonState.locked;

  @override
  List<Object?> get props => [id, title, state];
}
