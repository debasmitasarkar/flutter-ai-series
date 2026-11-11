// Not from the article: replays the article's walk-through ("how do i stream ",
// then "tok", then a typo) against FakeSuggester and counts requests.
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debounce_ai_autocomplete/compose_screen.dart';
import 'package:debounce_ai_autocomplete/suggester.dart';

class CountingSuggester implements Suggester {
  final _inner = FakeSuggester();
  final asked = <String>[];
  final cancelled = <String>[];

  @override
  Future<String?> complete(String input, {CancelToken? cancelToken}) async {
    asked.add(input);
    final r = await _inner.complete(input, cancelToken: cancelToken);
    if (cancelToken?.isCancelled ?? false) cancelled.add(input);
    return r;
  }
}

void main() {
  testWidgets('boundary fetch, prefix reuse, divergence', (tester) async {
    final s = CountingSuggester();
    await tester.pumpWidget(MaterialApp(home: ComposeScreen(suggester: s)));
    final field = find.byType(TextField);

    await tester.enterText(field, 'how do i stream ');
    await tester.pump(const Duration(milliseconds: 150)); // boundary debounce
    expect(s.asked, ['how do i stream ']);
    await tester.pump(const Duration(milliseconds: 900)); // fake latency
    expect(find.textContaining('tokens in flutter'), findsOneWidget);

    // Typing what the model predicted: the ghost shrinks, no new request.
    for (final t in ['how do i stream t', 'how do i stream to', 'how do i stream tok']) {
      await tester.enterText(field, t);
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(s.asked, hasLength(1));
    expect(find.text('... ens in flutter without rebuilding the screen'),
        findsOneWidget);

    // A typo diverges: ghost goes away, mid-word waits 700 ms.
    await tester.enterText(field, 'how do i stream tokx');
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ActionChip), findsNothing);
    expect(s.asked, hasLength(1));
    await tester.pump(const Duration(milliseconds: 100));
    expect(s.asked, hasLength(2));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a new keystroke cancels the request in flight', (tester) async {
    final s = CountingSuggester();
    await tester.pumpWidget(MaterialApp(home: ComposeScreen(suggester: s)));
    final field = find.byType(TextField);

    await tester.enterText(field, 'debounce ');
    await tester.pump(const Duration(milliseconds: 200)); // fired, in flight
    await tester.enterText(field, 'debounce x');
    await tester.pump(const Duration(milliseconds: 10));
    expect(s.cancelled, ['debounce ']);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('accept appends the ghost text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ComposeScreen(suggester: FakeSuggester())),
    );
    await tester.enterText(find.byType(TextField), 'the user taps ');
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.tap(find.byType(ActionChip));
    await tester.pump();
    final tf = tester.widget<TextField>(find.byType(TextField));
    expect(tf.controller!.text, 'the user taps back and the request keeps running');
  });
}
