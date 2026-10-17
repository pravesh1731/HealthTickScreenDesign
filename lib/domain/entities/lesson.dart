import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.title,
    required this.dayNumber,
    required this.nextLessonId,
    required this.pages,
  });

  final String id;
  final String title;
  final int dayNumber;

  /// The next lesson of the same day, played by "Next Section".
  final String? nextLessonId;
  final List<LessonPage> pages;

  @override
  List<Object?> get props => [id, title, dayNumber, nextLessonId, pages];
}

/// The two page types a lesson is made of. Each finished page is worth 1
/// health point.
sealed class LessonPage extends Equatable {
  const LessonPage({required this.cta});

  final String cta;
}

class TextLessonPage extends LessonPage {
  const TextLessonPage({required this.emoji, required this.body, required super.cta});

  final String? emoji;

  /// Lightweight markdown: paragraphs, `- ` bullets, `1. ` lists, **bold**,
  /// *italic*.
  final String body;

  @override
  List<Object?> get props => [emoji, body, cta];
}

class QuestionLessonPage extends LessonPage {
  const QuestionLessonPage({
    required this.prompt,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required super.cta,
  });

  final String prompt;
  final List<String> options;

  /// `null` for opinion questions where every answer is accepted.
  final int? correctOptionIndex;
  final String explanation;

  bool get isOpinion => correctOptionIndex == null;

  bool isCorrect(int optionIndex) => isOpinion || optionIndex == correctOptionIndex;

  @override
  List<Object?> get props => [prompt, options, correctOptionIndex, explanation, cta];
}

class LessonCompletion extends Equatable {
  const LessonCompletion({
    required this.pointsEarned,
    required this.totalHealthPoints,
    required this.firstCompletion,
  });

  final int pointsEarned;
  final int totalHealthPoints;

  /// `false` when replaying a finished lesson ("Do it again"); no points then.
  final bool firstCompletion;

  @override
  List<Object?> get props => [pointsEarned, totalHealthPoints, firstCompletion];
}
