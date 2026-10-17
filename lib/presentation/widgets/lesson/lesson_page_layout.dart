import 'package:flutter/material.dart';

import '../common/primary_button.dart';

/// Scrollable lesson content with the call-to-action pinned to the bottom,
/// shared by every page type so they all line up identically.
class LessonPageLayout extends StatelessWidget {
  const LessonPageLayout({
    super.key,
    required this.children,
    required this.ctaLabel,
    required this.onCta,
  });

  final List<Widget> children;
  final String ctaLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: PrimaryButton(label: ctaLabel, onPressed: onCta),
        ),
      ],
    );
  }
}
