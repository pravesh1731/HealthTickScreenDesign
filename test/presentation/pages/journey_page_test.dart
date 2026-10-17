import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tick_demo/app/app.dart';
import 'package:health_tick_demo/core/error/failures.dart';
import 'package:health_tick_demo/core/result/result.dart';
import 'package:health_tick_demo/di/providers.dart';
import 'package:health_tick_demo/presentation/widgets/journey/journey_node.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeJourneyRepository journeys;

  setUp(() => journeys = FakeJourneyRepository());

  // Pumps one frame, then far enough for route transitions to finish.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> openJourney(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journeyRepositoryProvider.overrideWithValue(journeys),
          lessonRepositoryProvider.overrideWithValue(FakeLessonRepository()),
        ],
        child: const HealthTickApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('JOURNEY'));
    await settle(tester);
  }

  testWidgets('draws one circle per day and opens the day popover', (tester) async {
    journeys.responses.add(Ok(journeyFixture(beginnerDays: 4)));
    await openJourney(tester);

    expect(find.text('Beginner'), findsOneWidget);
    expect(find.byType(JourneyNode), findsNWidgets(4));

    await tester.tap(find.byType(JourneyNode).first);
    await settle(tester);

    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.text('The 9 Keystone Habits'), findsWidgets);
  });

  testWidgets('re-renders when the backend changes the number of circles', (tester) async {
    journeys.responses
      ..add(Ok(journeyFixture(beginnerDays: 3)))
      ..add(Ok(journeyFixture(beginnerDays: 6)));
    await openJourney(tester);
    expect(find.byType(JourneyNode), findsNWidgets(3));

    journeys.changes.add(null); // the server says "the journey changed"
    await settle(tester);

    expect(find.byType(JourneyNode), findsNWidgets(6));
  });

  testWidgets('shows an error with retry when the journey cannot load', (tester) async {
    journeys.responses
      ..add(const Err(NetworkFailure('offline')))
      ..add(Ok(journeyFixture()));
    await openJourney(tester);

    expect(find.text("You're offline"), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await settle(tester);

    expect(find.byType(JourneyNode), findsNWidgets(3));
  });
}
