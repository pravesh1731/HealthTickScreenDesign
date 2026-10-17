import 'package:flutter_test/flutter_test.dart';
import 'package:health_tick_demo/data/dummy_api/server/content.dart';
import 'package:health_tick_demo/data/dummy_api/server/journey_builder.dart';
import 'package:health_tick_demo/data/dummy_api/server/journey_config.dart';
import 'package:health_tick_demo/data/dummy_api/server/validation.dart';

JourneyConfig config({int unlocked = 2, int beginner = 4, int insider = 3}) =>
    JourneyConfig.fromJson({
      'unlockedCircles': unlocked,
      'statuses': [
        {'id': 'beginner', 'title': 'Beginner', 'level': 1, 'circleCount': beginner},
        {'id': 'insider', 'title': 'Insider', 'level': 2, 'circleCount': insider},
      ],
    });

final content = ContentCatalog.fromJson({
  'lessons': {
    'a': {
      'title': 'A',
      'pages': [
        {'type': 'text', 'body': 'hi'},
      ],
    },
    'b': {
      'title': 'B',
      'pages': [
        {
          'type': 'question',
          'prompt': '?',
          'options': ['x', 'y'],
          'correctOptionIndex': 1,
        },
      ],
    },
  },
  'days': {
    'beginner': [
      {
        'lessons': ['a', 'b'],
      },
    ],
    'insider': [
      {
        'lessons': ['b'],
      },
    ],
  },
});

JourneySnapshot _build({
  required JourneyConfig config,
  required ContentCatalog content,
  required Set<String> completedLessonIds,
}) => buildJourney(
  config: config,
  content: content,
  completedLessonIds: completedLessonIds,
  unlockedCircles: config.unlockedCircles,
);

void main() {
  test('creates exactly circleCount days per status', () {
    final journey = _build(
      config: config(beginner: 5, insider: 2),
      content: content,
      completedLessonIds: {},
    );

    expect(journey.statuses.map((s) => s.days.length), [5, 2]);
    expect(journey.statuses.last.days.last.dayNumber, 7);
  });

  test('circles beyond the authored days have no lessons', () {
    final journey = _build(
      config: config(unlocked: 3, beginner: 3),
      content: content,
      completedLessonIds: {},
    );
    final days = journey.statuses.first.days;

    expect(days.first.lessons, hasLength(2)); // the one authored day
    expect(days[1].lessons, isEmpty);
    expect(days[2].lessons, isEmpty);
  });

  test('unlockedCircles counts across statuses', () {
    final journey = _build(
      config: config(unlocked: 5, beginner: 4),
      content: content,
      completedLessonIds: {},
    );

    final states = journey.statuses.expand((s) => s.days).map((d) => d.state).toList();
    expect(states.where((s) => s != DayState.locked), hasLength(5));
    expect(journey.statuses.last.isUnlocked, isTrue);
  });

  test('lessons in a day unlock one at a time', () {
    final day = _build(
      config: config(),
      content: content,
      completedLessonIds: {'beginner-d1-l1'},
    ).statuses.first.days.first;

    expect(day.lessons.map((l) => l.state), [LessonState.completed, LessonState.available]);
    expect(day.state, DayState.inProgress);
  });

  test('current day is the first unfinished unlocked day', () {
    final journey = _build(
      config: config(unlocked: 2),
      content: content,
      completedLessonIds: {'beginner-d1-l1', 'beginner-d1-l2'},
    );

    expect(journey.currentDay?.id, 'beginner-d2');
  });

  test('nothing is unlocked when unlockedCircles is 0', () {
    final journey = _build(config: config(unlocked: 0), content: content, completedLessonIds: {});

    expect(journey.currentDay, isNull);
    expect(journey.lessonsById.values.every((l) => l.state == LessonState.locked), isTrue);
  });

  group('config validation', () {
    test('rejects an out-of-range circle count with the field path', () {
      expect(
        () => config(beginner: 999),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.path,
            'path',
            'config.statuses[0].circleCount',
          ),
        ),
      );
    });

    test('rejects duplicate status ids', () {
      expect(
        () => JourneyConfig.fromJson({
          'unlockedCircles': 1,
          'statuses': [
            {'id': 'beginner', 'title': 'A', 'level': 1, 'circleCount': 1},
            {'id': 'beginner', 'title': 'B', 'level': 2, 'circleCount': 1},
          ],
        }),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects days that reference missing lessons', () {
      expect(
        () => ContentCatalog.fromJson({
          'lessons': <String, dynamic>{},
          'days': {
            'beginner': [
              {
                'lessons': ['missing'],
              },
            ],
          },
        }),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
