import 'dart:io';

import 'package:bigfonts/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Key;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(Future.value(
        ByteData.sublistView(File('test/fonts/$f').readAsBytesSync())));
  }
  await loader.load();
}

const sizes = {
  '320x568 (iPhone SE 1st gen)': Size(320, 568),
  '360x640 (small Android)': Size(360, 640),
  '390x844 (iPhone 14)': Size(390, 844),
};
const scales = [1.0, 1.3, 1.5, 2.0];

void main() {
  setUpAll(() async {
    await loadFont('Roboto',
        ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf']);
    await loadFont('MaterialIcons', ['MaterialIcons-Regular.otf']);
  });

  final results = StringBuffer();
  tearDownAll(() {
    File('results/run.txt')
      ..createSync(recursive: true)
      ..writeAsStringSync(results.toString());
    debugPrint(results.toString());
  });

  for (final fixed in [false, true]) {
    for (final entry in sizes.entries) {
      for (final scale in scales) {
        final name = '${fixed ? 'fixed' : 'before'} ${entry.key} @$scale';
        testWidgets(name, (tester) async {
          tester.view.physicalSize = entry.value * 3;
          tester.view.devicePixelRatio = 3;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearAllTestValues);

          final overflows = <String>[];
          final old = FlutterError.onError;
          FlutterError.onError = (d) {
            final msg = d.exceptionAsString();
            if (msg.contains('overflowed')) {
              overflows.add(msg.split('\n').first);
            } else {
              old?.call(d);
            }
          };
          await tester.pumpWidget(BigFontsApp(fixed: fixed));
          await tester.pumpAndSettle();
          FlutterError.onError = old;

          // Reachable = the Pay button is fully on screen and receives a tap
          // at its centre (scrolling first if it lives in a scroll view).
          final pay = find.byKey(const Key('pay'));
          if (fixed) {
            await tester.ensureVisible(pay);
            await tester.pumpAndSettle();
          }
          final rect = tester.getRect(pay);
          final onScreen = rect.top >= 0 && rect.bottom <= entry.value.height;
          final tappable = pay.hitTestable().evaluate().isNotEmpty;

          // Can the user still pick "Pickup"? Its centre must be on screen
          // and actually receive the tap.
          final pickup = find.text('Pickup');
          final c = tester.getCenter(pickup);
          final pickupOk = c.dx >= 0 &&
              c.dx <= entry.value.width &&
              pickup.hitTestable().evaluate().isNotEmpty;

          final png = 'shots/${fixed ? 'fixed' : 'before'}_'
              '${entry.value.width.toInt()}x${entry.value.height.toInt()}_$scale.png';
          await expectLater(find.byType(BigFontsApp), matchesGoldenFile(png));

          results.writeln('$name | overflows=${overflows.length} | '
              'pay bottom=${rect.bottom.toStringAsFixed(0)}/${entry.value.height.toInt()} '
              'onScreen=$onScreen tappable=$tappable pickupTappable=$pickupOk');
          for (final o in overflows) {
            results.writeln('    $o');
          }
        });
      }
    }
  }
}
