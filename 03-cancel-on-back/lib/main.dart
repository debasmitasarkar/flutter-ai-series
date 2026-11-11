// Demo wiring, not from the article: open AnswerScreen against the fake
// server, tap back after a second, and watch the console print
// "fakeAsk: stopped after 2 words".
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'answer_screen.dart';
import 'fake_sse_adapter.dart';

void main() {
  final dio = Dio(BaseOptions(baseUrl: 'https://your-proxy.example.com'))
    ..httpClientAdapter = FakeSseAdapter();
  runApp(MaterialApp(home: HomeScreen(dio: dio)));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.dio});
  final Dio dio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cancel on back')),
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AnswerScreen(prompt: 'Explain cancelling', dio: dio),
            ),
          ),
          child: const Text('Ask'),
        ),
      ),
    );
  }
}
