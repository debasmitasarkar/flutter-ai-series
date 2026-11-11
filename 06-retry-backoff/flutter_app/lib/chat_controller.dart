import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'claude_stream.dart';

sealed class ReplyState {
  const ReplyState();
}

class Waiting extends ReplyState {
  const Waiting();
}

class Busy extends ReplyState {
  const Busy(this.retryIn, this.attempt);
  final Duration retryIn;
  final int attempt;
}

class Streaming extends ReplyState {
  const Streaming(this.text);
  final String text;
}

class Done extends ReplyState {
  const Done(this.text);
  final String text;
}

/// [partial] is whatever arrived before it broke; empty if nothing did.
class Broken extends ReplyState {
  const Broken(this.partial, this.error);
  final String partial;
  final Object error;
}

class ChatController {
  ChatController(this._client, this._proxy);
  final http.Client _client;
  final Uri _proxy;

  final state = ValueNotifier<ReplyState>(const Waiting());
  StreamSubscription<String>? _sub;
  Completer<void>? _cancel;

  void ask(String prompt) {
    stop();
    final cancel = _cancel = Completer<void>();
    final buffer = StringBuffer();
    state.value = const Waiting();

    _sub =
        streamClaude(
          _client,
          _proxy,
          prompt,
          cancelled: cancel.future,
          onRetry: (n) => state.value = Busy(n.wait, n.attempt),
        ).listen(
          (chunk) {
            buffer.write(chunk);
            state.value = Streaming(buffer.toString());
          },
          onDone: () => state.value = Done(buffer.toString()),
          onError: (Object e) => state.value = Broken(buffer.toString(), e),
          cancelOnError: true,
        );
  }

  /// Back button, Stop button, new question: all end up here.
  void stop() {
    if (_cancel?.isCompleted == false) _cancel!.complete();
    _sub?.cancel();
  }

  void dispose() {
    stop();
    state.dispose();
  }
}
