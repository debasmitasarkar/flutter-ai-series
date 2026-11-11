import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:http/http.dart' as http;

abstract interface class StructuredClient {
  String get name;
  Future<Map<String, Object?>> extract(
    String input, {
    required Map<String, Object?> schema,
  });
}

class GeminiStructuredClient implements StructuredClient {
  GeminiStructuredClient({String model = 'gemini-3.5-flash-lite'})
      : _model = FirebaseAI.googleAI().generativeModel(
          model: model,
          systemInstruction: Content.system(
            'You turn user messages into support tickets.',
          ),
        );

  final GenerativeModel _model;

  @override
  String get name => 'Gemini';

  @override
  Future<Map<String, Object?>> extract(
    String input, {
    required Map<String, Object?> schema,
  }) async {
    final response = await _model.generateContent(
      [Content.text(input)],
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseJsonSchema: schema,
      ),
    );
    final text = response.text;
    if (text == null || text.isEmpty) {
      throw const FormatException('Gemini returned no JSON');
    }
    return jsonDecode(text) as Map<String, Object?>;
  }
}

class ClaudeStructuredClient implements StructuredClient {
  ClaudeStructuredClient({
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
  Future<Map<String, Object?>> extract(
    String input, {
    required Map<String, Object?> schema,
  }) async {
    final res = await _client.post(
      Uri.parse('$proxyUrl/v1/messages'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'model': model,
        'max_tokens': 1024,
        'system': 'You turn user messages into support tickets.',
        'messages': [
          {'role': 'user', 'content': input},
        ],
        'output_config': {
          'format': {'type': 'json_schema', 'schema': schema},
        },
      }),
    );
    if (res.statusCode != 200) {
      // A schema keyword Claude doesn't support lands here as a 400.
      throw http.ClientException('Claude ${res.statusCode}: ${res.body}');
    }

    final body = jsonDecode(res.body) as Map<String, Object?>;
    switch (body['stop_reason']) {
      case 'refusal':
        throw const FormatException('Claude refused; no JSON to parse');
      case 'max_tokens':
        throw const FormatException('JSON cut off; raise max_tokens');
    }

    final blocks = (body['content'] as List).cast<Map<String, Object?>>();
    final text = blocks.firstWhere((b) => b['type'] == 'text')['text'];
    return jsonDecode(text as String) as Map<String, Object?>;
  }
}

class FakeStructuredClient implements StructuredClient {
  FakeStructuredClient(this.reply);

  /// Whatever JSON you want the "model" to send back.
  final String reply;

  @override
  String get name => 'Fake';

  @override
  Future<Map<String, Object?>> extract(
    String input, {
    required Map<String, Object?> schema,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return jsonDecode(reply) as Map<String, Object?>;
  }
}
