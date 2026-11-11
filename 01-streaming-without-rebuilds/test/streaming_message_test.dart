// Not from the article: small checks for the code it shows.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streaming_without_rebuilds/chat_screen.dart';
import 'package:streaming_without_rebuilds/fake_ask.dart';
import 'package:streaming_without_rebuilds/reply_bubble.dart';
import 'package:streaming_without_rebuilds/streaming_message.dart';

void main() {
  testWidgets('chunks are coalesced into one update per 32 ms', (tester) async {
    final m = StreamingMessage(id: 'a');
    var updates = 0;
    m.text.addListener(() => updates++);

    m.append('Hello');
    m.append(', ');
    m.append('world');
    expect(m.text.value, '');

    await tester.pump(const Duration(milliseconds: 40));
    expect(m.text.value, 'Hello, world');
    expect(updates, 1);
    m.dispose();
  });

  testWidgets('finish flushes what is pending and flips isDone',
      (tester) async {
    final m = StreamingMessage(id: 'b');
    m.append('partial');
    m.finish();
    expect(m.text.value, 'partial');
    expect(m.isDone.value, isTrue);
    m.dispose();
  });

  testWidgets('ReplyBubble shows the streamed fakeAsk reply', (tester) async {
    final m = StreamingMessage(id: 'c');
    fakeAsk('hi').listen(m.append, onDone: m.finish);
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ReplyBubble(message: m))),
    );
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.textContaining('wasted work.'), findsOneWidget);
    m.dispose();
  });

  testWidgets('ChatScreen builds with an empty list', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ChatScreen(ask: fakeAsk)));
    expect(find.byType(ReplyBubble), findsNothing);
  });
}
