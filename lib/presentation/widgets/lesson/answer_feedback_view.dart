import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/lesson.dart';
import '../common/markdown_text.dart';
import 'lesson_page_layout.dart';

/// Shown after answering: "Oops..." for a wrong answer, a thumbs-up for a
/// right one, followed by the explanation.
class AnswerFeedbackView extends StatelessWidget {
  const AnswerFeedbackView({
    super.key,
    required this.page,
    required this.selectedOption,
    required this.onNext,
  });

  final QuestionLessonPage page;
  final int selectedOption;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final correct = page.isCorrect(selectedOption);
    final title = page.isOpinion
        ? 'Thanks for sharing!'
        : correct
        ? 'Spot on! You nailed it.'
        : 'Not quite, but I appreciate your effort.';

    return LessonPageLayout(
      ctaLabel: 'NEXT',
      onCta: onNext,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: correct ? const _ThumbsUp() : const _OopsSign()),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.3),
              ),
              if (page.explanation.isNotEmpty) ...[
                const SizedBox(height: 20),
                MarkdownText(page.explanation, style: const TextStyle(fontSize: 17, height: 1.45)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OopsSign extends StatelessWidget {
  const _OopsSign();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform.rotate(
          angle: -6 * pi / 180,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.ink, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('Oops...', style: TextStyle(fontSize: 18)),
          ),
        ),
        const Text('✋', style: TextStyle(fontSize: 54)),
      ],
    );
  }
}

class _ThumbsUp extends StatelessWidget {
  const _ThumbsUp();

  @override
  Widget build(BuildContext context) => const Text('👍', style: TextStyle(fontSize: 96));
}
