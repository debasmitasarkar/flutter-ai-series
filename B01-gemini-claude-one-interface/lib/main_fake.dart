// Not from the article: the same screen with two fake brains, no Firebase,
// no proxy, no keys. `flutter run -t lib/main_fake.dart`
import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'fake_client.dart';

void main() {
  runApp(MaterialApp(
    home: ChatScreen(clients: [
      FakeClient('Fake'),
      FakeClient('Other fake', delay: const Duration(milliseconds: 150)),
    ]),
  ));
}
