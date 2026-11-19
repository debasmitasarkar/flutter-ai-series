# R09: which Intent extras a Flutter release build still honours

Article: "Flutter 3.50 Quietly Broke Android Launch Shortcuts (Even Your Own)".

`intent_lab/` is a widgets-only app (no material imports), so the same code builds on Flutter 3.38 and 3.50. It prints one line per launch:

```
I flutter : LAB entry=<main|qaMain> route=<defaultRouteName>
```

and has buttons that post a notification / relaunch itself, once with a `route` extra and once with a deep link (`intentlab://open/checkout`).

## Run it

```
cd intent_lab
flutter build apk --release --target-platform android-arm64   # and --profile
cd ..
tool/run_matrix.sh intent_lab/build/app/outputs/flutter-apk/app-release.apk 350-release
# install the APK, then (button y positions for your screen):
Y="1066 1229 1424 1587" tool/run_inapp.sh 350-release-api33
```

## Results (2026-11-19, emulators sdk_gphone64_arm64, API 36 and API 33)

| launch | 3.38.10 release | 3.50.0 release, API 36 | 3.50.0 release, API 33 | 3.50.0 profile, API 36 |
|---|---|---|---|---|
| `adb am start --es route /checkout` | /checkout | `/` (silent) | `/` (silent) | /checkout + IntentUtils warning |
| `adb am start --es dart_entrypoint qaMain` | qaMain | main (silent) | main (silent) | qaMain + warning |
| `adb am start --es impeller-backend vulkan` | OpenGLES (not applied) | ignored, FlutterEngineFlagsProvider warning | ignored, warning | Vulkan |
| adb deep link `intentlab://open/checkout` | full URI | full URI | full URI | full URI |
| own notification, `route` extra | /checkout (API 33) | /checkout | `/` (silent) | not tested |
| own `startActivity`, `route` extra | /checkout (API 33) | /checkout | `/` (silent) | not tested |
| own notification / `startActivity`, deep link | not tested | full URI | full URI | not tested |

Raw logcat per case: `results/*.txt`. `flutter run --release --use-application-binary` with `--route` or `--trace-startup`: `results/350-use-application-binary.txt`.

Why API 33 differs: on API 34+ the embedding compares `getLaunchedFromUid()` with the app's UID; on API 33 and lower it compares `getCallingPackage()`, which is only set for `startActivityForResult`, so a notification tap or a plain `startActivity` is "not self-sent".

Emulators only; no physical device in this run.
