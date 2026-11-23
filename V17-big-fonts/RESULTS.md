# V17 run, 2026-11-23 (Flutter 3.50.0, material_ui ^1.1.0)

## Widget test (linear textScaler via textScaleFactorTestValue, Roboto loaded from the SDK cache)
Before (as first written): overflow errors per screen
| size | 1.0 | 1.3 | 1.5 | 2.0 |
|---|---|---|---|---|
| 320x568 | 1 (1.2 px chips) | 3 | 3 | 4 |
| 360x640 | 0 | 2 | 3 | 4 |
| 390x844 | 0 | 0 | 3 | 4 |
Fixed: 0 everywhere (24 runs). Pay button on screen + hit-testable in all 12 'before' runs (keyboard closed), so big fonts alone did NOT push Pay off screen. Pickup chip centre off screen / not hit-testable in 5 of 12 before runs (320@1.3, 1.5, 2.0; 360@2.0; 390@2.0); 0 of 12 fixed.
Worst at 2.0 on 320 wide: chip row 208 px past the edge, product title 176 px, terms line 146 px, product card 8 px at the bottom.
Full log: bigfonts/results/run.txt, goldens bigfonts/test/shots/.

## Android 16 emulator (API 36), wm size 720x1280 density 320 = 360x640 dp, release APK
Android 14+ nonlinear scaling, logged from MediaQuery.textScalerOf:
| font_scale | 14 pt -> | 24 pt -> |
|---|---|---|
| 1.0 | 14.0 | 24.0 |
| 1.3 | 18.8 | 26.4 |
| 1.5 | 22.0 | 28.0 |
| 2.0 | 26.0 | 36.0 |
Release build, before: no stripes, no log; at 1.5 'Pickup' chip and product title cut, at 2.0 also the terms line cut mid-sentence ("By paying you accept the tern").
Keyboard open at 2.0 (before): Pay button and Total hidden behind the keyboard, screen can't scroll. At 1.0 also hidden behind keyboard.
Fixed: Pay pinned above the keyboard at 1.0 and 2.0, content scrolls to Total and terms.
Screens: emu/*.png

## iOS 26.5 simulator, iPhone 17 Pro (402 pt wide), DEBUG build (sim has no release), simctl content_size
| content_size | 14 pt -> | 24 pt -> |
|---|---|---|
| large (default) | 14.0 | 24.0 |
| accessibility-medium | 23.1 | 39.5 |
| accessibility-extra-extra-extra-large | 43.6 | 74.8 |
Before at AX3XL: price rows overlap and are unreadable, Pay label cut in half by the screen bottom, terms cut, chips cut. Fixed: all readable, Pay pinned. Screens emu/ios_*.png
