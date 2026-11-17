# R08 runs (2026-11-17, Flutter 3.50.0 at ~/fvm/versions/3.50.0 (same tag; first runs used a duplicate clone that was then removed), Dart 3.14.0, macOS arm64)

Flag help (flutter build web -h): "--[no-]deprecated-js-interop  Whether to allow the deprecated JS interop libraries (such as "dart:html", "dart:js", and "dart:js_util") when compiling to JavaScript. With "--no-deprecated-js-interop", importing these libraries is a compile-time error and conditional imports on them resolve to false. Use this to find code that still needs to migrate to "package:web" and "dart:js_interop"."

Survey (survey.py, survey.json, pub.dev search platform:web sort=like top 100, latest versions, 10:40): 5/100 mention dart:html/js/js_util/package:js in lib/: dio 5.11.1 (only as 2nd conditional after dart.library.js_interop), hive 2.2.3 (2022-06-30; direct imports but only behind dart.library.html conditionals), easy_localization 3.0.8 (intl_browser behind dart.library.html), awesome_notifications 0.12.1 (web interface behind dart.library.html), isar 3.1.0+1 (2023-04-25; web impl behind dart.library.html, else native ffi). Own package only, not transitive deps.

App: dio, hive, easy_localization (en/de), awesome_notifications, isar, shared_preferences, url_launcher, go_router, google_fonts, material_ui.
- default build: OK (38.9 s wall); wasm dry run lists only isar dart:ffi (16 lines), nothing about dart:html.
- --no-deprecated-js-interop with isar: FAIL, 1,898 "Error:" lines, all in isar/ffi about dart:ffi; zero mention of dart:html.
- without isar: default OK, strict OK, --wasm OK.
Runtime, headless Chromium 1217, locale de-DE:
- default: dio ok; hive openBox ok 1; awesome initialize returned false; shared_prefs ok; url_launcher true; easy_localization deviceLocale de_DE -> Hallo
- strict: dio ok; hive openBox UnimplementedError; awesome Unsupported operation: Platform._operatingSystem; shared_prefs ok; url_launcher ok; easy_localization deviceLocale en_US -> Hello; plus an uncaught page error
- --wasm: identical to strict (skwasm.wasm + main.dart.wasm loaded)
Fixes (app_fixed): hive -> hive_ce 2.23.3 (js_interop conditional) openBox ok 1 in strict AND wasm; easy_localization: own conditional import of intl_browser findSystemLocale (intl 0.20 uses package:web) + startLocale -> "Hallo" in strict and wasm (context.deviceLocale still en_US); awesome_notifications: no fix (still Unsupported); isar_community 3.4.1 (2026-10-13) same dart.library.html conditionals -> same dart:ffi build failure in strict and wasm.
- Rerun 11:00 with dio GET version.json: HTTP 200 in default, strict and wasm; rest unchanged (hive UnimplementedError, awesome Unsupported Platform._operatingSystem, easy_localization en_US/Hello in strict+wasm).
- isar-only app (isar 3.1.0+1) with --wasm: FAIL, 34 'Error:' lines, all dart:ffi, 0 mentions of dart:html.
