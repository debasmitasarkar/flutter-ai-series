import 'dart:convert';
import 'dart:isolate';

import 'answer.dart';

/// Runs on whatever isolate calls it. Top-level, so it can be sent to another isolate.
ProductAnswer parseAnswer(String raw) =>
    ProductAnswer.fromJson(jsonDecode(raw) as Map<String, dynamic>);

/// Small payloads stay on the main isolate; big ones go to a short-lived worker.
Future<ProductAnswer> parseAnswerSmart(String raw) async {
  if (raw.length < offIsolateThreshold) return parseAnswer(raw);
  return Isolate.run(() => parseAnswer(raw));
}

const offIsolateThreshold = 50 * 1024; // characters, tune with your own numbers
