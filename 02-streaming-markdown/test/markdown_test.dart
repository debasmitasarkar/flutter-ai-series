// Not from the article: small checks for the code it shows.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streaming_markdown/fake_markdown_ask.dart';
import 'package:streaming_markdown/streaming_markdown.dart';

void main() {
  group('closeOpenMarkdown', () {
    test('closes open bold', () {
      expect(closeOpenMarkdown('**Impor'), '**Impor**');
    });
    test('closes open inline code', () {
      expect(closeOpenMarkdown('use `Value'), 'use `Value`');
    });
    test('closes open italic but not a bullet', () {
      expect(closeOpenMarkdown('a *32 ms'), 'a *32 ms*');
      expect(closeOpenMarkdown('* item'), '* item');
    });
    test('shows only the text of a half-typed link', () {
      expect(
        closeOpenMarkdown('Read [Flutter docs](https://'),
        'Read Flutter docs',
      );
    });
    test('closes an open code fence and skips inline fixes', () {
      expect(closeOpenMarkdown('```dart\nfinal a = *'), '```dart\nfinal a = *\n```');
    });
  });

  group('splitStable', () {
    test('cuts at the last blank line', () {
      final p = splitStable('one\n\ntwo');
      expect(p.done, 'one\n');
      expect(p.live, '\ntwo');
    });
    test('never cuts inside a code fence', () {
      final p = splitStable('```\na\n\nb');
      expect(p.done, '');
      expect(p.live, '```\na\n\nb');
    });
  });

  testWidgets('StreamingMarkdown renders the fake stream to the end',
      (tester) async {
    final text = ValueNotifier<String>('');
    final isDone = ValueNotifier<bool>(false);
    fakeMarkdownAsk('x').listen(
      (c) => text.value += c,
      onDone: () => isDone.value = true,
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: StreamingMarkdown(text: text, isDone: isDone),
        ),
      ),
    ));
    for (var i = 0; i < 200 && !isDone.value; i++) {
      await tester.pump(const Duration(milliseconds: 15));
    }
    await tester.pump();
    expect(isDone.value, isTrue);
    expect(find.textContaining('Only the bubble listens', findRichText: true),
        findsOneWidget);
  });
}
