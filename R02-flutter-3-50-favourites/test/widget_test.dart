import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui_migration/main.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('settings button navigates', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('German material strings still load', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    final ctx = tester.element(find.byType(Scaffold));
    expect(MaterialLocalizations.of(ctx).okButtonLabel, 'OK');
    tester.platformDispatcher.localesTestValue = const [Locale('de')];
    await tester.pumpAndSettle();
    final de = tester.element(find.byType(Scaffold));
    expect(MaterialLocalizations.of(de).backButtonTooltip, 'Zurück');
    tester.platformDispatcher.clearLocalesTestValue();
  });
}
