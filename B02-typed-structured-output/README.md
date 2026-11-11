# Typed Dart Objects From Gemini and Claude: One JSON Schema, Two Different Rulebooks

Article: https://medium.com/p/46cd534d6407

One JSON Schema, written as a const Dart map, goes to Gemini (`responseJsonSchema` in firebase_ai) and to Claude (`output_config.format`). The answer becomes a `TicketDraft` whose `fromJson` checks what a schema can't promise.

## What's here

| File | From the article |
| --- | --- |
| `lib/ticket.dart` | `ticketSchema`, the `Category` / `Priority` / `Platform` enums, `TicketDraft.fromJson` |
| `lib/clients.dart` | `StructuredClient`, `GeminiStructuredClient`, `ClaudeStructuredClient` (checks `stop_reason` for `refusal` and `max_tokens`), `FakeStructuredClient` |
| `lib/ticket_sheet.dart` | `TicketSheet`: bad JSON becomes a fill-it-in state instead of a crash |
| `lib/main.dart` | Demo wiring (not in the article) using `FakeStructuredClient` |
| `test/ticket_test.dart` | The article's four tests: schema sent in `output_config`, refusal, enum guard, fake |
| `test/ticket_sheet_test.dart` | Widget test for the loading, ready and error states (not in the article listing) |

The Claude fixture in the tests follows the documented response shape. It wasn't captured from a live call.

## Run it

```sh
flutter pub get
flutter test
flutter create .   # adds the platform folders, which aren't committed
flutter run
```

The tests use `FakeStructuredClient` and package:http's `MockClient`, so they need no network, keys or Firebase.

## Running the real clients

- **Gemini** (`GeminiStructuredClient`) needs a Firebase project with Firebase AI Logic. Run `flutterfire configure` and `Firebase.initializeApp(...)` before you create the client. `responseJsonSchema` needs Gemini 2.5 or later. No Firebase config files are in this repo.
- **Claude** (`ClaudeStructuredClient`) needs your own proxy that adds the API key and a current `anthropic-version` header.

The article's tests ran on Flutter 3.47.9. In this repo they also pass on Flutter 3.38.10 with firebase_ai 5.1.0. Only the analyzer has checked the Gemini path.
