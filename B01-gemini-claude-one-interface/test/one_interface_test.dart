// Not from the article: the screen with FakeClient, and the real ClaudeClient
// against package:http's MockClient. No network, no keys, no Firebase.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:one_interface/chat_screen.dart';
import 'package:one_interface/claude_client.dart';
import 'package:one_interface/fake_client.dart';

String sse(String type, Map<String, Object?> data) =>
    'event: $type\ndata: ${jsonEncode({'type': type, ...data})}\n\n';

void main() {
  testWidgets('the screen streams from whichever client is selected',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ChatScreen(clients: [FakeClient('Fake'), FakeClient('Other')]),
    ));

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('I am Fake'), findsOneWidget);

    await tester.tap(find.text('Other'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('I am Other'), findsOneWidget);
  });

  test('ClaudeClient yields only text deltas and stops at message_stop',
      () async {
    late Map<String, Object?> sent;
    final mock = MockClient.streaming((req, body) async {
      sent = jsonDecode(await body.bytesToString()) as Map<String, Object?>;
      final events = [
        sse('message_start', {'message': {}}),
        sse('content_block_delta', {
          'delta': {'type': 'text_delta', 'text': 'Hello'},
        }),
        sse('ping', {}),
        sse('content_block_delta', {
          'delta': {'type': 'text_delta', 'text': ' there'},
        }),
        sse('message_stop', {}),
        sse('content_block_delta', {
          'delta': {'type': 'text_delta', 'text': ' (after stop)'},
        }),
      ];
      return http.StreamedResponse(
        Stream.fromIterable(events.map(utf8.encode)),
        200,
      );
    });
    final client = ClaudeClient(proxyUrl: 'https://proxy.test', client: mock);

    final text = await client.ask('hi').join();
    expect(text, 'Hello there');
    expect(sent['stream'], isTrue);
    expect(sent['system'], isNotNull);
  });

  test('ClaudeClient throws on a non-200 from the proxy', () {
    final mock = MockClient((_) async => http.Response('nope', 529));
    final client = ClaudeClient(proxyUrl: 'https://proxy.test', client: mock);
    expect(client.ask('hi').join(), throwsA(isA<http.ClientException>()));
  });
}
