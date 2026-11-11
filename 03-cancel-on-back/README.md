# Cancelling an AI Request in Flutter When the User Taps Back

Article: https://medium.com/p/ad650a8617fe

Part 3. A streaming AI call has two parts, the HTTP request and the stream subscription, and you need to cancel both. `AiCall` keeps them together behind one `cancel()`, and the screen's `dispose` calls it.

## What's here

| File | From the article |
| --- | --- |
| `lib/ai_call.dart` | `AiCall`: dio `CancelToken` and `StreamSubscription` in one object |
| `lib/answer_screen.dart` | `AnswerScreen`: owns the call, cancels it in `dispose`, and has a Stop button |
| `lib/fake_ask.dart` | `fakeAsk`: prints `fakeAsk: stopped after N words` when it's cancelled |
| `lib/fake_sse_adapter.dart` | Not in the article. A dio `HttpClientAdapter` that serves `fakeAsk` as `data:` SSE lines, so `AiCall` runs unchanged with no server |
| `lib/main.dart` | Demo wiring (not in the article): open the answer, tap back, watch the console |
| `test/` | Streams to the end, cancel keeps the partial answer, and popping the route stops the source (not in the article) |

`AnswerScreen` uses `StreamingMarkdown` from Part 2 through a path dependency on `../02-streaming-markdown`. `analysis_options.yaml` turns off `unnecessary_underscores` so the article's `(_, done, __)` builder stays as written.

## Run it

```sh
flutter pub get
flutter test       # takes about 10 s, because the fake streams in real time
flutter create .   # adds the platform folders, which aren't committed
flutter run
```

To use a real backend, drop the `httpClientAdapter` line in `main.dart` and point `baseUrl` at your proxy. Tested on Flutter 3.38.10 with dio 5.11.1.
