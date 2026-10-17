/// A tiny, dependency-free parser for the subset of markdown used in lesson
/// content: paragraphs, `- ` bullets, `1. ` numbered items, **bold** and
/// *italic*. Anything it does not understand is kept as plain text.
sealed class MarkdownBlock {
  const MarkdownBlock(this.spans);

  final List<InlineSegment> spans;
}

final class ParagraphBlock extends MarkdownBlock {
  const ParagraphBlock(super.spans);
}

final class BulletBlock extends MarkdownBlock {
  const BulletBlock(super.spans);
}

final class NumberedBlock extends MarkdownBlock {
  const NumberedBlock(this.number, super.spans);

  final String number;
}

class InlineSegment {
  const InlineSegment(this.text, {this.bold = false, this.italic = false});

  final String text;
  final bool bold;
  final bool italic;
}

final _numbered = RegExp(r'^(\d+)\.\s+(.*)$');
final _bullet = RegExp(r'^[-•]\s+(.*)$');
// Markers must hug the text (`*word*`, not `5 * 3`), like CommonMark.
final _inline = RegExp(r'\*\*(?!\s)(.+?)(?<!\s)\*\*|\*(?![\s*])(.+?)(?<!\s)\*');

List<MarkdownBlock> parseMarkdownLite(String source) {
  final blocks = <MarkdownBlock>[];
  final paragraph = <String>[];

  void flushParagraph() {
    if (paragraph.isEmpty) return;
    blocks.add(ParagraphBlock(parseInline(paragraph.join('\n'))));
    paragraph.clear();
  }

  for (final rawLine in source.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) {
      flushParagraph();
      continue;
    }
    final numbered = _numbered.firstMatch(line);
    final bullet = _bullet.firstMatch(line);
    if (numbered != null) {
      flushParagraph();
      blocks.add(NumberedBlock(numbered.group(1)!, parseInline(numbered.group(2)!)));
    } else if (bullet != null) {
      flushParagraph();
      blocks.add(BulletBlock(parseInline(bullet.group(1)!)));
    } else {
      paragraph.add(line);
    }
  }
  flushParagraph();
  return blocks;
}

List<InlineSegment> parseInline(String text) {
  final segments = <InlineSegment>[];
  var cursor = 0;
  for (final match in _inline.allMatches(text)) {
    if (match.start > cursor) segments.add(InlineSegment(text.substring(cursor, match.start)));
    final bold = match.group(1);
    segments.add(
      bold != null ? InlineSegment(bold, bold: true) : InlineSegment(match.group(2)!, italic: true),
    );
    cursor = match.end;
  }
  if (cursor < text.length) segments.add(InlineSegment(text.substring(cursor)));
  return segments;
}
