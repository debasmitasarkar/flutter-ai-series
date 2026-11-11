Stream<String> fakeMarkdownAsk(String prompt) async* {
  final f = '\u0060' * 3; // three backticks, so the fence survives this article
  final reply = '''
Here's the **short version**: use `ValueNotifier` for the text.

${f}dart
final text = ValueNotifier<String>('');
$f

Then:

- Coalesce chunks with a *32 ms* timer
- Only the bubble listens
- Read more in the [Flutter docs](https://docs.flutter.dev)
''';
  for (var i = 0; i < reply.length; i += 3) {
    await Future<void>.delayed(const Duration(milliseconds: 15));
    yield reply.substring(i, (i + 3).clamp(0, reply.length));
  }
}
