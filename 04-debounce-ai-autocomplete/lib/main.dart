import 'package:flutter/material.dart';

import 'compose_screen.dart';
import 'suggester.dart';

void main() {
  runApp(MaterialApp(
    home: ComposeScreen(suggester: FakeSuggester()),
    // Later: ProxySuggester(Dio(BaseOptions(baseUrl: 'https://your-proxy.example.com')))
  ));
}
