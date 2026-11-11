// Not from the article: checks that AiCall streams, and that cancelling or
// leaving the screen stops the fake source. Uses real time (about 8 s total).
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cancel_on_back/ai_call.dart';
import 'package:cancel_on_back/answer_screen.dart';
import 'package:cancel_on_back/fake_sse_adapter.dart';

Dio fakeDio() => Dio(BaseOptions(baseUrl: 'https://proxy.test'))
  ..httpClientAdapter = FakeSseAdapter();

/// Captures debugPrint output; call the returned restore() before the test ends.
(List<String>, void Function()) captureDebugPrint() {
  final logs = <String>[];
  final old = debugPrint;
  debugPrint = (String? m, {int? wrapWidth}) => logs.add(m ?? '');
  return (logs, () => debugPrint = old);
}

void main() {
  test('streams the whole fake answer', () async {
    final call = AiCall('hi');
    await call.start(fakeDio());
    while (!call.isDone.value) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    expect(call.text.value, 'Sure, cancelling is two calls.');
    call.dispose();
  });

  test('cancel keeps the partial answer and stops the stream', () async {
    final (logs, restore) = captureDebugPrint();
    addTearDown(restore);
    final call = AiCall('hi');
    await call.start(fakeDio());
    await Future<void>.delayed(const Duration(milliseconds: 1000)); // 2 words
    call.cancel('user tapped stop');
    final partial = call.text.value;
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    expect(partial, 'Sure, ');
    expect(call.text.value, partial);
    expect(call.isDone.value, isTrue);
    expect(logs, contains('fakeAsk: stopped after 2 words'));
    call.dispose();
  });

  testWidgets('popping AnswerScreen cancels the call', (tester) async {
    final (logs, restore) = captureDebugPrint();
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: nav,
      home: const Scaffold(body: Text('home')),
    ));
    nav.currentState!.push(MaterialPageRoute<void>(
      builder: (_) => AnswerScreen(prompt: 'hi', dio: fakeDio()),
    ));
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1000)),
    );
    await tester.pump();
    expect(find.byTooltip('Stop'), findsOneWidget);

    nav.currentState!.pop();
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1200)),
    );
    restore();
    expect(logs.where((l) => l.startsWith('fakeAsk: stopped')), hasLength(1));
  });
}
