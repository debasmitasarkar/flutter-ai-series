// ignore: deprecated_member_use
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:r05app/main.dart';

// What the package's FAB (built from flutter/material.dart) actually sees.
legacy.ThemeData packageTheme(WidgetTester tester) => legacy.Theme.of(
  tester.element(find.byType(legacy.FloatingActionButton)),
);

ThemeData appTheme(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(FloatingActionButton)));

void main() {
  testWidgets('without the bridge the package gets the default theme', (tester) async {
    await tester.pumpWidget(const App(bridge: false));
    expect(
      packageTheme(tester).colorScheme.primaryContainer,
      isNot(appTheme(tester).colorScheme.primaryContainer),
    );
  });

  testWidgets('the bridge copies colours but not component themes', (tester) async {
    await tester.pumpWidget(const App(bridge: true));
    expect(
      packageTheme(tester).colorScheme.primaryContainer,
      appTheme(tester).colorScheme.primaryContainer,
    );
    expect(appTheme(tester).floatingActionButtonTheme.shape, isA<CircleBorder>());
    expect(packageTheme(tester).floatingActionButtonTheme.shape, isNull);
  });
}
