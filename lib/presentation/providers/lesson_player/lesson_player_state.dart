import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/lesson.dart';

enum LessonStage { loading, loadFailed, playing, submitting, submitFailed, completed }

class LessonPlayerState extends Equatable {
  const LessonPlayerState({
    this.stage = LessonStage.loading,
    this.lesson,
    this.pageIndex = 0,
    this.selectedOption,
    this.showingFeedback = false,
    this.points = 0,
    this.completion,
    this.failure,
  });

  final LessonStage stage;
  final Lesson? lesson;
  final int pageIndex;

  /// Option picked on the current question page, before submitting.
  final int? selectedOption;

  /// True after a question was answered, while its explanation is shown.
  final bool showingFeedback;

  /// Health points shown in the top bar: +1 for every finished page.
  final int points;
  final LessonCompletion? completion;
  final Failure? failure;

  LessonPage? get currentPage {
    final pages = lesson?.pages;
    if (pages == null || pageIndex >= pages.length) return null;
    return pages[pageIndex];
  }

  double get progress {
    final count = lesson?.pages.length ?? 0;
    if (count == 0) return 0;
    if (stage == LessonStage.completed) return 1;
    return (pageIndex + (showingFeedback ? 0.5 : 0)) / count;
  }

  /// Whether leaving now would throw work away (asks for confirmation).
  bool get hasUnsavedProgress =>
      (stage == LessonStage.playing || stage == LessonStage.submitFailed) &&
      (pageIndex > 0 || showingFeedback || selectedOption != null);

  LessonPlayerState copyWith({
    LessonStage? stage,
    Lesson? lesson,
    int? pageIndex,
    int? Function()? selectedOption,
    bool? showingFeedback,
    int? points,
    LessonCompletion? completion,
    Failure? Function()? failure,
  }) => LessonPlayerState(
    stage: stage ?? this.stage,
    lesson: lesson ?? this.lesson,
    pageIndex: pageIndex ?? this.pageIndex,
    selectedOption: selectedOption != null ? selectedOption() : this.selectedOption,
    showingFeedback: showingFeedback ?? this.showingFeedback,
    points: points ?? this.points,
    completion: completion ?? this.completion,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [
    stage,
    lesson,
    pageIndex,
    selectedOption,
    showingFeedback,
    points,
    completion,
    failure,
  ];
}
