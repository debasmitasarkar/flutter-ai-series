import 'package:flutter/material.dart';

import 'streaming_message.dart';

class ReplyBubble extends StatelessWidget {
  const ReplyBubble({super.key, required this.message});

  final StreamingMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ValueListenableBuilder<String>(
          valueListenable: message.text,
          builder: (context, text, _) => Text(text),
        ),
      ),
    );
  }
}
