# Flutter 3.50 direct native interop vs platform channels, measured

Code for [Flutter 3.50 Made Platform Channels Optional. I Timed 10,000 Native Calls Both Ways.](https://medium.com/p/61fe0ad71261)

Built and run on **Flutter 3.50.0 stable / Dart 3.14.0** with jni 1.1.2, jnigen 1.0.1, objective_c 9.6.4 and ffigen 23.0.0.

- `interop_bench/` - the same three native calls (uptime, OS version string, "am I on the main thread?") made two ways:
  - a `MethodChannel` with handlers in `android/.../MainActivity.kt` and `ios/Runner/AppDelegate.swift`
  - generated bindings: `lib/android_api.g.dart` (JNIgen) and `lib/ios_api.g.dart` + `ios/Runner/ios_api.g.m` (FFIgen)
  - `lib/src/bench.dart` times 1,000 calls per road (median / p95), from the main isolate and from `Isolate.run`, and prints one `BENCH {...}` JSON line
  - `lib/src/race_page.dart` races 10,000 calls each way (flag icon, or `--dart-define=AUTORACE=true`)
- `plain_bench/` - a channel-only app, used for the APK size comparison
- `results/` - the raw numbers from my phones

## Run

```
cd interop_bench
flutter run --profile            # on a real device; read the BENCH line from the log

# regenerate the bindings
flutter build apk                # once, so JNIgen can find the Android classpath
dart run tool/jnigen.dart
dart run tool/ffigen.dart        # needs Xcode; edit the SDK path at the top if yours differs
```

For iOS, set your own development team in Xcode before running on a device. `ios_api.g.m` is already part of the Runner target (compiled with `-fobjc-arc`).

Platform folders are mostly not committed. Run `flutter create . --platforms=android,ios --org dev.debasmita` inside each app first; the committed `MainActivity.kt`, `AppDelegate.swift`, `ios_api.g.m` and Runner `project.pbxproj` (which compiles `ios_api.g.m` with `-fobjc-arc`) are kept, so don't overwrite them.
