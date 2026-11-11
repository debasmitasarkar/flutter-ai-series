import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:retry_backoff/fake_server.dart';
import 'package:retry_backoff/retry.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  late HttpServer server;
  late http.Client client;
  tearDown(() async {
    client.close();
    await server.close(force: true);
  });

  Future<http.StreamedResponse> Function() poster() =>
      () => client.send(
        http.Request(
          'POST',
          Uri.parse('http://127.0.0.1:${server.port}/v1/messages'),
        )..body = '{}',
      );

  const fast = RetryPolicy(
    baseDelay: Duration(milliseconds: 10),
    maxDelay: Duration(milliseconds: 40),
  );

  test('529 twice, then 200', () async {
    server = await startFakeAi([overloaded, overloaded, ok]);
    client = http.Client();
    final notices = <RetryNotice>[];
    final r = await sendWithRetry(
      poster(),
      policy: fast,
      onRetry: notices.add,
      random: Random(1),
    );
    expect(r.statusCode, 200);
    expect(notices.map((n) => n.status), [529, 529]);
  });

  test('honours retry-after seconds', () async {
    server = await startFakeAi([rateLimited(1), ok]);
    client = http.Client();
    final notices = <RetryNotice>[];
    final sw = Stopwatch()..start();
    final r = await sendWithRetry(poster(), policy: fast, onRetry: notices.add);
    expect(r.statusCode, 200);
    expect(notices.single.wait, const Duration(seconds: 1));
    expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(1000));
  });

  test('reads Gemini retryDelay from the body', () async {
    server = await startFakeAi([geminiExhausted, ok]);
    client = http.Client();
    final notices = <RetryNotice>[];
    await sendWithRetry(poster(), policy: fast, onRetry: notices.add);
    expect(notices.single.wait, const Duration(milliseconds: 1500));
  });

  test('gives up when the server asks for too long', () async {
    server = await startFakeAi([rateLimited(60), ok]);
    client = http.Client();
    expect(
      () => sendWithRetry(poster(), policy: fast),
      throwsA(isA<RetriesExhausted>()),
    );
  });

  test('gives up after maxAttempts', () async {
    server = await startFakeAi([overloaded]);
    client = http.Client();
    final notices = <RetryNotice>[];
    await expectLater(
      sendWithRetry(poster(), policy: fast, onRetry: notices.add),
      throwsA(isA<RetriesExhausted>().having((e) => e.attempts, 'attempts', 4)),
    );
    expect(notices.length, 3);
  });

  test('400 is not retried', () async {
    server = await startFakeAi([(400, <String, String>{}, '{}'), ok]);
    client = http.Client();
    final r = await sendWithRetry(poster(), policy: fast);
    expect(r.statusCode, 400);
  });

  test('cancel during the wait stops it', () async {
    server = await startFakeAi([rateLimited(10), ok]);
    client = http.Client();
    final cancel = Completer<void>();
    final f = sendWithRetry(
      poster(),
      policy: const RetryPolicy(maxServerDelay: Duration(seconds: 30)),
      cancelled: cancel.future,
      onRetry: (_) => cancel.complete(),
    );
    final sw = Stopwatch()..start();
    await expectLater(f, throwsA(isA<RetryCancelled>()));
    expect(sw.elapsedMilliseconds, lessThan(2000));
  });

  test('Claude spend cap is a hard stop', () async {
    server = await startFakeAi([
      (
        429,
        <String, String>{},
        '{"type":"error","error":{"type":"rate_limit_error","details":{"error_code":"enforced_spend_limit_reached"}}}',
      ),
      ok,
    ]);
    client = http.Client();
    await expectLater(
      sendWithRetry(poster(), policy: fast),
      throwsA(isA<RetriesExhausted>().having((e) => e.attempts, 'attempts', 1)),
    );
  });

  test('retry-after as an HTTP date', () {
    final now = DateTime.utc(2026, 11, 11, 9, 0, 0);
    final r = http.Response(
      '',
      429,
      headers: {
        'retry-after': HttpDate.format(now.add(const Duration(seconds: 7))),
      },
    );
    expect(retryAfterHeader(r, now: now), const Duration(seconds: 7));
  });

  test('full jitter stays under the cap', () {
    final rng = Random(42);
    for (var retry = 0; retry < 10; retry++) {
      final d = backoff(retry, const RetryPolicy(), rng);
      expect(
        d.inMilliseconds,
        lessThanOrEqualTo(min(8000, 500 * pow(2, retry).toInt())),
      );
    }
  });
}
