# Flutter 3.50: your app moved to material_ui, your packages didn't

Code for [Your App Moved to material_ui. Your Packages Didn't.](https://medium.com/p/d04e2feab6c7)

Built and run on **Flutter 3.50.0 stable / Dart 3.14.0**, material_ui 1.11.0.

- `app/lib/main.dart` - two screens:
  - `--dart-define=SCREEN=fab`: flutter_expandable_fab with `ExpandableFab.location`. Works on 3.0.0 (material_ui). On 2.5.2 (flutter/material.dart) the location line doesn't compile, and without it the button never becomes visible.
  - default theme screen: my material_ui FAB next to a `flutter/material.dart` FAB (standing in for an un-migrated package). Add `--dart-define=BRIDGE=true` to wrap it in `MaterialUiCompatibilityBridge`.
- `app/test/bridge_test.dart` - without the bridge the old-library FAB gets a different colour scheme; with it the colours match but `floatingActionButtonTheme.shape` is not carried over.
- `app/tool/legacy_imports.dart` - lists the packages in your app that still import `flutter/material.dart` or `cupertino.dart`. Copy it into your own app's `tool/` and run `dart run tool/legacy_imports.dart` after `flutter pub get`.

## Run

```
cd app
flutter create . --platforms=ios,web   # platform folders are not committed
flutter test
flutter run --dart-define=SCREEN=fab
flutter run --dart-define=BRIDGE=true
```

To see traps 1 and 2 from the article: `flutter pub add flutter_expandable_fab:^2.0.0`, then `flutter analyze` (trap 1), then delete the `floatingActionButtonLocation` line and run the fab screen (trap 2).
