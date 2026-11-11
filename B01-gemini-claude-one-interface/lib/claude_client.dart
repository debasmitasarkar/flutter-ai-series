import 'dart:convert';
import 'package:http/http.dart' as http;

import 'llm_client.dart';

class ClaudeClient implements LlmClient {
  ClaudeClient({
    required this.proxyUrl,
    this.model = 'claude-sonnet-5-5',
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String proxyUrl;
  final String model;
  final http.Client _client;

  @override
  String get name => 'Claude';

  @override
  Stream<String> ask(String prompt) async* {
    final req = http.Request('POST', Uri.parse('$proxyUrl/v1/messages'))
      ..headers['content-type'] = 'application/json'
      ..body = jsonEncode({
        'model': model,
        'max_tokens': 1024,
        'stream': true,
        'system': 'You are a concise assistant inside a mobile app.',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      });

    final res = await _client.send(req);
    if (res.statusCode != 200) {
      throw http.ClientException('Claude proxy returned ${res.statusCode}');
    }

    final lines = res.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      if (!line.startsWith('data: ')) continue;
      final event = jsonDecode(line.substring(6)) as Map<String, dynamic>;
      switch (event['type']) {
        case 'content_block_delta':
          final delta = event['delta'] as Map<String, dynamic>;
          if (delta['type'] == 'text_delta') yield delta['text'] as String;
        case 'message_stop':
          return;
      }
    }
  }
}
