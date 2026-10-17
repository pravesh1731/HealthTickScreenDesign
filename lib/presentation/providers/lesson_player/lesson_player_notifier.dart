import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/providers.dart';
import '../../../domain/entities/lesson.dart';
import '../../../domain/usecases/complete_lesson.dart';
import '../../../domain/usecases/get_lesson.dart';
import 'lesson_player_state.dart';

/// One player per lesson id. autoDispose: the state is thrown away when the
/// lesson screen closes, so reopening a lesson always starts fresh.
final lessonPlayerProvider = NotifierProvider.autoDispose
    .family<LessonPlayerNotifier, LessonPlayerState, String>(LessonPlayerNotifier.new);

class LessonPlayerNotifier extends Notifier<LessonPlayerState> {
  LessonPlayerNotifier(this.lessonId);

  final String lessonId;
  late GetLesson _getLesson;
  late CompleteLesson _completeLesson;

  @override
  LessonPlayerState build() {
    _getLesson = ref.watch(getLessonProvider);
    _completeLesson = ref.watch(completeLessonProvider);
    Future.microtask(load);
    return const LessonPlayerState();
  }

  Future<void> load() async {
    state = const LessonPlayerState();
    final result = await _getLesson(lessonId);
    if (!ref.mounted) return;
    state = result.fold(
      onSuccess: (lesson) => LessonPlayerState(stage: LessonStage.playing, lesson: lesson),
      onFailure: (failure) => LessonPlayerState(stage: LessonStage.loadFailed, failure: failure),
    );
  }

  /// "That's amazing" on a text page.
  void continueFromText() {
    final page = state.currentPage;
    if (state.stage != LessonStage.playing || page is! TextLessonPage) return;
    state = state.copyWith(points: state.points + 1);
    _advance();
  }

  void selectOption(int index) {
    final page = state.currentPage;
    if (state.stage != LessonStage.playing ||
        page is! QuestionLessonPage ||
        state.showingFeedback ||
        index < 0 ||
        index >= page.options.length) {
      return;
    }
    state = state.copyWith(selectedOption: () => index);
  }

  /// Returns `false` when nothing is selected yet, so the UI can nudge the
  /// user ("Please select an answer to the quiz to proceed").
  bool submitAnswer() {
    final page = state.currentPage;
    final selected = state.selectedOption;
    if (state.stage != LessonStage.playing || page is! QuestionLessonPage) return true;
    if (state.showingFeedback) return true;
    if (selected == null) return false;

    state = state.copyWith(showingFeedback: true, points: state.points + 1);
    return true;
  }

  /// "Next" on the answer explanation.
  void continueFromFeedback() {
    if (state.stage != LessonStage.playing || !state.showingFeedback) return;
    _advance();
  }

  Future<void> retrySubmit() => _submit();

  void _advance() {
    final lesson = state.lesson!;
    if (state.pageIndex + 1 < lesson.pages.length) {
      state = state.copyWith(
        pageIndex: state.pageIndex + 1,
        selectedOption: () => null,
        showingFeedback: false,
      );
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    if (state.stage == LessonStage.submitting) return;
    state = state.copyWith(stage: LessonStage.submitting, failure: () => null);
    final result = await _completeLesson(lessonId);
    if (!ref.mounted) return;
    state = result.fold(
      onSuccess: (completion) =>
          state.copyWith(stage: LessonStage.completed, completion: completion),
      onFailure: (failure) =>
          state.copyWith(stage: LessonStage.submitFailed, failure: () => failure),
    );
  }
}
