# 5 Migrations to Finish Before Flutter 3.50 Lands

Article: https://medium.com/p/4061a1113128

Release prep before Flutter 3.50. The article has no runnable project, so this folder is the checklist with the commands and snippets from the article, in the order the article does them. Read the article for the reasons behind each step.

## Step 0: upgrade to 3.47.8 (eMudhra CA distrust)

On Android and Windows, `dart:io` uses its own root bundle, so updating the OS doesn't fix this. Rebuild.

```sh
flutter upgrade
flutter --version   # 3.47.8, Dart 3.13.7
flutter build appbundle --release
flutter build windows --release
```

## 1. Material and Cupertino move to `material_ui` / `cupertino_ui`

```sh
dart fix --apply --code=migrate_design_widgets
```

```dart
// before
import 'package:flutter/material.dart';

// after
import 'package:material_ui/material_ui.dart';
```

If the fix trips over your `pubspec.yaml`:

```sh
flutter pub add material_ui
dart fix --apply --code=migrate_design_widgets
```

Localisation:

```dart
MaterialApp(
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  supportedLocales: const [Locale('en'), Locale('hi'), Locale('de')],
  home: const HomeScreen(),
)
```

Bridge for dependencies that still import the SDK copy:

```dart
MaterialApp(
  builder: (context, child) => MaterialUiCompatibilityBridge(child: child!),
  home: const HomeScreen(),
)

// or, surgically
Scaffold(
  appBar: AppBar(title: const Text('Settings')),
  body: MaterialUiCompatibilityBridge(child: LegacyPackageWidget()),
)
```

## 2. UIScene before Xcode 27

Run `flutter run` or `flutter build ios` and look for:

```
Finished migration to UIScene lifecycle
```

If you get a warning instead, the manual migration is two edits. In `AppDelegate.swift`:

```swift
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // GeneratedPluginRegistrant.register(with: self)  <- gone from here
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // method channels and platform views move here too:
    let channel = FlutterMethodChannel(
      name: "samples.flutter.dev/battery",
      binaryMessenger: engineBridge.applicationRegistrar.messenger())
  }
}
```

In `Info.plist`:

```xml
<key>UIApplicationSceneManifest</key>
<dict>
  <key>UIApplicationSupportsMultipleScenes</key>
  <false/>
  <key>UISceneConfigurations</key>
  <dict>
    <key>UIWindowSceneSessionRoleApplication</key>
    <array>
      <dict>
        <key>UISceneClassName</key>
        <string>UIWindowScene</string>
        <key>UISceneDelegateClassName</key>
        <string>FlutterSceneDelegate</string>
        <key>UISceneConfigurationName</key>
        <string>flutter</string>
        <key>UISceneStoryboardFile</key>
        <string>Main</string>
      </dict>
    </array>
  </dict>
</dict>
```

Watch out for `window?.rootViewController as! FlutterViewController` in `didFinishLaunchingWithOptions`, which now crashes. Move that code to `didInitializeImplicitFlutterEngine`. The `applicationDidBecomeActive`-style callbacks move to a `SceneDelegate` that subclasses `FlutterSceneDelegate`.

## 3. Minimum iOS 15 and macOS 12

Check your analytics before you bump the target.

```ruby
# ios/Podfile
platform :ios, '15.0'
```

## 4. Swift Package Manager is the default, and CocoaPods trunk goes read-only on 2 December 2026

Build once and read the list of plugins without Swift package support. The temporary opt-out goes in `pubspec.yaml`. Don't leave it there forever:

```yaml
flutter:
  config:
    enable-swift-package-manager: false
```

The full migration is in [R03](../R03-cocoapods-to-spm).

## 5. Desktop: Intel Macs and Impeller

```sh
flutter config --enable-macos-arm64-only
```

Impeller is the default on macOS, Windows and Linux. Retest custom fragment shaders, because OpenGLES texture coordinates are no longer flipped implicitly.

## Bonus (can wait for 2027): Wasm

Move from `dart:html` to `package:web`. `dart fix` can do part of it.

## Checklist

- [ ] Upgrade to 3.47.8, then rebuild Android, Windows and Linux
- [ ] `dart fix --apply --code=migrate_design_widgets`, fix localisations, bridge the stragglers
- [ ] Build for iOS and confirm "Finished migration to UIScene lifecycle", or make the two edits
- [ ] Bump to iOS 15 / macOS 12 after checking analytics
- [ ] Work through the Swift Package Manager warning list before 2 December
- [ ] Go ARM-only on macOS if you can, and retest custom shaders under Impeller

The versions and dates above are as of the article (31 October 2026). Nothing in this folder runs, and I haven't re-run these commands for the repo.
