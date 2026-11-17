# Flutter 3.50 --no-deprecated-js-interop, audited

Code for [I Turned On Flutter 3.50's --no-deprecated-js-interop. The Build Passed. The App Spoke English to a German.](https://medium.com/p/9123cc454b60)

Built and run on **Flutter 3.50.0 stable / Dart 3.14.0**, release web builds, opened in headless Chromium with the browser language set to German (de-DE).

- `survey.py` - takes the top 100 web packages on pub.dev by likes, downloads each latest version and lists imports of `dart:html`, `dart:js`, `dart:js_util`, `package:js` and `dart.library.html` conditionals. Run `python3 survey.py <out dir> 100`.
- `audit_app/` - one app using dio, hive, easy_localization, awesome_notifications, shared_preferences, url_launcher, go_router and google_fonts. At startup it uses each package once and prints `AUDIT ...` lines (and shows them on screen).
  - `lib/with_isar.dart` - isar on its own, for the build that fails with 1,898 `dart:ffi` errors.
  - `tool/find_html_conditionals.dart` - lists every import in your dependencies that checks `dart.library.html` without a `dart.library.js_interop` branch.
- `fixed_app/` - the same app with hive_ce instead of hive and the browser language read through `intl_browser` (see `lib/system_locale*.dart`).
- `results/` - the survey output, my run notes and the Chromium script I used to read the `AUDIT` lines.

## Run

```
cd audit_app
flutter pub get
dart run tool/find_html_conditionals.dart

flutter build web                                   # default
flutter build web --no-deprecated-js-interop        # builds, but hive / easy_localization / awesome_notifications change behaviour
flutter build web --wasm                            # same runtime results as the flag build
flutter build web --no-deprecated-js-interop -t lib/with_isar.dart   # fails, all dart:ffi errors

# serve a build and open it in a browser set to a non-English language
python3 -m http.server 8601 -d build/web
```

The `web/` folders are committed; the other platform folders are not needed.
