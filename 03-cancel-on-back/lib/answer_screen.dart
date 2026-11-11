import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:streaming_markdown/streaming_markdown.dart';

import 'ai_call.dart';

class AnswerScreen extends StatefulWidget {
  const AnswerScreen({super.key, required this.prompt, required this.dio});
  final String prompt;
  final Dio dio;

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  late final AiCall _call;

  @override
  void initState() {
    super.initState();
    _call = AiCall(widget.prompt)..start(widget.dio);
  }

  @override
  void dispose() {
    _call.dispose(); // aborts the request, cancels the subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Answer'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _call.isDone,
            builder: (_, done, __) => done
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.stop_circle_outlined),
                    tooltip: 'Stop',
                    onPressed: () => _call.cancel('user tapped stop'),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamingMarkdown(text: _call.text, isDone: _call.isDone),
      ),
    );
  }
}
