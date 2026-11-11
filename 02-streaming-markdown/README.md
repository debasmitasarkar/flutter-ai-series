# Rendering Streaming AI Markdown in Flutter Without the Flicker

Article: https://medium.com/p/4afab5744c95

Part 2. Close half-finished Markdown markers before you render them, and parse only the live tail of the reply on each flush.

## What's here

| File | From the article |
| --- | --- |
| `lib/close_open_markdown.dart` | `closeOpenMarkdown`: closes open `**`, `*`, backticks and code fences, and hides half-typed links |
| `lib/split_stable.dart` | `splitStable`: splits the reply at the last blank line outside a code fence |
| `lib/streaming_markdown.dart` | `StreamingMarkdown`: caches the finished part as a widget instance, and re-renders as selectable once `isDone` flips |
| `lib/fake_markdown_ask.dart` | `fakeMarkdownAsk`: streams Markdown three characters at a time |
| `lib/main.dart` | Demo wiring (not in the article) |
| `test/` | Unit tests for the two helpers and a widget test (not in the article) |

Differences from the article listing:
- `streaming_markdown.dart` adds `import 'package:flutter/foundation.dart';`. `ValueListenable` isn't exported by `material.dart`, so the listing doesn't compile without it.
- It also re-exports the two helpers so that Part 3 can import one file.
- `analysis_options.yaml` turns off `use_null_aware_elements`, which leaves the article's `if (_doneWidget != null) _doneWidget!` as it is.

Renderer: [`flutter_markdown_plus`](https://pub.dev/packages/flutter_markdown_plus), the community fork of the discontinued `flutter_markdown`.

## Run it

```sh
flutter pub get
flutter test
flutter create .   # adds the platform folders, which aren't committed
flutter run
```

Tested on Flutter 3.38.10.
