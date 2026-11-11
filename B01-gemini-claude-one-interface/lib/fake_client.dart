import 'llm_client.dart';

class FakeClient implements LlmClient {
  FakeClient(this.name, {this.delay = const Duration(milliseconds: 60)});

  @override
  final String name;
  final Duration delay;

  @override
  Stream<String> ask(String prompt) async* {
    final words = 'Hi, I am $name and I am pretending to think about '
        '"$prompt" very hard.'.split(' ');
    for (final w in words) {
      await Future<void>.delayed(delay);
      yield '$w ';
    }
  }
}
