import 'package:flutter/material.dart';

import '../../../core/utils/markdown_lite.dart';

/// Renders lesson copy written in the markdown subset of [parseMarkdownLite].
class MarkdownText extends StatelessWidget {
  const MarkdownText(this.source, {super.key, this.style});

  final String source;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ?? const TextStyle(fontSize: 19, height: 1.45);
    final blocks = parseMarkdownLite(source);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, block) in blocks.indexed)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : _gapBefore(block, blocks[index - 1])),
            child: _buildBlock(block, base),
          ),
      ],
    );
  }

  double _gapBefore(MarkdownBlock block, MarkdownBlock previous) =>
      block is ParagraphBlock || previous is ParagraphBlock ? 16 : 10;

  Widget _buildBlock(MarkdownBlock block, TextStyle base) {
    final text = Text.rich(TextSpan(style: base, children: _spans(block.spans)));
    return switch (block) {
      ParagraphBlock() => text,
      BulletBlock() => _ListItem(marker: '•', style: base, child: text),
      NumberedBlock(:final number) => _ListItem(marker: '$number.', style: base, child: text),
    };
  }

  List<TextSpan> _spans(List<InlineSegment> segments) => [
    for (final segment in segments)
      TextSpan(
        text: segment.text,
        style: TextStyle(
          fontWeight: segment.bold ? FontWeight.w700 : null,
          fontStyle: segment.italic ? FontStyle.italic : null,
        ),
      ),
  ];
}

class _ListItem extends StatelessWidget {
  const _ListItem({required this.marker, required this.style, required this.child});

  final String marker;
  final TextStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 26, child: Text(marker, style: style)),
          Expanded(child: child),
        ],
      ),
    );
  }
}
