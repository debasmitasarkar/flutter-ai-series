// fromJson-only timing behind the article's "freezed is ~a tenth of the cost".
// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:isolate_json_parsing/answer.dart';
import 'bench.dart' show payload, median;

void main() {
  for (final n in [40, 400, 4000, 12000]) {
    final raw = payload(n);
    final kb = (utf8.encode(raw).length / 1024).round();
    final f = <double>[];
    for (var r = 0; r < 25; r++) {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final sw = Stopwatch()..start();
      ProductAnswer.fromJson(m);
      sw.stop();
      f.add(sw.elapsedMicroseconds / 1000);
    }
    print('$kb KB fromJson-only ${median(f).toStringAsFixed(2)} ms');
  }
}
