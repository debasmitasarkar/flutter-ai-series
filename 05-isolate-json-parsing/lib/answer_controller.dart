import 'dart:async';

import 'package:flutter/foundation.dart';

import 'answer.dart';
import 'parse.dart';

sealed class AnswerState {
  const AnswerState();
}

class Streaming extends AnswerState {
  const Streaming(this.charsSoFar);
  final int charsSoFar;
}

class Ready extends AnswerState {
  const Ready(this.answer);
  final ProductAnswer answer;
}

class Failed extends AnswerState {
  const Failed(this.error);
  final Object error;
}

/// Collects a streamed structured-output reply, then parses it once, off the
/// main isolate when it's big enough to matter.
class AnswerController {
  final state = ValueNotifier<AnswerState>(const Streaming(0));
  final _buffer = StringBuffer();
  StreamSubscription<String>? _sub;

  void listen(Stream<String> chunks) {
    _sub = chunks.listen(
      (chunk) {
        _buffer.write(chunk);
        state.value = Streaming(_buffer.length);
      },
      onError: (Object e) => state.value = Failed(e),
      onDone: _parse,
      cancelOnError: true,
    );
  }

  Future<void> _parse() async {
    final raw = _buffer.toString();
    _buffer.clear();
    try {
      state.value = Ready(await parseAnswerSmart(raw));
    } catch (e) {
      state.value = Failed(e);
    }
  }

  void dispose() {
    _sub?.cancel();
    state.dispose();
  }
}
