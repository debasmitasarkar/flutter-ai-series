// Demo wiring, not from the article: one StreamingMessage fed by fakeAsk,
// shown in a ReplyBubble, so you can watch the coalesced updates run.
import 'package:flutter/material.dart';

import 'fake_ask.dart';
import 'reply_bubble.dart';
import 'streaming_message.dart';

void main() => runApp(const MaterialApp(home: DemoScreen()));

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final _message = StreamingMessage(id: 'demo');

  @override
  void initState() {
    super.initState();
    fakeAsk('hello').listen(
      _message.append,
      onDone: _message.finish,
    );
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Streaming without rebuilds')),
      body: ListView(children: [ReplyBubble(message: _message)]),
    );
  }
}
