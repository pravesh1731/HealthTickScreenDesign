import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_tick_demo/core/error/failures.dart';
import 'package:health_tick_demo/core/result/result.dart';
import 'package:health_tick_demo/di/providers.dart';
import 'package:health_tick_demo/domain/entities/lesson.dart';
import 'package:health_tick_demo/presentation/providers/lesson_player/lesson_player_notifier.dart';
import 'package:health_tick_demo/presentation/providers/lesson_player/lesson_player_state.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeLessonRepository repository;
  late ProviderContainer container;
  final provider = lessonPlayerProvider(lessonFixture.id);

  setUp(() {
    repository = FakeLessonRepository();
    container = ProviderContainer.test(
      overrides: [lessonRepositoryProvider.overrideWithValue(repository)],
    );
  });

  LessonPlayerState state() => container.read(provider);
  LessonPlayerNotifier player() => container.read(provider.notifier);

  /// Listening keeps the autoDispose provider alive; building it starts the
  /// lesson load, which is then allowed to finish.
  Future<void> start() async {
    container.listen(provider, (_, _) {});
    await Future<void>.delayed(Duration.zero);
  }

  const completion = LessonCompletion(pointsEarned: 2, totalHealthPoints: 2, firstCompletion: true);

  Future<void> playToLastQuestion() async {
    repository.lessonResponses.add(const Ok(lessonFixture));
    await start();
    player().continueFromText();
  }

  test('plays a text page and a question page, then saves the lesson', () async {
    repository.completeResponses.add(const Ok(completion));
    await playToLastQuestion();
    expect(state().points, 1);
    expect(state().currentPage, isA<QuestionLessonPage>());

    expect(player().submitAnswer(), isFalse, reason: 'nothing selected yet');

    player().selectOption(2);
    expect(player().submitAnswer(), isTrue);
    expect(state().showingFeedback, isTrue);
    expect(state().points, 2, reason: '1 point per finished page');

    player().continueFromFeedback();
    await Future<void>.delayed(Duration.zero);

    expect(state().stage, LessonStage.completed);
    expect(state().completion, completion);
    expect(repository.completeCalls, 1);
  });

  test('a failed save can be retried', () async {
    repository.completeResponses
      ..add(const Err(NetworkFailure('offline')))
      ..add(const Ok(completion));
    await playToLastQuestion();
    player()
      ..selectOption(2)
      ..submitAnswer()
      ..continueFromFeedback();
    await Future<void>.delayed(Duration.zero);

    expect(state().stage, LessonStage.submitFailed);
    expect(state().hasUnsavedProgress, isTrue);

    await player().retrySubmit();

    expect(state().stage, LessonStage.completed);
    expect(repository.completeCalls, 2);
  });

  test('surfaces a locked lesson as a load failure', () async {
    repository.lessonResponses.add(const Err(ForbiddenFailure('locked', code: 'LESSON_LOCKED')));

    await start();

    expect(state().stage, LessonStage.loadFailed);
    expect(state().failure, isA<ForbiddenFailure>());
  });
}
