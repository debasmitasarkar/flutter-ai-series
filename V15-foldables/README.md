# V15: Foldables Are Coming for Your Flutter App

Code for the Medium article "Foldables Are Coming for Your Flutter App".

- `app/lib/main.dart`: an orders app with a list, an order screen (note field + fake playback) and a portrait lock. `NaiveHome` is the adaptive layout as first written, `FixedHome` keeps each pane alive with a `GlobalKey` and an `IndexedStack`. A small `Lab` class sets up the same state on every run and logs scroll, note and playback after every window change.
- `app/android/.../MainActivity.kt`: logs every `onCreate`, so you can see the activity is never recreated.
- `tools/run.sh`: installs an APK on the Pixel 9 Pro Fold emulator, folds, unfolds and rotates, and saves logs and screenshots. `tools/rotate.sh` runs the rotate-only check.
- `results/`: the logs from the runs in the article. `RESULTS.md` has every number.
- `screens/`: emulator screenshots (status bar cropped).

Build with Flutter 3.50.1:

```
cd app
flutter build apk --release                                   # before
flutter build apk --release --dart-define=FIXED=true          # after
ORG_GRADLE_PROJECT_v15Target=35 flutter build apk --release   # before, targetSdk 35
```

Emulator: Pixel 9 Pro Fold, Android 16 (API 36) Google Play image. In Settings, set "Continue using apps on fold" to always (`adb shell settings put system fold_lock_behavior_setting stay_awake_on_fold_key`) and turn off the lock screen, otherwise the app is hidden behind the lock screen after a fold. The display ids in `run.sh` are from my emulator; get yours with `adb shell dumpsys SurfaceFlinger --display-id`.
