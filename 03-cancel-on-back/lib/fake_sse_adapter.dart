// Not from the article. A dio adapter that plays the role of your server:
// it turns fakeAsk() into `data: ...` SSE lines, so the article's AiCall runs
// unchanged with no network and no API key.
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'fake_ask.dart';

class FakeSseAdapter implements HttpClientAdapter {
  /// How many requests reached the "server".
  int requests = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests++;
    final body = fakeAsk('${options.data}')
        .map((w) => Uint8List.fromList(utf8.encode('data: $w\n')));
    return ResponseBody(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: ['text/event-stream'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
