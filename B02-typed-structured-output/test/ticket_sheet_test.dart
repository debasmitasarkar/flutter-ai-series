// Not from the article's listing: the "hand it FakeStructuredClient in a
// widget test" idea from the UI section, for the loading, ready and error states.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_structured_output/clients.dart';
import 'package:typed_structured_output/ticket_sheet.dart';

Widget host(StructuredClient client) => MaterialApp(
      home: Scaffold(body: TicketSheet(client: client, message: 'x')),
    );

void main() {
  testWidgets('progress, then a ticket card', (tester) async {
    await tester.pumpWidget(host(FakeStructuredClient(
      '{"summary":"Card declined","category":"billing","priority":"medium",'
      '"platform":"android","steps":["Pay"]}',
    )));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.text('Card declined'), findsOneWidget);
    expect(find.text('billing · android · 1 steps'), findsOneWidget);
    expect(find.text('medium'), findsOneWidget);
  });

  testWidgets('bad JSON becomes a fill-it-in state, not a crash',
      (tester) async {
    await tester.pumpWidget(host(FakeStructuredClient(
      '{"summary":"x","category":"complaint","priority":"high",'
      '"platform":"ios","steps":[]}',
    )));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.text("Couldn't fill this in. Please add the details."),
        findsOneWidget);
  });
}
