import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_tick_demo/core/error/exceptions.dart';
import 'package:health_tick_demo/data/dummy_api/dummy_api_client.dart';
import 'package:health_tick_demo/data/dummy_api/hardcoded/journey_config_data.dart';
import 'package:health_tick_demo/data/dummy_api/hardcoded/lesson_content_data.dart';
import 'package:health_tick_demo/data/dummy_api/server/dummy_server.dart';
import 'package:health_tick_demo/data/models/journey_model.dart';
import 'package:health_tick_demo/data/models/lesson_model.dart';
import 'package:health_tick_demo/domain/entities/journey.dart';

void main() {
  late DummyServer server;
  late DummyApiClient api;

  setUp(() {
    server = DummyServer.withHardcodedData();
    api = DummyApiClient(server, delay: Duration.zero);
  });

  Future<Journey> journey() async => JourneyModel.fromJson(await api.getJson('journey'));

  /// Completes every lesson of [dayId], in order.
  Future<void> finishDay(String dayId) async {
    for (final lesson in (await journey()).dayById(dayId)!.lessons) {
      await api.postJson('lessons/${lesson.id}/complete');
    }
  }

  // Expected values come from the data files, so editing levels or content
  // doesn't break these tests.
  final config = jsonDecode(journeyConfigJson) as Map<String, dynamic>;
  final content = jsonDecode(lessonContentJson) as Map<String, dynamic>;

  test('serves the circle counts and unlocked count from the config', () async {
    final j = await journey();
    final statuses = config['statuses'] as List;

    expect(j.statuses.map((s) => s.id), statuses.map((s) => s['id']));
    expect(j.statuses.map((s) => s.days.length), statuses.map((s) => s['circleCount']));
    expect(j.allDays.where((d) => !d.isLocked), hasLength(config['unlockedCircles']));
  });

  test('circles without authored content have no lessons', () async {
    final authored = content['days'] as Map<String, dynamic>;
    for (final status in (await journey()).statuses) {
      final authoredDays = (authored[status.id] as List?)?.length ?? 0;
      for (final (index, day) in status.days.indexed) {
        expect(day.lessons.isNotEmpty, index < authoredDays, reason: day.id);
      }
    }
  });

  test('serves an unlocked lesson the app can parse', () async {
    final lesson = LessonModel.fromJson(await api.getJson('lessons/beginner-d1-l1'));

    expect(lesson.title, 'Welcome to Health Tick!');
    expect(lesson.pages, isNotEmpty);
  });

  test('a locked lesson is a 403 and an unknown one a 404', () async {
    await expectLater(
      api.getJson('lessons/beginner-d2-l1'),
      throwsA(isA<HttpStatusException>().having((e) => e.statusCode, 'statusCode', 403)),
    );
    await expectLater(
      api.getJson('lessons/nope'),
      throwsA(isA<HttpStatusException>().having((e) => e.statusCode, 'statusCode', 404)),
    );
  });

  test('completing a lesson gives 1 point per page, only the first time', () async {
    final first = await api.postJson('lessons/beginner-d1-l1/complete');
    final again = await api.postJson('lessons/beginner-d1-l1/complete');

    expect(first, {'pointsEarned': 2, 'totalHealthPoints': 2, 'firstCompletion': true});
    expect(again['pointsEarned'], 0);
  });

  test('finishing day 1 unlocks day 2, finishing day 2 unlocks day 3', () async {
    await finishDay('beginner-d1');
    expect((await journey()).unlockedCircles, 2);
    expect((await journey()).currentDayId, 'beginner-d2');

    await finishDay('beginner-d2');
    final after = await journey();
    expect(after.unlockedCircles, 3);
    expect(after.dayById('beginner-d3')!.lessons, isEmpty);
    expect(after.isUnlockedJourneyComplete, isTrue);
  });

  test('a partly finished day does not unlock the next one', () async {
    await api.postJson('lessons/beginner-d1-l1/complete');

    expect((await journey()).unlockedCircles, 1);
  });

  test('tells the app when the journey changes', () async {
    var signals = 0;
    server.service.changes.listen((_) => signals++);

    await api.postJson('lessons/beginner-d1-l1/complete');
    await api.postJson('lessons/beginner-d1-l1/complete'); // replay: nothing new
    await Future<void>.delayed(Duration.zero);

    expect(signals, 1);
  });
}
