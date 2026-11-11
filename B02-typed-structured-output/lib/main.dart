// Demo wiring, not from the article: the ticket sheet driven by
// FakeStructuredClient, so it runs with no Firebase project and no proxy.
// Swap in GeminiStructuredClient (needs Firebase) or ClaudeStructuredClient
// (needs your proxy) for the real thing.
import 'package:flutter/material.dart';

import 'clients.dart';
import 'ticket_sheet.dart';

const _message =
    'App crashes every time I open my invoices on my iPhone. '
    'Open app, tap Billing, tap Invoices, it closes. Need this before Friday!';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Support ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TicketSheet(
          message: _message,
          client: FakeStructuredClient(
            '{"summary":"App crashes when opening invoices on iPhone",'
            '"category":"bug","priority":"high","platform":"ios",'
            '"steps":["Open app","Tap Billing","Tap Invoices"]}',
          ),
        ),
      ),
    ),
  ));
}
