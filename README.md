# Flutter + AI series by Debasmita Sarkar

Runnable code for my Medium articles on the plumbing behind AI features in Flutter, plus the standalone Gemini/Claude and release-prep articles.

I'm a Google Developer Expert for Flutter and Dart.

## Flutter + AI series

| Article | Folder | Medium |
| --- | --- | --- |
| Part 1: Streaming AI Responses in Flutter Without Rebuilding Your Whole Screen | [01-streaming-without-rebuilds](01-streaming-without-rebuilds) | https://medium.com/p/b3a90e682a0c |
| Part 2: Rendering Streaming AI Markdown in Flutter Without the Flicker | [02-streaming-markdown](02-streaming-markdown) | https://medium.com/p/4afab5744c95 |
| Part 3: Cancelling an AI Request in Flutter When the User Taps Back | [03-cancel-on-back](03-cancel-on-back) | https://medium.com/p/ad650a8617fe |
| Part 4: Debouncing AI Autocomplete in Flutter: Why 300ms Is the Wrong Number | [04-debounce-ai-autocomplete](04-debounce-ai-autocomplete) | https://medium.com/p/08756e7b5702 |
| Part 5: Parsing Big AI JSON in Flutter: When Isolate.run Helps and When It's Just Overhead | [05-isolate-json-parsing](05-isolate-json-parsing) | https://medium.com/p/1db99b9cbb47 |
| Part 6: When the AI Says "Slow Down": Retrying 429 and 529 in Flutter Without Hammering the API | [06-retry-backoff](06-retry-backoff) | https://medium.com/p/57b1ea87e701 |

## More articles

| Article | Folder | Medium |
| --- | --- | --- |
| One Chat Screen, Two Brains: Gemini and Claude Behind a Single Dart Interface | [B01-gemini-claude-one-interface](B01-gemini-claude-one-interface) | https://medium.com/p/ab6d614900c9 |
| Typed Dart Objects From Gemini and Claude: One JSON Schema, Two Different Rulebooks | [B02-typed-structured-output](B02-typed-structured-output) | https://medium.com/p/46cd534d6407 |
| 5 Migrations to Finish Before Flutter 3.50 Lands | [R01-pre-3-50-migrations](R01-pre-3-50-migrations) (checklist only) | https://medium.com/p/4061a1113128 |
| I Moved a 15-Plugin Flutter App Off CocoaPods Before 2 December | [R03-cocoapods-to-spm](R03-cocoapods-to-spm) (commands only) | https://medium.com/p/5e80804f7a6c |
| My Favourite Updates in Flutter 3.50 (and Dart 3.14) | [R02-flutter-3-50-favourites](R02-flutter-3-50-favourites) | https://medium.com/p/529b79c19d73 |

## How the folders work

- Each code folder is a small, self-contained Dart or Flutter package. The code is the code from the article. Anything added only to make it run, like demo `main.dart` files, test adapters or extra tests, is labelled as not from the article, both in the file and in that folder's README.
- Everything runs with fake clients, so you need no API keys, no network and no Firebase project. The folders that also have real Gemini or Claude clients explain what you need to run those.
- The Flutter folders don't commit platform folders. Run `flutter create .` once inside a folder before `flutter run`. `flutter test` works without them.
- `03-cancel-on-back` depends on `02-streaming-markdown` through a relative path, so keep the repo layout as it is.

```sh
cd 01-streaming-without-rebuilds
flutter pub get
flutter test
```

All code folders were tested on Flutter 3.38.10 (Dart 3.10.9). The minimum is Dart 3.8 (`sdk: ">=3.8.0 <4.0.0"`).

## Keys

This repo has no API keys and no Firebase config files, and `.gitignore` keeps them out.

## License

MIT. See [LICENSE](LICENSE).
