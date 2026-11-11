import 'dart:convert';

import 'package:http/http.dart' as http;

import 'retry.dart';

/// The reply could not be read: a status we do not retry, or an error event mid-stream.
class StreamBroke implements Exception {
  StreamBroke(this.reason);
  final String reason;
  @override
  String toString() => 'Stream broke: $reason';
}

/// Streams Claude's text through your proxy. The retry only covers the part
/// before the first byte; after that, errors are the caller's call.
Stream<String> streamClaude(
  http.Client client,
  Uri proxy,
  String prompt, {
  Future<void>? cancelled,
  void Function(RetryNotice notice)? onRetry,
}) async* {
  final response = await openStreamWithRetry(
    () => client.send(
      http.Request('POST', proxy)
        ..headers['content-type'] = 'application/json'
        ..body = jsonEncode({
          'model': 'claude-sonnet-5-5',
          'max_tokens': 1024,
          'stream': true,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
    ),
    cancelled: cancelled,
    onRetry: onRetry,
  );
  if (response.statusCode != 200) {
    throw StreamBroke(
      'HTTP ${response.statusCode}: ${await response.stream.bytesToString()}',
    );
  }

  final lines = response.stream
      .transform(utf8.decoder)
      .transform(const LineSplitter());
  await for (final line in lines) {
    if (!line.startsWith('data: ')) continue;
    final event = jsonDecode(line.substring(6)) as Map<String, dynamic>;
    switch (event['type']) {
      case 'content_block_delta':
        final text = event['delta']?['text'];
        if (text is String) yield text;
      case 'error':
        // e.g. overloaded_error after a 200: the server gave up mid-answer.
        throw StreamBroke(event['error']?['type'] as String? ?? 'error');
    }
  }
}
