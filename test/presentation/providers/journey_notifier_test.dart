import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tick_demo/core/error/failures.dart';
import 'package:health_tick_demo/core/result/result.dart';
import 'package:health_tick_demo/di/providers.dart';
import 'package:health_tick_demo/presentation/providers/journey/journey_notifier.dart';
import 'package:health_tick_demo/presentation/providers/journey/journey_state.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeJourneyRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeJourneyRepository();
    // Only the repository is faked; the real use cases and notifier run.
    container = ProviderContainer.test(
      overrides: [journeyRepositoryProvider.overrideWithValue(repository)],
    );
  });

  Future<void> pump() => Future<void>.delayed(Duration.zero);

  JourneyState state() => container.read(journeyProvider);
  JourneyNotifier notifier() => container.read(journeyProvider.notifier);

  /// Builds the notifier, which starts the first load, and lets it finish.
  Future<void> start() async {
    container.listen(journeyProvider, (_, _) {});
    await pump();
  }

  test('loads the journey on start', () async {
    repository.responses.add(Ok(journeyFixture()));

    await start();

    expect(state().journey, journeyFixture());
    expect(state().isLoading, isFalse);
    expect(state().failure, isNull);
  });

  test('shows the failure when nothing could be loaded, then recovers on retry', () async {
    repository.responses
      ..add(const Err(NetworkFailure('offline')))
      ..add(Ok(journeyFixture()));

    await start();
    expect(state().journey, isNull);
    expect(state().failure, isA<NetworkFailure>());

    await notifier().load();
    expect(state().journey, journeyFixture());
    expect(state().failure, isNull);
  });

  test('keeps the current journey when a reload fails', () async {
    repository.responses
      ..add(Ok(journeyFixture()))
      ..add(const Err(ServerFailure('boom', statusCode: 500)));

    await start();
    await notifier().load();

    expect(state().journey, journeyFixture());
    expect(state().failure, isA<ServerFailure>());
  });

  test('reloads by itself when the server announces a change', () async {
    repository.responses
      ..add(Ok(journeyFixture(beginnerDays: 3)))
      ..add(Ok(journeyFixture(beginnerDays: 5)));
    await start();

    repository.changes.add(null);
    await pump();

    expect(state().journey!.statuses.first.days, hasLength(5));
    expect(repository.getCalls, 2);
  });
}
