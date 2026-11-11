import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'chat_controller.dart';

/// A fake proxy: two "overloaded" answers, then a real-looking SSE stream.
http.Client fakeBusyClaude() {
  var calls = 0;
  return MockClient.streaming((request, body) async {
    await body.drain<void>();
    calls++;
    if (calls <= 2) {
      return http.StreamedResponse(
        Stream.value(
          utf8.encode('{"type":"error","error":{"type":"overloaded_error"}}'),
        ),
        529,
      );
    }
    Stream<List<int>> sse() async* {
      for (final word in 'Retry worked, here is your answer.'.split(' ')) {
        await Future<void>.delayed(const Duration(milliseconds: 120));
        final event = {
          'type': 'content_block_delta',
          'delta': {'type': 'text_delta', 'text': '$word '},
        };
        yield utf8.encode(
          'event: content_block_delta\ndata: ${jsonEncode(event)}\n\n',
        );
      }
    }

    return http.StreamedResponse(
      sse(),
      200,
      headers: {'content-type': 'text/event-stream'},
    );
  });
}

void main() => runApp(
  MaterialApp(
    home: ChatScreen(
      controller: ChatController(
        fakeBusyClaude(),
        Uri.parse('https://your-proxy.example/claude'),
      ),
    ),
  ),
);

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.controller});
  final ChatController controller;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _question = 'What should I retry?';

  @override
  void initState() {
    super.initState();
    widget.controller.ask(_question);
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ask the model')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ValueListenableBuilder<ReplyState>(
          valueListenable: widget.controller.state,
          builder: (context, state, _) => switch (state) {
            Waiting() => const LinearProgressIndicator(),
            Busy(:final retryIn, :final attempt) => Text(
              'The model is busy. Trying again in '
              '${(retryIn.inMilliseconds / 1000).toStringAsFixed(1)} s (try ${attempt + 1})…',
            ),
            Streaming(:final text) || Done(:final text) => Text(text),
            Broken(:final partial) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (partial.isNotEmpty) Text(partial),
                const SizedBox(height: 12),
                Text(
                  partial.isEmpty
                      ? "Couldn't get an answer right now."
                      : 'The answer was cut off.',
                ),
                TextButton(
                  onPressed: () => widget.controller.ask(_question),
                  child: const Text('Try again'),
                ),
              ],
            ),
          },
        ),
      ),
    );
  }
}
