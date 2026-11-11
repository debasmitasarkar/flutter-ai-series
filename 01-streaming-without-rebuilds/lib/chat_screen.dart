import 'dart:async';

import 'package:flutter/material.dart';

import 'reply_bubble.dart';
import 'streaming_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.ask});

  /// Any function that returns a stream of text chunks.
  /// google_generative_ai, firebase_ai, a raw SSE client, or a fake for tests.
  final Stream<String> Function(String prompt) ask;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messages = <StreamingMessage>[];
  final _scroll = ScrollController();
  StreamSubscription<String>? _sub;

  // The article leaves the input field out, so nothing in this file calls
  // _send yet. Wire it to your TextField's onSubmitted.
  // ignore: unused_element
  void _send(String prompt) {
    final reply = StreamingMessage(id: DateTime.now().toIso8601String());
    setState(() => _messages.add(reply)); // ONE rebuild, when the bubble appears

    _sub?.cancel();
    _sub = widget.ask(prompt).listen(
      (chunk) {
        reply.append(chunk);
        _scrollIfAtBottom();
      },
      onDone: reply.finish,
      onError: (_) => reply.finish(),
    );
  }

  void _scrollIfAtBottom() {
    if (!_scroll.hasClients) return;
    // Only follow the text if the user hasn't scrolled up to read something.
    if (_scroll.position.extentAfter < 80) {
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    for (final m in _messages) {
      m.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scroll,
      itemCount: _messages.length,
      itemBuilder: (_, i) => ReplyBubble(message: _messages[i]),
    );
  }
}
