# R10 run, 2026-11-23: app created on Flutter 3.38.10, upgraded to 3.50.0

App: upgrade_app (3.38 original) / upgrade_350 (copy, upgraded). One shop screen: German product names with soft hyphens (CMS style), Arabic order status with 2 WidgetSpans and the usual "reverse spans for RTL" workaround, IgnorePointer(ignoringSemantics: false), checkout bar pinned to the bottom with no SafeArea, web/index.html with viewport-fit=cover.

## 1. flutter analyze on 3.50 (analyze_350_before_fix.txt)
- 1 error: `The named parameter 'ignoringSemantics' isn't defined` (lib/shop_screen.dart:47). On 3.38 it was only an info (deprecated after v3.8.0-12.0.pre).
- 3 infos: package:flutter/material.dart deprecated after v3.47.0-0.0.pre (R05 topic).
- `dart fix --dry-run`: 4 fixes (3 import deprecations + missing_dependency in pubspec). Nothing for ignoringSemantics. Fixed by deleting the line (IgnorePointer now removes only pointer SemanticsActions when ignoring).

## 2. flutter build apk --release on 3.50 (four rounds)
1. Gradle 8.14.0 < Flutter minimum 9.3.1 -> wrapper to 9.3.1
2. AGP 8.11.1 < Flutter minimum 9.1.1 -> AGP to 9.3.1 (3.50 template value)
3. AGP 9.3.1: "Minimum supported Gradle version is 9.5.0. Current version is 9.3.1." -> wrapper 9.5.0 (template value)
4. build.gradle.kts script compilation errors: android{} BaseAppModuleExtension deprecated (newDsl), kotlinOptions{} and jvmTarget deprecated -> removed id("kotlin-android") + kotlinOptions, added kotlin { compilerOptions { jvmTarget = JVM_17 } }, Kotlin plugin 2.2.20 -> 2.4.20 (all as in a fresh 3.50 template; changed together, not isolated)
Then: Built app-release.apk (43.7MB). gradle.properties already had android.builtInKotlin=false and android.newDsl=false "added automatically by Flutter migrator".

## 3. flutter test on 3.50 with the 3.38 goldens (Arial loaded as Roboto, MaterialIcons)
- goldens/rtl_reverse_true.png: Pixel test failed, 8.58%, 1373px diff
- goldens/rtl_reverse_false.png: Pixel test failed, 8.02%, 1283px diff
- goldens/shop.png: Pixel test failed, 0.35%, 10328px diff
- 3 of 4 tests red, 1 passed (TextPainter line metrics test: widths unchanged, e.g. Geschirr|spül|maschine 89.8/68.5 on both).

## 4. Soft hyphens
Android emulator release + test goldens: 3.38 "Geschirrspül / maschine", 3.50 "Geschirrspül- / maschine" and "Kühlschrankthermo- / meter". Web (iOS sim Safari): no hyphen on either version (docs: web change ships after 3.50).

## 5. WidgetSpan in RTL
Order: reading right to left the truck should come first.
3.38: workaround on -> truck first (x 538 vs badge 427); workaround off -> wrong.
3.50: workaround on -> WRONG (truck 430, badge 538); workaround off -> right. Same on Android release and on web.

## 6. Web viewport-fit=cover (iOS 26 simulator, Safari, landscape)
3.38: page laid out inside the safe area, full "Geschirrspülmaschine" visible.
3.50: edge-to-edge, first card's text starts under the Dynamic Island ("…schirrspülmaschine"). Portrait with the Safari toolbar showing: no visible difference.

Screens: shots/ (android_338/350, web_338/350_land_page, test/failures in upgrade_350).

## Golden diff attribution (shop.png, 0.35%)
Diff pixels only in two bands: y 287-300 (x 365-1083) = the two hyphens on the first card row; y 1015-1079 (x 692-1086) = the Arabic bubble icons. Nothing else changed.
Note: only 3 golden tests exist; all 3 went red. The 4th test (TextPainter widths) asserts nothing; widths were identical on both SDKs (hyphen drawn but not counted in the reported line width).
