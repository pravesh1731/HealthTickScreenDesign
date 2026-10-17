import 'package:flutter/material.dart';

import '../../../domain/entities/lesson.dart';
import '../common/markdown_text.dart';
import 'lesson_page_layout.dart';

/// "Normal text" page: an illustration, rich copy and a CTA.
class TextPageView extends StatelessWidget {
  const TextPageView({super.key, required this.page, required this.onContinue});

  final TextLessonPage page;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final emoji = page.emoji;
    return LessonPageLayout(
      ctaLabel: page.cta,
      onCta: onContinue,
      children: [
        if (emoji != null && emoji.isNotEmpty) ...[
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 110)),
          ),
          const SizedBox(height: 28),
        ],
        MarkdownText(page.body),
      ],
    );
  }
}
