# R10: What Broke When I Upgraded to Flutter 3.50

Code for the Medium article "What Broke When I Upgraded to Flutter 3.50".

- `app_338/`: the shop app as created and tested on Flutter 3.38.10 (goldens recorded there).
- `app_350/`: the same app after the upgrade to 3.50.0, with every fix applied (ignoringSemantics removed, Gradle 9.5.0, AGP 9.3.1, Kotlin 2.4.20, compilerOptions DSL). `test/failures/` holds the golden diffs from the first 3.50 run.
- `RESULTS.md`: every error message and number in the article, in order.
- `gradle_app_before.kts`: app/build.gradle.kts before the Gradle fixes.
- `screens/`: Android emulator release builds and iOS simulator Safari (landscape) screenshots.

The RTL workaround (`reverseForRtl`) is left on in both apps on purpose, so you can see it flip.

The golden tests load Arial from `/System/Library/Fonts/Supplemental/Arial.ttf` (it has Latin and Arabic glyphs), so run them on macOS.
