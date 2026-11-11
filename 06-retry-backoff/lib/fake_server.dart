import 'dart:convert';
import 'dart:io';

/// A tiny local "AI API" that answers from a script, so you can test
/// retries without an API key or a real outage.
/// Each entry is (status, headers, body).
Future<HttpServer> startFakeAi(
  List<(int, Map<String, String>, String)> script,
) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  var i = 0;
  server.listen((req) async {
    await req.drain<void>();
    final (status, headers, body) =
        script[i < script.length ? i : script.length - 1];
    i++;
    req.response.statusCode = status;
    headers.forEach(req.response.headers.set);
    req.response.headers.contentType = ContentType.json;
    req.response.write(body);
    await req.response.close();
  });
  return server;
}

final overloaded = (
  529,
  <String, String>{},
  jsonEncode({
    'type': 'error',
    'error': {'type': 'overloaded_error', 'message': 'Overloaded'},
  }),
);

(int, Map<String, String>, String) rateLimited(int seconds) => (
  429,
  {'retry-after': '$seconds'},
  jsonEncode({
    'type': 'error',
    'error': {'type': 'rate_limit_error', 'message': 'Rate limited'},
  }),
);

final geminiExhausted = (
  429,
  <String, String>{},
  jsonEncode({
    'error': {
      'code': 429,
      'status': 'RESOURCE_EXHAUSTED',
      'details': [
        {
          '@type': 'type.googleapis.com/google.rpc.RetryInfo',
          'retryDelay': '1.5s',
        },
      ],
    },
  }),
);

final ok = (
  200,
  <String, String>{},
  jsonEncode({
    'content': [
      {'type': 'text', 'text': 'Hello!'},
    ],
  }),
);
