import 'dart:math';

import 'package:retry_backoff/retry.dart';

/// 100 app instances all get a 529 at t=0. Where do their next 3 retries land?
/// Counts requests per 250 ms bucket for fixed exponential backoff vs full jitter.
void main() {
  const clients = 100, buckets = 80, bucketMs = 100;
  final rng = Random(7);
  const p = RetryPolicy();
  for (final mode in ['no jitter', 'full jitter']) {
    final counts = List.filled(buckets, 0);
    for (var c = 0; c < clients; c++) {
      var t = 0;
      for (var retry = 0; retry < 3; retry++) {
        final ceiling = min(
          p.maxDelay.inMilliseconds,
          p.baseDelay.inMilliseconds * pow(2, retry).toInt(),
        );
        t += mode == 'no jitter'
            ? ceiling
            : backoff(retry, p, rng).inMilliseconds;
        final b = t ~/ bucketMs;
        if (b < buckets) counts[b]++;
      }
    }
    final peak = counts.reduce(max);
    print(
      '$mode: peak $peak requests in one 100 ms window; ${counts.join(',')}',
    );
  }
}
