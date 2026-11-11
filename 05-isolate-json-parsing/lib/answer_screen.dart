import 'package:flutter/material.dart';

import 'answer_controller.dart';

class AnswerScreen extends StatefulWidget {
  const AnswerScreen({super.key, required this.chunks});
  final Stream<String> chunks;

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final _controller = AnswerController();

  @override
  void initState() {
    super.initState();
    _controller.listen(widget.chunks);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: ValueListenableBuilder<AnswerState>(
        valueListenable: _controller.state,
        builder: (context, state, _) => switch (state) {
          Streaming(:final charsSoFar) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text('Receiving… ${(charsSoFar / 1024).toStringAsFixed(0)} KB'),
                ],
              ),
            ),
          Failed(:final error) => Center(child: Text('Could not read the answer: $error')),
          Ready(:final answer) => ListView.builder(
              itemCount: answer.products.length,
              itemBuilder: (context, i) {
                final p = answer.products[i];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text(p.why, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Text('${p.price.toStringAsFixed(0)} ${p.currency}'),
                );
              },
            ),
        },
      ),
    );
  }
}
