# I Moved a 15-Plugin Flutter App Off CocoaPods Before 2 December. Here's What Actually Broke.

Article: https://medium.com/p/5e80804f7a6c

Release prep before CocoaPods trunk goes read-only on 2 December. The test app in the article had no app code, only dependencies, so this folder holds the commands and config from the article, not a project.

## Recreate the test app

The app was created with Flutter 3.38, while CocoaPods was still the default, and then opened with Flutter 3.47.9:

```sh
flutter pub add shared_preferences url_launcher path_provider image_picker \
  sqflite connectivity_plus package_info_plus permission_handler \
  flutter_local_notifications webview_flutter local_auth \
  flutter_secure_storage google_mlkit_text_recognition firebase_core firebase_ai
```

The CocoaPods "before" used the per-project opt-out in `pubspec.yaml`:

```yaml
flutter:
  config:
    enable-swift-package-manager: false
```

Builds were `flutter build ios --simulator`, with a `flutter clean` before each one.

## Fixes the "before" needed

```ruby
# ios/Podfile: google_mlkit_commons needs iOS 15.5
platform :ios, '15.5'
```

```sh
pod install --repo-update   # "specs repository is too out-of-date"
```

## Firebase 12.19.3 on CocoaPods (status as of 4 November 2026)

`firebase_app_check` asked for `FirebaseAppCheck (~> 12.19.3)`, and no such pod exists. Until the FlutterFire fix (flutterfire#18862) ships, this override gets a CocoaPods build working again:

```ruby
# ios/Podfile
$FirebaseSDKVersion = '12.19.0'
```

Afterwards, check `Podfile.lock`. `FirebaseFirestore` should still resolve to 12.19.3, the version with the certificate fix. Under Swift Package Manager you don't need the override, because Firebase resolves to 13.x.

## The migration

Delete the two `config` lines from `pubspec.yaml` and the Firebase pin from the `Podfile`, then build again. Flutter edits the Xcode project for you. Read the warning that lists plugins without Swift Package Manager support.

## Checklist from the article

1. Upgrade to Flutter 3.44 or newer. Delete `enable-swift-package-manager: false` from the pubspec. If someone turned it off globally, run:
   ```sh
   flutter config --enable-swift-package-manager
   ```
2. Build once for iOS and macOS, and copy the "do not support Swift Package Manager" list into a ticket.
3. For each plugin on the list, check pub.dev for a newer version and look at its issue tracker. If it's abandoned, pick a replacement now.
4. Remove custom `Podfile` logic by hand and add those dependencies as Swift packages.
5. Check every scheme and flavor for the "Run Prepare Flutter Framework Script" pre-action.
6. When the list is empty, remove CocoaPods:
   ```sh
   cd ios
   pod deintegrate
   cd ..
   rm -rf ios/Podfile ios/Podfile.lock ios/Pods ios/.symlinks
   flutter clean
   flutter pub get
   ```
7. Build for a real device as well as the simulator (`flutter build ios --no-codesign`). Look for `duplicate symbol` errors from `GoogleDataTransport` in mixed mode.

The plugin status, versions and build times in the article are from 4 November 2026 (Apple M4 Max, Xcode 26.6). Nothing in this folder runs, and I haven't re-run these commands for the repo.
