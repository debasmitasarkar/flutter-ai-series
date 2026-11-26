# Results (2026-11-26)

Flutter 3.50.1, release builds. Pixel 9 Pro Fold emulator, Android 16 (API 36). Inner screen 852x883 dp, cover screen 443x994 dp. Emulators only.

Default `flutter.targetSdkVersion` in Flutter 3.50.1's Gradle plugin: 36.

## State across fold / unfold (results/*/log.txt)

`MainActivity.onCreate` ran once per run in every build: fold, unfold and rotate never recreated the activity (Flutter's template lists them in `android:configChanges`).

| Build | Fold | Unfold |
|---|---|---|
| before, targetSdk 36 | note lost, playback restarted at 0 after ~12 s | list scroll 2400 -> 0, note empty, playback restarted |
| before, targetSdk 35 | same as above | same as above |
| after (GlobalKey + IndexedStack) | note kept, scroll 2400 kept, playback 12.7 -> 14.8 s | note kept, scroll 2400, playback 19.0 -> 20.9 s |

## Rotate, unfolded (results/rotate-*/log.txt, tools/rotate.sh)

Both before and after: onCreate once, note, scroll 2400 and playback kept across rotate and rotate back (the layout stays two-pane at 852 and 883 dp wide).

## Portrait lock, unfolded, rotated to landscape (screens/t35-landscape.png, t36-landscape.png)

| targetSdk | Result |
|---|---|
| 35 | letterboxed: app bounds 639 dp wide in an 883 dp wide screen (window bounds 298..1855 px of 2152) |
| 36 | lock ignored on the large screen, app fills 883x852 dp |

The before-t36 fold/unfold log was re-run with the rotate step fixed (`emu rotate`); the emulator started that run in landscape, so its rotate lines come after the state was already lost.

Not tested: split screen, external keyboard/mouse, camera, the 4:3 foldable emulator, a physical foldable.
