import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpDate, HttpException;
import 'dart:math';

import 'package:http/http.dart' as http;

/// How hard we try before giving up.
class RetryPolicy {
  const RetryPolicy({
    this.maxAttempts = 4,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 8),
    this.maxServerDelay = const Duration(seconds: 20),
  });

  /// Total tries, including the first one.
  final int maxAttempts;
  final Duration baseDelay;

  /// Cap for our own backoff.
  final Duration maxDelay;

  /// If the server asks us to wait longer than this, give up instead.
  final Duration maxServerDelay;
}

/// 429 = slow down, 529 = Claude overloaded, 503 = Gemini overloaded,
/// 500/502/504 = the server tripped. 4xx like 400 or 401 never get better.
bool isRetryable(int status) =>
    status == 408 ||
    status == 429 ||
    status == 500 ||
    status == 502 ||
    status == 503 ||
    status == 504 ||
    status == 529;

/// Reads `retry-after-ms`, then `retry-after` (seconds or an HTTP date).
Duration? retryAfterHeader(http.BaseResponse response, {DateTime? now}) {
  final ms = int.tryParse(response.headers['retry-after-ms'] ?? '');
  if (ms != null) return Duration(milliseconds: ms);
  final value = response.headers['retry-after'];
  if (value == null) return null;
  final seconds = int.tryParse(value.trim());
  if (seconds != null) return Duration(seconds: seconds);
  try {
    final wait = HttpDate.parse(value).difference(now ?? DateTime.now());
    return wait.isNegative ? Duration.zero : wait;
  } on FormatException {
    return null;
  } on HttpException {
    return null;
  }
}

/// Gemini 429s may carry the wait in the body: {"error": {"details": [{"retryDelay": "37s"}]}}.
Duration? retryDelayInBody(String body) {
  try {
    final details = (jsonDecode(body) as Map)['error']?['details'];
    if (details is! List) return null;
    for (final d in details) {
      final raw = d is Map ? d['retryDelay'] : null;
      if (raw is String && raw.endsWith('s')) {
        final s = double.tryParse(raw.substring(0, raw.length - 1));
        if (s != null) return Duration(milliseconds: (s * 1000).round());
      }
    }
  } catch (_) {}
  return null;
}

/// Some 429s are not "slow down" but "stop": Claude's spend cap says so in
/// error.details.error_code, and the server can answer x-should-retry: false.
bool isHardStop(http.BaseResponse response, String body) {
  if (response.headers['x-should-retry'] == 'false') return true;
  try {
    final details = (jsonDecode(body) as Map)['error']?['details'];
    return details is Map &&
        details['error_code'] == 'enforced_spend_limit_reached';
  } catch (_) {
    return false;
  }
}

/// Full jitter: a random wait between 0 and min(cap, base * 2^retry).
Duration backoff(int retry, RetryPolicy p, Random random) {
  final ceiling = min(
    p.maxDelay.inMilliseconds,
    p.baseDelay.inMilliseconds * pow(2, retry).toInt(),
  );
  return Duration(milliseconds: random.nextInt(ceiling + 1));
}

/// What the UI gets told before each wait.
class RetryNotice {
  const RetryNotice(this.attempt, this.wait, this.status);
  final int attempt;
  final Duration wait;
  final int? status;
}

class RetriesExhausted implements Exception {
  RetriesExhausted(this.lastStatus, this.attempts);
  final int? lastStatus;
  final int attempts;
  @override
  String toString() =>
      'Gave up after $attempts attempts (last status $lastStatus)';
}

class RetryCancelled implements Exception {
  @override
  String toString() => 'Cancelled while waiting to retry';
}

/// Sends a request built by [send] and retries it when the answer is
/// "slow down" or "overloaded". [send] must build a NEW request each time:
/// an http.Request can only be sent once.
///
/// Only the response *status* is retried. Once a streamed body has started,
/// the caller owns it; see [openStreamWithRetry].
Future<http.StreamedResponse> openStreamWithRetry(
  Future<http.StreamedResponse> Function() send, {
  RetryPolicy policy = const RetryPolicy(),
  Future<void>? cancelled,
  void Function(RetryNotice notice)? onRetry,
  Random? random,
}) async {
  final rng = random ?? Random();
  var wasCancelled = false;
  cancelled?.then((_) => wasCancelled = true);

  for (var attempt = 1; ; attempt++) {
    if (wasCancelled) throw RetryCancelled();
    http.StreamedResponse? response;
    try {
      response = await send();
    } on http.ClientException {
      // Connection dropped before any status: safe to try again.
      if (attempt >= policy.maxAttempts) rethrow;
    }

    Duration? serverWait;
    if (response != null) {
      final status = response.statusCode;
      if (!isRetryable(status)) return response;
      // We're not handing this response out, so reading its body is fine.
      final body = await response.stream.bytesToString();
      if (isHardStop(response, body) || attempt >= policy.maxAttempts) {
        throw RetriesExhausted(status, attempt);
      }
      // Work out how long to wait: the server's number first, ours second.
      serverWait = retryAfterHeader(response) ?? retryDelayInBody(body);
      if (serverWait != null && serverWait > policy.maxServerDelay) {
        throw RetriesExhausted(status, attempt);
      }
    }
    final wait = serverWait ?? backoff(attempt - 1, policy, rng);
    onRetry?.call(RetryNotice(attempt, wait, response?.statusCode));

    await Future.any([Future<void>.delayed(wait), ?cancelled]);
  }
}

/// Same thing for a plain, non-streamed request.
Future<http.Response> sendWithRetry(
  Future<http.StreamedResponse> Function() send, {
  RetryPolicy policy = const RetryPolicy(),
  Future<void>? cancelled,
  void Function(RetryNotice notice)? onRetry,
  Random? random,
}) async => http.Response.fromStream(
  await openStreamWithRetry(
    send,
    policy: policy,
    cancelled: cancelled,
    onRetry: onRetry,
    random: random,
  ),
);
