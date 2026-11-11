import 'package:firebase_ai/firebase_ai.dart';

import 'llm_client.dart';

class GeminiClient implements LlmClient {
  GeminiClient({String model = 'gemini-2.5-flash'})
      : _model = FirebaseAI.googleAI().generativeModel(
          model: model,
          systemInstruction: Content.system(
            'You are a concise assistant inside a mobile app.',
          ),
        );

  final GenerativeModel _model;

  @override
  String get name => 'Gemini';

  @override
  Stream<String> ask(String prompt) async* {
    final stream = _model.generateContentStream([Content.text(prompt)]);
    await for (final chunk in stream) {
      final text = chunk.text;
      if (text != null && text.isNotEmpty) yield text;
    }
  }
}
