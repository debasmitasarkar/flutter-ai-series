import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upgrade_app/main.dart';
import 'package:upgrade_app/shop_screen.dart';

Future<void> loadFont(String family, String file) async {
  final loader = FontLoader(family)
    ..addFont(Future.value(
        ByteData.sublistView(File(file.startsWith('/') ? file : 'test/fonts/$file').readAsBytesSync())));
  await loader.load();
}

final out = StringBuffer();

void main() {
  setUpAll(() async {
    // Arial has Latin and Arabic glyphs, so both render as real text.
    await loadFont('Roboto', '/System/Library/Fonts/Supplemental/Arial.ttf'); // macOS system font, not shipped in the repo
    await loadFont('MaterialIcons', 'MaterialIcons-Regular.otf');
  });
  tearDownAll(() {
    final v = Platform.environment['SDK'] ?? 'unknown';
    File('results/$v.txt')
      ..createSync(recursive: true)
      ..writeAsStringSync(out.toString());
  });

  testWidgets('soft hyphen line widths', (tester) async {
    for (final p in products) {
      final tp = TextPainter(
        text: TextSpan(
            text: p.$1,
            style: const TextStyle(
                fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '…',
      )..layout(maxWidth: 145);
      final lines = tp.computeLineMetrics();
      out.writeln('hyphen ${p.$1.replaceAll('­', '|')}: lines=${lines.length} '
          'widths=${lines.map((l) => l.width.toStringAsFixed(1)).join('/')} '
          'longest=${tp.width.toStringAsFixed(1)} '
          'exceeded=${tp.didExceedMaxLines}');
    }
  });

  for (final reverse in [true, false]) {
    testWidgets('rtl widgetspan reverse=$reverse', (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Center(
                  child: SizedBox(
                      width: 320,
                      child: RepaintBoundary(
                          key: const Key('b'),
                          child: OrderStatusBubble(reverseForRtl: reverse)))))));
      final truck = tester.getCenter(find.byKey(const Key('truck'))).dx;
      final badge = tester.getCenter(find.byKey(const Key('badge'))).dx;
      // Reading right to left, the truck should come first (rightmost).
      out.writeln('rtl reverse=$reverse truck.x=${truck.toStringAsFixed(0)} '
          'badge.x=${badge.toStringAsFixed(0)} '
          'truckFirstInRtl=${truck > badge}');
      await expectLater(find.byKey(const Key('b')),
          matchesGoldenFile('goldens/rtl_reverse_$reverse.png'));
    });
  }

  testWidgets('shop screen golden', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const UpgradeApp());
    await expectLater(find.byType(UpgradeApp), matchesGoldenFile('goldens/shop.png'));
  });
}
