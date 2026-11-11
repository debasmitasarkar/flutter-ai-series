# Streaming AI Responses in Flutter Without Rebuilding Your Whole Screen

Article: https://medium.com/p/b3a90e682a0c

Part 1 of the Flutter + AI series. When an LLM reply streams in, only the newest bubble should rebuild, not the whole chat screen.

## What's here

| File | From the article |
| --- | --- |
| `lib/streaming_message.dart` | `StreamingMessage`: a `ValueNotifier<String>` per reply, with chunks coalesced by a 32 ms `Timer` |
| `lib/reply_bubble.dart` | `ReplyBubble`: a `ValueListenableBuilder` that listens to its own message only |
| `lib/chat_screen.dart` | `ChatScreen`: one `setState` per message, auto-scroll only when the user is near the bottom |
| `lib/fake_ask.dart` | `fakeAsk`: a stream of words, no API key needed |
| `lib/main.dart` | Demo wiring (not in the article): one `ReplyBubble` fed by `fakeAsk` |
| `test/` | Small checks of the code above (not in the article) |

The article leaves the input field out of `ChatScreen`, so `_send` has an `// ignore: unused_element`. Connect it to your `TextField`.

## Run it

```sh
flutter pub get
flutter test
flutter create .   # adds the platform folders, which aren't committed
flutter run
```

No dependencies besides Flutter. Tested on Flutter 3.38.10 (Dart 3.10.9).
