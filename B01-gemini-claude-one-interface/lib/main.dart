// The article's main. Needs a Firebase project: run `flutterfire configure`
// first (it writes lib/firebase_options.dart, which is git-ignored here) and a
// Claude proxy you own. To try the screen with no setup, run lib/main_fake.dart.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'claude_client.dart';
import 'fake_client.dart';
import 'gemini_client.dart';

Future<void> main() async {
  // "You need Firebase initialised before this runs (the usual
  // Firebase.initializeApp in main)". With flutterfire configure, pass
  // `options: DefaultFirebaseOptions.currentPlatform`.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    home: ChatScreen(clients: [
      FakeClient('Fake'),
      GeminiClient(),
      ClaudeClient(proxyUrl: 'https://your-proxy.example.com'),
    ]),
  ));
}
