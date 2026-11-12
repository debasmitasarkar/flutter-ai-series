import 'package:demo350/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('blur dialog opens and closes', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BlurDialogDemo()));
    await tester.tap(find.text('Ask the AI'));
    await tester.pumpAndSettle();
    expect(find.text('Focus mode'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
    await tester.tap(find.text('Back to the chaos'));
    await tester.pumpAndSettle();
    expect(find.text('Focus mode'), findsNothing);
  });

  testWidgets('reduce motion uses a fade', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReduceMotionDemo()));
    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.text('Open details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final page = find.byType(DetailsPage);
    expect(
      find.ancestor(of: page, matching: find.byType(FadeTransition)),
      findsWidgets,
    );
    expect(
      find.ancestor(of: page, matching: find.byType(SlideTransition)),
      findsNothing,
    );
    await tester.pumpAndSettle();
    expect(find.text('Arrived!'), findsOneWidget);
  });

  testWidgets('without reduce motion it slides', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReduceMotionDemo()));
    await tester.tap(find.text('Open details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final page = find.byType(DetailsPage);
    expect(
      find.ancestor(of: page, matching: find.byType(SlideTransition)),
      findsWidgets,
    );
  });

  testWidgets('sliver clip sections render', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SliverClipDemo()));
    expect(find.byType(SliverClipRRect), findsWidgets);
  });
}
