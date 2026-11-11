import 'package:flutter/foundation.dart'; // ValueListenable: not in the article's imports
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import 'close_open_markdown.dart';
import 'split_stable.dart';

export 'close_open_markdown.dart';
export 'split_stable.dart';

class StreamingMarkdown extends StatefulWidget {
  const StreamingMarkdown({
    super.key,
    required this.text,
    required this.isDone,
  });

  final ValueListenable<String> text;
  final ValueListenable<bool> isDone;

  @override
  State<StreamingMarkdown> createState() => _StreamingMarkdownState();
}

class _StreamingMarkdownState extends State<StreamingMarkdown> {
  String _doneSrc = '';
  Widget? _doneWidget;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isDone,
      builder: (context, isDone, _) {
        if (isDone) {
          // Streaming finished: one clean parse, and now it's selectable.
          return MarkdownBody(data: widget.text.value, selectable: true);
        }
        return ValueListenableBuilder<String>(
          valueListenable: widget.text,
          builder: (context, src, _) {
            final parts = splitStable(src);
            if (parts.done != _doneSrc) {
              _doneSrc = parts.done;
              _doneWidget = MarkdownBody(data: parts.done);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_doneWidget != null) _doneWidget!,
                MarkdownBody(data: closeOpenMarkdown(parts.live)),
              ],
            );
          },
        );
      },
    );
  }
}
