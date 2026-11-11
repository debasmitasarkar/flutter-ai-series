// The harness behind the article's numbers (the `measure` function is the one
// shown in the article). Run AOT, JIT numbers lie:
//   dart compile exe tool/bench.dart -o build/bench && ./build/bench
// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:isolate_json_parsing/parse.dart';

String payload(int n) {
  final products = List.generate(
    n,
    (i) => {
      'id': 'sku-$i',
      'name': 'Noise-cancelling headphones model $i with a long marketing name',
      'price': 199.0 + i % 50,
      'currency': 'EUR',
      'tags': ['audio', 'wireless', 'travel', 'anc', 'usb-c'],
      'specs': List.generate(
        6,
        (j) => {
          'label': 'Spec label $j',
          'value': 'Some value for spec $j of item $i',
        },
      ),
      'why':
          'Recommended because it matches the budget, has strong noise cancelling and a 30 hour battery, which the user asked for.',
      'score': (i % 100) / 100,
    },
  );
  return jsonEncode({
    'query': 'headphones under 300 for flights',
    'summary': 'Here are the best matches.',
    'products': products,
  });
}

double median(List<double> xs) {
  xs.sort();
  return xs[xs.length ~/ 2];
}

/// Runs [work] while a 1 ms ticker runs on this isolate;
/// returns (total ms, longest gap between ticks ms).
Future<(double, double)> measure(Future<void> Function() work) async {
  var last = DateTime.now().microsecondsSinceEpoch;
  var maxGap = 0;
  final t = Timer.periodic(const Duration(milliseconds: 1), (_) {
    final now = DateTime.now().microsecondsSinceEpoch;
    if (now - last > maxGap) maxGap = now - last;
    last = now;
  });
  await Future.delayed(const Duration(milliseconds: 20));
  maxGap = 0;
  last = DateTime.now().microsecondsSinceEpoch;
  final sw = Stopwatch()..start();
  await work();
  sw.stop();
  await Future.delayed(const Duration(milliseconds: 5));
  t.cancel();
  return (sw.elapsedMicroseconds / 1000, maxGap / 1000);
}

Future<void> main() async {
  for (final n in [40, 400, 4000, 12000]) {
    final raw = payload(n);
    final kb = (utf8.encode(raw).length / 1024).round();
    final mainT = <double>[],
        mainGap = <double>[],
        isoT = <double>[],
        isoGap = <double>[],
        decodeOnly = <double>[];
    for (var r = 0; r < 25; r++) {
      final sw = Stopwatch()..start();
      jsonDecode(raw);
      sw.stop();
      decodeOnly.add(sw.elapsedMicroseconds / 1000);
      final a = await measure(() async {
        parseAnswer(raw);
      });
      mainT.add(a.$1);
      mainGap.add(a.$2);
      final b = await measure(() async {
        await Isolate.run(() => parseAnswer(raw));
      });
      isoT.add(b.$1);
      isoGap.add(b.$2);
    }
    print(
      '$kb KB | n=$n | decode-only ${median(decodeOnly).toStringAsFixed(2)} ms | main: total ${median(mainT).toStringAsFixed(2)} ms, worst stall ${median(mainGap).toStringAsFixed(2)} ms | Isolate.run: total ${median(isoT).toStringAsFixed(2)} ms, worst stall ${median(isoGap).toStringAsFixed(2)} ms',
    );
  }
}
