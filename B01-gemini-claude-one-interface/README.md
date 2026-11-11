# One Chat Screen, Two Brains: Gemini and Claude Behind a Single Dart Interface

Article: https://medium.com/p/ab6d614900c9

A small `LlmClient` interface (a name plus a `Stream<String>`) with Gemini behind it through Firebase AI Logic, Claude behind it through the Messages API over SSE, and a fake for tests.

## What's here

| File | From the article |
| --- | --- |
| `lib/llm_client.dart` | `LlmClient` interface |
| `lib/gemini_client.dart` | `GeminiClient` on `firebase_ai`, with the system prompt on the model |
| `lib/claude_client.dart` | `ClaudeClient`: raw Messages API SSE through your proxy, with the system prompt on each request |
| `lib/fake_client.dart` | `FakeClient` |
| `lib/chat_screen.dart` | `ChatScreen` with a `SegmentedButton` to switch brains |
| `lib/main.dart` | The article's `main` with Fake, Gemini and Claude, plus the `Firebase.initializeApp` the article says you need |
| `lib/main_fake.dart` | Not in the article: two fakes, no setup |
| `test/` | `ChatScreen` with fakes, and `ClaudeClient` against `MockClient` (not in the article) |

## Run it

```sh
flutter pub get
flutter test
flutter create .                     # adds the platform folders, which aren't committed
flutter run -t lib/main_fake.dart    # no Firebase, no proxy, no keys
```

The tests use only `FakeClient` and `MockClient`, so they need no network, keys or Firebase.

## Running the real clients

- **Gemini** needs a Firebase project with Firebase AI Logic and the Gemini Developer API turned on. Run `flutterfire configure`, then call `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`. App Check is recommended. The Firebase config files (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`) are not in this repo, and `.gitignore` keeps them out.
- **Claude** needs a proxy you own. It adds `x-api-key` and `anthropic-version` and forwards the body to `https://api.anthropic.com/v1/messages`. Never put an Anthropic API key in a Flutter app.

`analysis_options.yaml` turns off `unnecessary_underscores` for the article's `(_, text, __)` builder. Tested on Flutter 3.38.10 with firebase_ai 5.1.0. Only the analyzer has checked the Gemini path, because running it needs a Firebase project.
