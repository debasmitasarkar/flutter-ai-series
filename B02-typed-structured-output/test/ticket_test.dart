import 'dart:convert';

import 'package:typed_structured_output/clients.dart';
import 'package:typed_structured_output/ticket.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';

const userMessage =
    'App crashes every time I open my invoices on my iPhone. '
    'Open app, tap Billing, tap Invoices, it closes. Need this before Friday!';

// Illustrative fixture in the documented Messages API response shape,
// not captured from a live call.
const claudeFixture = '''
{
  "id": "msg_fixture",
  "type": "message",
  "role": "assistant",
  "stop_reason": "end_turn",
  "content": [
    {
      "type": "text",
      "text": "{\\"summary\\":\\"App crashes when opening invoices on iPhone\\",\\"category\\":\\"bug\\",\\"priority\\":\\"high\\",\\"platform\\":\\"ios\\",\\"steps\\":[\\"Open app\\",\\"Tap Billing\\",\\"Tap Invoices\\"]}"
    }
  ]
}
''';

void main() {
  test('Claude client sends the schema and parses the text block', () async {
    late Map<String, Object?> sent;
    final mock = MockClient((req) async {
      sent = jsonDecode(req.body) as Map<String, Object?>;
      return http.Response(claudeFixture, 200);
    });
    final client = ClaudeStructuredClient(proxyUrl: 'https://p', client: mock);

    final json = await client.extract(userMessage, schema: ticketSchema);
    final ticket = TicketDraft.fromJson(json);

    final format = (sent['output_config'] as Map)['format'] as Map;
    expect(format['type'], 'json_schema');
    expect(format['schema'], ticketSchema);
    expect(ticket.category, Category.bug);
    expect(ticket.platform, Platform.ios);
    expect(ticket.steps, hasLength(3));
  });

  test('refusal is an error, not a ticket', () async {
    final mock = MockClient((_) async => http.Response(
        jsonEncode({
          'stop_reason': 'refusal',
          'content': [
            {'type': 'text', 'text': 'I can not help with that.'}
          ],
        }),
        200));
    final client = ClaudeStructuredClient(proxyUrl: 'https://p', client: mock);
    expect(client.extract('x', schema: ticketSchema),
        throwsA(isA<FormatException>()));
  });

  test('fromJson rejects values the app cannot act on', () {
    expect(
      () => TicketDraft.fromJson({
        'summary': 'x',
        'category': 'complaint',
        'priority': 'high',
        'platform': 'ios',
        'steps': <String>[],
      }),
      throwsFormatException,
    );
  });

  test('fake client feeds the same parser', () async {
    final fake = FakeStructuredClient(
      '{"summary":"Card declined at checkout","category":"billing",'
      '"priority":"medium","platform":"android","steps":[]}',
    );
    final ticket =
        TicketDraft.fromJson(await fake.extract('x', schema: ticketSchema));
    expect(ticket.category, Category.billing);
  });
}
