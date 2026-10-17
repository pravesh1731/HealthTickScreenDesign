import 'validation.dart';

/// Hard-coded lesson library (see `hardcoded/lesson_content_data.dart`).
///
/// Day N of a status uses that status's N-th authored day. Circles beyond the
/// authored days have no lessons yet, so `circleCount` can still change freely
/// at runtime.
class ContentCatalog {
  const ContentCatalog({required this.lessons, required this.dayTemplates});

  final Map<String, LessonTemplate> lessons;
  final Map<String, List<DayTemplate>> dayTemplates;

  List<DayTemplate> daysFor(String statusId) => dayTemplates[statusId] ?? const [];

  factory ContentCatalog.fromJson(Map<String, dynamic> json) {
    const path = 'content';
    final lessonsJson = json.readObject('lessons', path);
    final lessons = {
      for (final entry in lessonsJson.entries)
        entry.key: LessonTemplate.fromJson(
          entry.key,
          (entry.value as Map).cast<String, dynamic>(),
          '$path.lessons.${entry.key}',
        ),
    };

    final daysJson = json.readObject('days', path);
    final dayTemplates = <String, List<DayTemplate>>{};
    for (final entry in daysJson.entries) {
      final days = (entry.value as List).indexed.map((day) {
        final dayPath = '$path.days.${entry.key}[${day.$1}]';
        final template = DayTemplate.fromJson((day.$2 as Map).cast<String, dynamic>(), dayPath);
        for (final key in template.lessonKeys) {
          if (!lessons.containsKey(key)) {
            throw ValidationException(dayPath, 'unknown lesson "$key"');
          }
        }
        return template;
      }).toList();
      dayTemplates[entry.key] = days;
    }

    return ContentCatalog(lessons: lessons, dayTemplates: dayTemplates);
  }
}

class DayTemplate {
  const DayTemplate({required this.emoji, required this.lessonKeys});

  final String emoji;
  final List<String> lessonKeys;

  factory DayTemplate.fromJson(Map<String, dynamic> json, String path) {
    final keys = json.readList('lessons', path).cast<String>();
    if (keys.isEmpty) throw ValidationException('$path.lessons', 'must not be empty');
    return DayTemplate(emoji: json.readOptional<String>('emoji', path) ?? '⭐', lessonKeys: keys);
  }
}

class LessonTemplate {
  const LessonTemplate({required this.key, required this.title, required this.pages});

  final String key;
  final String title;
  final List<PageTemplate> pages;

  factory LessonTemplate.fromJson(String key, Map<String, dynamic> json, String path) {
    final pages = json
        .readList('pages', path)
        .indexed
        .map(
          (page) => PageTemplate.fromJson(
            (page.$2 as Map).cast<String, dynamic>(),
            '$path.pages[${page.$1}]',
          ),
        )
        .toList();
    if (pages.isEmpty) throw ValidationException('$path.pages', 'must not be empty');
    return LessonTemplate(key: key, title: json.read<String>('title', path), pages: pages);
  }
}

sealed class PageTemplate {
  const PageTemplate();

  factory PageTemplate.fromJson(Map<String, dynamic> json, String path) {
    final type = json.read<String>('type', path);
    return switch (type) {
      'text' => TextPageTemplate.fromJson(json, path),
      'question' => QuestionPageTemplate.fromJson(json, path),
      _ => throw ValidationException('$path.type', 'unsupported page type "$type"'),
    };
  }

  Map<String, dynamic> toJson();
}

class TextPageTemplate extends PageTemplate {
  const TextPageTemplate({required this.emoji, required this.body, required this.cta});

  final String? emoji;
  final String body;
  final String cta;

  factory TextPageTemplate.fromJson(Map<String, dynamic> json, String path) => TextPageTemplate(
    emoji: json.readOptional<String>('emoji', path),
    body: json.read<String>('body', path),
    cta: json.readOptional<String>('cta', path) ?? 'CONTINUE',
  );

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'emoji': emoji, 'body': body, 'cta': cta};
}

class QuestionPageTemplate extends PageTemplate {
  const QuestionPageTemplate({
    required this.prompt,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.cta,
  });

  final String prompt;
  final List<String> options;

  /// `null` means an opinion question: every answer is accepted.
  final int? correctOptionIndex;
  final String explanation;
  final String cta;

  factory QuestionPageTemplate.fromJson(Map<String, dynamic> json, String path) {
    final options = json.readList('options', path).cast<String>();
    if (options.length < 2) {
      throw ValidationException('$path.options', 'needs at least 2 options');
    }
    final correct = json.readOptional<int>('correctOptionIndex', path);
    if (correct != null) {
      requireRange(correct, '$path.correctOptionIndex', min: 0, max: options.length - 1);
    }
    return QuestionPageTemplate(
      prompt: json.read<String>('prompt', path),
      options: options,
      correctOptionIndex: correct,
      explanation: json.readOptional<String>('explanation', path) ?? '',
      cta: json.readOptional<String>('cta', path) ?? 'SUBMIT',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'question',
    'prompt': prompt,
    'options': options,
    'correctOptionIndex': correctOptionIndex,
    'explanation': explanation,
    'cta': cta,
  };
}
