import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/lesson.dart';
import '../providers/lesson_player/lesson_player_notifier.dart';
import '../providers/lesson_player/lesson_player_state.dart';
import '../widgets/common/app_snack_bar.dart';
import '../widgets/common/failure_view.dart';
import '../widgets/lesson/answer_feedback_view.dart';
import '../widgets/lesson/exit_lesson_sheet.dart';
import '../widgets/lesson/lesson_completed_view.dart';
import '../widgets/lesson/lesson_top_bar.dart';
import '../widgets/lesson/question_page_view.dart';
import '../widgets/lesson/text_page_view.dart';

class LessonPlayerPage extends ConsumerWidget {
  const LessonPlayerPage({super.key, required this.lessonId});

  final String lessonId;

  static Route<void> route({required String lessonId}) =>
      MaterialPageRoute(builder: (_) => LessonPlayerPage(lessonId: lessonId));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonPlayerProvider(lessonId));
    return PopScope(
      canPop: !state.hasUnsavedProgress,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await confirmExitLesson(context)) navigator.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (state.lesson != null)
                LessonTopBar(
                  progress: state.progress,
                  points: state.points,
                  onBack: () => Navigator.of(context).maybePop(),
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey((state.stage, state.pageIndex, state.showingFeedback)),
                    child: _StageBody(lessonId: lessonId, state: state),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageBody extends ConsumerWidget {
  const _StageBody({required this.lessonId, required this.state});

  final String lessonId;
  final LessonPlayerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.read(lessonPlayerProvider(lessonId).notifier);
    final navigator = Navigator.of(context);

    switch (state.stage) {
      case LessonStage.loading:
        return const Center(child: CircularProgressIndicator(color: AppColors.ink));

      case LessonStage.loadFailed:
        return FailureView(
          failure: state.failure!,
          onRetry: player.load,
          secondaryLabel: 'Back to journey',
          onSecondary: navigator.pop,
        );

      case LessonStage.submitting:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.ink),
              SizedBox(height: 16),
              Text('Saving your progress…', style: TextStyle(color: AppColors.muted)),
            ],
          ),
        );

      case LessonStage.submitFailed:
        // Shown with an explicit retry: losing a finished lesson silently
        // would be the worst outcome here.
        return FailureView(
          failure: state.failure!,
          onRetry: player.retrySubmit,
          secondaryLabel: 'Exit without saving',
          onSecondary: () async {
            if (await confirmExitLesson(context)) navigator.pop();
          },
        );

      case LessonStage.completed:
        final lesson = state.lesson!;
        final next = lesson.nextLessonId;
        return LessonCompletedView(
          completion: state.completion!,
          hasNextLesson: next != null,
          onNext: () => navigator.pushReplacement(LessonPlayerPage.route(lessonId: next!)),
          onFinish: navigator.pop,
        );

      case LessonStage.playing:
        return switch (state.currentPage!) {
          final TextLessonPage page => TextPageView(
            page: page,
            onContinue: player.continueFromText,
          ),
          final QuestionLessonPage page when state.showingFeedback => AnswerFeedbackView(
            page: page,
            selectedOption: state.selectedOption!,
            onNext: player.continueFromFeedback,
          ),
          final QuestionLessonPage page => QuestionPageView(
            page: page,
            selectedOption: state.selectedOption,
            onSelect: player.selectOption,
            onSubmit: () {
              if (!player.submitAnswer()) {
                showAppSnackBar(
                  context,
                  title: 'Hello!',
                  message: 'Please select an answer to the quiz to proceed.',
                );
              }
            },
          ),
        };
    }
  }
}
