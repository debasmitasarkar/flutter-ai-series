# When the AI Says "Slow Down": Retrying 429 and 529 in Flutter Without Hammering the API

Article: https://medium.com/p/57b1ea87e701

Part 6. A retry helper in plain Dart. It retries only 408, 429, 500, 502, 503, 504 and 529, and waits for `retry-after-ms`, `retry-after` (seconds or an HTTP date) or Gemini's `retryDelay` when the server sends one. Otherwise it backs off with full jitter. It stops on Claude's spend cap and on long server waits, can be cancelled during the wait, and never retries a stream after the first byte.

There are two packages here:

| Path | What it is |
| --- | --- |
| `lib/retry.dart` | The retry helper from the article (`RetryPolicy`, `openStreamWithRetry`, `sendWithRetry`, …) |
| `lib/fake_server.dart` | A tiny local fake AI API on `HttpServer`, driven by a script of responses |
| `test/retry_test.dart` | The 10 unit tests the article mentions |
| `bin/demo.dart` | The 529, 529, 429 `retry-after: 2`, 200 run from the article |
| `bin/herd.dart` | The 100-client simulation behind the "no jitter vs full jitter" chart |
| `flutter_app/` | The Flutter side: `claude_stream.dart`, `chat_controller.dart`, `main.dart` with the `MockClient` fake proxy, and the widget test that checks for two `Busy` states before `Done` |

`flutter_app/lib/retry.dart` is an identical copy of `lib/retry.dart`, so each package stands on its own.

## Run it

```sh
# Pure Dart package
dart pub get
dart test
dart run bin/demo.dart
dart run bin/herd.dart

# Flutter app
cd flutter_app
flutter pub get
flutter test
flutter create .   # adds the platform folders, which aren't committed
flutter run
```

## Notes

- **SDK:** the null-aware element `?cancelled` needs Dart 3.8 or later. The article's tests were first run on a Dart 3.15 dev SDK. In this repo all 10 unit tests and the widget test also pass on Flutter 3.38.10 (Dart 3.10.9).
- **Fix from the article listing:** in `flutter_app/lib/main.dart` the article has `'Couldn't get an answer right now.'` in single quotes, and that line doesn't compile. Here it's in double quotes.
- **Web:** `retry.dart` imports `dart:io` for `HttpDate`, so it won't compile for Flutter web as-is. The article mentions this.
- **Tests and sandboxes:** the unit tests bind a loopback `HttpServer` on 127.0.0.1, so a sandbox that blocks local sockets will make them fail.
