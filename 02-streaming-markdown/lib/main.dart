// Demo wiring, not from the article: two notifiers (the `text` and `isDone`
// from Part 1) fed by fakeMarkdownAsk and rendered with StreamingMarkdown.
import 'package:flutter/material.dart';

import 'fake_markdown_ask.dart';
import 'streaming_markdown.dart';

void main() => runApp(const MaterialApp(home: DemoScreen()));

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final _text = ValueNotifier<String>('');
  final _isDone = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    fakeMarkdownAsk('hello').listen(
      (chunk) => _text.value += chunk,
      onDone: () => _isDone.value = true,
    );
  }

  @override
  void dispose() {
    _text.dispose();
    _isDone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Streaming Markdown')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: StreamingMarkdown(text: _text, isDone: _isDone),
      ),
    );
  }
}
