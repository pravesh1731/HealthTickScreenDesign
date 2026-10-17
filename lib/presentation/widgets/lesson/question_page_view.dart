import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/lesson.dart';
import '../common/markdown_text.dart';
import 'lesson_page_layout.dart';

/// "Question" page: a prompt and single-choice options.
class QuestionPageView extends StatelessWidget {
  const QuestionPageView({
    super.key,
    required this.page,
    required this.selectedOption,
    required this.onSelect,
    required this.onSubmit,
  });

  final QuestionLessonPage page;
  final int? selectedOption;
  final ValueChanged<int> onSelect;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return LessonPageLayout(
      ctaLabel: page.cta,
      onCta: onSubmit,
      children: [
        const SizedBox(height: 12),
        MarkdownText(page.prompt),
        const SizedBox(height: 28),
        for (final (index, option) in page.options.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _OptionTile(
              label: option,
              selected: index == selectedOption,
              onTap: () => onSelect(index),
            ),
          ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 78),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.border,
              width: selected ? 2 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                    color: selected ? AppColors.ink : AppColors.muted,
                    fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? AppColors.ink : AppColors.border,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
