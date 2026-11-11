# Parsing Big AI JSON in Flutter: When Isolate.run Helps and When It's Just Overhead

Article: https://medium.com/p/1db99b9cbb47

Part 5. Measure before you reach for an isolate. Parse a streamed structured-output reply once, and send it to `Isolate.run` only when it's over a size threshold.

## What's here

| File | From the article |
| --- | --- |
| `lib/answer.dart` | freezed 3 models: `ProductAnswer`, `Product`, `Spec` |
| `lib/answer.freezed.dart`, `lib/answer.g.dart` | Generated files, committed so you can run the tests without `build_runner` |
| `lib/parse.dart` | `parseAnswer` and `parseAnswerSmart` (50 KB threshold) |
| `lib/answer_controller.dart` | `AnswerController`: buffers the stream, then parses once |
| `lib/answer_screen.dart` | `AnswerScreen`: a `switch` over `Streaming` / `Ready` / `Failed` |
| `lib/fake_stream.dart` | `fakeStructuredReply`: a big reply in 2 KB chunks |
| `lib/main.dart` | The article's `main` |
| `tool/bench.dart` | The harness behind the article's numbers. Its `measure` function is the one shown in the article |
| `tool/fromjson.dart` | Times `fromJson` on its own |
| `test/controller_test.dart` | A big reply goes through the isolate path and a small one stays on the main isolate |

## Run it

```sh
flutter pub get
flutter test
flutter create .   # adds the platform folders, which aren't committed
flutter run --profile

# Regenerate the freezed files after you change answer.dart
dart run build_runner build --delete-conflicting-outputs

# The benchmark, compiled AOT (JIT numbers lie)
dart compile exe tool/bench.dart -o build/bench && ./build/bench
```

The `source_helper` override in `pubspec.yaml` is the workaround from the article. Without it, `json_serializable` 6.14.1 with `source_helper` 1.4.0 fails with "defined in multiple extensions". Tested on Flutter 3.38.10. Compiled AOT on an Apple Silicon Mac, the benchmark gave numbers close to the article's: 0.24 ms at 29 KB, and a 49.5 ms worst stall at 8.7 MB, down to 8.8 ms with `Isolate.run`.
