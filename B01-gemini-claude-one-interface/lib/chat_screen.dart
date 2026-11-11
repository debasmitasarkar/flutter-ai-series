import 'dart:async';

import 'package:flutter/material.dart';

import 'llm_client.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.clients});
  final List<LlmClient> clients;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late LlmClient _client = widget.clients.first;
  final _input = TextEditingController();
  final _reply = ValueNotifier<String>('');
  StreamSubscription<String>? _sub;

  void _send() {
    _sub?.cancel();
    _reply.value = '';
    _sub = _client.ask(_input.text).listen(
          (chunk) => _reply.value += chunk,
          onError: (Object e) => _reply.value += '\n\n⚠️ $e',
        );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _reply.dispose();
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SegmentedButton<LlmClient>(
          segments: [
            for (final c in widget.clients)
              ButtonSegment(value: c, label: Text(c.name)),
          ],
          selected: {_client},
          onSelectionChanged: (s) => setState(() => _client = s.first),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ValueListenableBuilder<String>(
                valueListenable: _reply,
                builder: (_, text, __) => SingleChildScrollView(
                  child: Text(text),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _input,
              onSubmitted: (_) => _send(),
              decoration: const InputDecoration(hintText: 'Ask something'),
            ),
          ),
        ],
      ),
    );
  }
}
