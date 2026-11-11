import 'package:retry_backoff_flutter/chat_controller.dart';
import 'package:retry_backoff_flutter/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('busy twice, then the answer streams in', (tester) async {
    await tester.runAsync(() async {
      final controller = ChatController(
        fakeBusyClaude(),
        Uri.parse('https://proxy.test/claude'),
      );
      final seen = <String>[];
      controller.state.addListener(
        () => seen.add(controller.state.value.runtimeType.toString()),
      );
      controller.ask('hi');
      while (controller.state.value is! Done) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      expect(seen.where((s) => s == 'Busy').length, 2);
      expect((controller.state.value as Done).text, contains('Retry worked'));
      controller.dispose();
    });
  });
}
