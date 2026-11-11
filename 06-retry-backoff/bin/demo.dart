import 'dart:convert';

import 'package:retry_backoff/fake_server.dart';
import 'package:retry_backoff/retry.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // 529, 529, 429 with retry-after: 2, then success.
  final server = await startFakeAi([
    overloaded,
    overloaded,
    rateLimited(2),
    ok,
  ]);
  final client = http.Client();
  final url = Uri.parse('http://127.0.0.1:${server.port}/v1/messages');
  final sw = Stopwatch()..start();

  final response = await sendWithRetry(
    () => client.send(
      http.Request('POST', url)
        ..headers['content-type'] = 'application/json'
        ..body = jsonEncode({'model': 'any', 'messages': []}),
    ),
    onRetry: (n) => print(
      '[${sw.elapsedMilliseconds} ms] attempt ${n.attempt} got ${n.status}, '
      'waiting ${n.wait.inMilliseconds} ms',
    ),
  );

  print(
    '[${sw.elapsedMilliseconds} ms] ${response.statusCode}: ${response.body}',
  );
  client.close();
  await server.close();
}
