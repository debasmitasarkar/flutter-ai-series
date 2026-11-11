import 'package:isolate_json_parsing/answer_controller.dart';
import 'package:isolate_json_parsing/fake_stream.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('big streamed reply ends up parsed', () async {
    final c = AnswerController()..listen(fakeStructuredReply(products: 4000, chunkSize: 65536));
    while (c.state.value is Streaming) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    final s = c.state.value;
    expect(s, isA<Ready>());
    expect((s as Ready).answer.products.length, 4000);
    c.dispose();
  });
  test('small reply parses on the main isolate path', () async {
    final c = AnswerController()..listen(fakeStructuredReply(products: 3));
    while (c.state.value is Streaming) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect((c.state.value as Ready).answer.products.length, 3);
  });
}
