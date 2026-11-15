import 'dart:isolate';

import 'package:flutter/services.dart';

import 'native_api.dart';

const calls = 1000;

/// Summary of [calls] timed calls, in microseconds.
class Result {
  Result(this.name, List<double> us, {required this.firstUs})
    : median = _pct(us, 0.5),
      p95 = _pct(us, 0.95),
      totalMs = us.fold<double>(0, (a, b) => a + b) / 1000;

  final String name;
  final double firstUs, median, p95, totalMs;

  static double _pct(List<double> v, double p) {
    final s = [...v]..sort();
    return s[((s.length - 1) * p).round()];
  }

  Map<String, Object> toJson() => {
    'name': name,
    'firstUs': firstUs.toStringAsFixed(1),
    'medianUs': median.toStringAsFixed(2),
    'p95Us': p95.toStringAsFixed(2),
    'totalMs': totalMs.toStringAsFixed(1),
  };
}

double _us(Stopwatch sw) => sw.elapsedTicks * 1e6 / sw.frequency;

Result timeSync(String name, Object? Function() call) {
  final sw = Stopwatch()..start();
  call();
  final first = _us(sw);
  final us = <double>[];
  for (var i = 0; i < calls; i++) {
    sw.reset();
    call();
    us.add(_us(sw));
  }
  return Result(name, us, firstUs: first);
}

Future<Result> timeAsync(String name, Future<Object?> Function() call) async {
  final sw = Stopwatch()..start();
  await call();
  final first = _us(sw);
  final us = <double>[];
  for (var i = 0; i < calls; i++) {
    sw.reset();
    await call();
    us.add(_us(sw));
  }
  return Result(name, us, firstUs: first);
}

/// Runs everything once, in the order a fresh app would hit it.
Future<Map<String, Object>> runAll() async {
  final direct = DirectApi.forPlatform();
  final channel = ChannelApi();
  final results = <Result>[
    // Direct first, so its "first call" really is the first lookup.
    timeSync('direct uptime', direct.uptimeMs),
    await timeAsync('channel uptime', channel.uptimeMs),
    timeSync('direct osVersion', direct.osVersion),
    await timeAsync('channel osVersion', channel.osVersion),
  ];

  // From a background isolate: direct calls just work, the channel needs
  // the root isolate token.
  final token = RootIsolateToken.instance!;
  final fromIsolate = await Isolate.run(() async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    final d = DirectApi.forPlatform();
    final c = ChannelApi();
    return [
      timeSync('isolate direct uptime', d.uptimeMs).toJson(),
      (await timeAsync('isolate channel uptime', c.uptimeMs)).toJson(),
      {
        'name': 'isolate isMainThread',
        'direct': d.isMainThread(),
        'channel': await c.isMainThread(),
      },
    ];
  });

  return {
    'results': [for (final r in results) r.toJson(), ...fromIsolate],
    'mainIsolate isMainThread': {
      'direct': direct.isMainThread(),
      'channel': await channel.isMainThread(),
    },
    'uptimeMs': {
      'direct': direct.uptimeMs(),
      'channel': await channel.uptimeMs(),
    },
    'osVersion': direct.osVersion(),
  };
}
