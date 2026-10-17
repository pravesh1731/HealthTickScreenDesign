import 'package:flutter_test/flutter_test.dart';
import 'package:health_tick_demo/data/models/journey_model.dart';
import 'package:health_tick_demo/domain/entities/journey.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('maps the backend payload to entities', () {
    final journey = JourneyModel.fromJson(journeyJson(beginnerDays: 4, unlocked: 2));

    expect(journey.statuses.map((s) => s.title), ['Beginner', 'Insider']);
    expect(journey.statuses.first.days, hasLength(4));
    expect(journey.statuses.last.days, isEmpty);
    expect(journey.currentDay?.id, 'beginner-d1');
    expect(journey.dayById('beginner-d3')!.isLocked, isTrue);
  });

  test('treats unknown states as locked instead of crashing', () {
    final json = journeyJson();
    final day = (json['statuses'] as List).first['days'][0] as Map<String, dynamic>;
    day['state'] = 'someFutureState';

    final journey = JourneyModel.fromJson(json);

    expect(journey.statuses.first.days.first.state, DayState.locked);
  });

  test('names the bad field when a required value is missing', () {
    final json = journeyJson();
    ((json['statuses'] as List).first['days'][1] as Map).remove('id');

    expect(
      () => JourneyModel.fromJson(json),
      throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('statuses[0]'))),
    );
  });

  test('day exposes progress and the lesson to continue with', () {
    final day = journeyFixture().statuses.first.days.first;

    expect(day.progress, 0.5);
    expect(day.lessonToPlay?.id, 'beginner-d1-l2');
  });
}
