import 'package:flutter_test/flutter_test.dart';
import 'package:health_tick_demo/core/utils/markdown_lite.dart';

void main() {
  test('parses paragraphs, bullets and numbered items', () {
    final blocks = parseMarkdownLite('Intro line\n\n- first\n- second\n\n1. one\n2. two\n\nOutro');

    expect(blocks.map((b) => b.runtimeType), [
      ParagraphBlock,
      BulletBlock,
      BulletBlock,
      NumberedBlock,
      NumberedBlock,
      ParagraphBlock,
    ]);
    expect((blocks[4] as NumberedBlock).number, '2');
  });

  test('parses bold and italic inline segments', () {
    final segments = parseInline('A **bold** and *italic* word');

    expect(segments.map((s) => s.text), ['A ', 'bold', ' and ', 'italic', ' word']);
    expect(segments[1].bold, isTrue);
    expect(segments[3].italic, isTrue);
  });

  test('keeps unmatched markers as plain text instead of failing', () {
    final segments = parseInline('5 * 3 = 15 and **oops');

    expect(segments.map((s) => s.text).join(), '5 * 3 = 15 and **oops');
    expect(segments.every((s) => !s.bold && !s.italic), isTrue);
  });
}
