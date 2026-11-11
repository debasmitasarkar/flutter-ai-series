# Debouncing AI Autocomplete in Flutter: Why 300ms Is the Wrong Number

Article: https://medium.com/p/08756e7b5702

Part 4. An AI autocomplete needs a different debounce from a search box. It fires fast on a word boundary and waits 700 ms mid-word. It cancels the request in flight when the text diverges, and reuses the suggestion while the user types what it predicted.

## What's here

| File | From the article |
| --- | --- |
| `lib/suggester.dart` | `Suggester` interface, `FakeSuggester` (900 ms, honours the cancel token), `ProxySuggester` (dio) |
| `lib/autocomplete_controller.dart` | `AutocompleteController`: boundary/pause timing, cancel in flight, prefix reuse, sequence check |
| `lib/compose_screen.dart` | `ComposeScreen`: the suggestion as an `ActionChip` under the field |
| `lib/main.dart` | The article's `main` with `FakeSuggester` |
| `test/` | Replays the article's walk-through and counts requests and cancels (not in the article) |

Differences from the article listing: `autocomplete_controller.dart` imports `package:dio/dio.dart` for `CancelToken`, which the listing's imports leave out. `analysis_options.yaml` turns off `unnecessary_underscores` for the `(_, ghost, __)` builder.

## Run it

```sh
flutter pub get
flutter test
flutter create .   # adds the platform folders, which aren't committed
flutter run
```

Try typing `how do i stream `, `the user taps ` or `debounce `. Those are the fake's canned prefixes. Tested on Flutter 3.38.10.
