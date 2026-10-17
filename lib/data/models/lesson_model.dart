import 'dart:developer' as developer;

import '../../core/utils/json_reader.dart';
import '../../domain/entities/lesson.dart';

abstract final class LessonModel {
  static Lesson fromJson(Map<String, dynamic> json) {
    final pages = json.list('pages', _pageOrNull).nonNulls.toList();
    if (pages.isEmpty) {
      throw const FormatException('Lesson has no pages this app can display');
    }
    return Lesson(
      id: json.require<String>('id'),
      title: json.require<String>('title'),
      dayNumber: json.optional<int>('dayNumber') ?? 0,
      nextLessonId: json.optional<String>('nextLessonId'),
      pages: pages,
    );
  }

  /// Unknown page types are skipped rather than failing the whole lesson, so
  /// the backend can introduce new page types without breaking old app builds.
  static LessonPage? _pageOrNull(Map<String, dynamic> json) {
    final type = json.require<String>('type');
    switch (type) {
      case 'text':
        return TextLessonPage(
          emoji: json.optional<String>('emoji'),
          body: json.require<String>('body'),
          cta: json.optional<String>('cta') ?? 'CONTINUE',
        );
      case 'question':
        final options = json.require<List<dynamic>>('options').whereType<String>().toList();
        if (options.length < 2) {
          throw const FormatException('Question needs at least 2 options');
        }
        final correct = json.optional<int>('correctOptionIndex');
        if (correct != null && (correct < 0 || correct >= options.length)) {
          throw FormatException('correctOptionIndex $correct is out of range');
        }
        return QuestionLessonPage(
          prompt: json.require<String>('prompt'),
          options: options,
          correctOptionIndex: correct,
          explanation: json.optional<String>('explanation') ?? '',
          cta: json.optional<String>('cta') ?? 'SUBMIT',
        );
      default:
        developer.log('Skipping unsupported page type "$type"', name: 'lesson');
        return null;
    }
  }

  static LessonCompletion completionFromJson(Map<String, dynamic> json) => LessonCompletion(
    pointsEarned: json.require<int>('pointsEarned'),
    totalHealthPoints: json.require<int>('totalHealthPoints'),
    firstCompletion: json.optional<bool>('firstCompletion') ?? true,
  );
}
