import 'dart:async';
import 'package:flutter/foundation.dart';

class StreamingMessage {
  StreamingMessage({required this.id});

  final String id;
  final ValueNotifier<String> text = ValueNotifier('');
  final ValueNotifier<bool> isDone = ValueNotifier(false);

  final StringBuffer _pending = StringBuffer();
  Timer? _flush;

  /// Append a chunk. Updates are coalesced so the widget repaints
  /// at most ~30 times a second, no matter how fast chunks arrive.
  void append(String chunk) {
    _pending.write(chunk);
    _flush ??= Timer(const Duration(milliseconds: 32), () {
      text.value = text.value + _pending.toString();
      _pending.clear();
      _flush = null;
    });
  }

  void finish() {
    _flush?.cancel();
    _flush = null;
    if (_pending.isNotEmpty) {
      text.value = text.value + _pending.toString();
      _pending.clear();
    }
    isDone.value = true;
  }

  void dispose() {
    _flush?.cancel();
    text.dispose();
    isDone.dispose();
  }
}
