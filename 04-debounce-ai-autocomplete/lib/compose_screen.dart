import 'package:flutter/material.dart';

import 'autocomplete_controller.dart';
import 'suggester.dart';

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key, required this.suggester});
  final Suggester suggester;

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final _text = TextEditingController();
  late final _auto = AutocompleteController(_text, widget.suggester);

  @override
  void dispose() {
    _auto.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grey = Theme.of(context).hintColor;
    return Scaffold(
      appBar: AppBar(title: const Text('Compose')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _text,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Start typing...'),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String?>(
              valueListenable: _auto.ghost,
              builder: (_, ghost, __) => ghost == null
                  ? const SizedBox(height: 40)
                  : ActionChip(
                      avatar: const Icon(Icons.auto_awesome, size: 16),
                      label: Text('... $ghost', style: TextStyle(color: grey)),
                      onPressed: _auto.accept,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
