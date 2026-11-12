# Flutter 3.50: migrating to material_ui and cupertino_ui

Code for [My Favourite Updates in Flutter 3.50 (and Dart 3.14)](https://medium.com/p/529b79c19d73).

A small app first written on Flutter 3.38 (go_router, google_fonts, localization delegates, a `ThemeExtension`, a `CupertinoSwitch`, a widget test), migrated on **Flutter 3.50.0 stable / Dart 3.14.0**.

- `favourites_demo/` - the app behind the GIFs: blurred dialog backdrop (`barrierBuilder` on `showGeneralDialog`), `MediaQuery.reduceMotionOf` fade-vs-slide, `SliverClipRRect` sections. Run `flutter create . --platforms=web` once, then `flutter run -d chrome` and add `?demo=blur`, `?demo=motion` or `?demo=clip` to the URL.
- `before/` - the 3.38 version (`main.dart.txt`, `pubspec.yaml.txt`)
- `lib/`, `test/`, `pubspec.yaml` - after the migration

## What I ran

```
dart fix --apply --code=migrate_design_widgets
```

It rewrote the imports in `lib/` and `test/` and added the two packages. Then four manual fixes:

1. Pin `material_ui: ^1.11.0` and `cupertino_ui: ^1.1.6` (the fix adds them as `any`).
2. Remove the `flutter_localizations` import (otherwise `GlobalMaterialLocalizations` is an ambiguous import).
3. `localizationsDelegates: GlobalMaterialLocalizations.delegates` from `material_ui`.
4. `google_fonts: ^9.0.0` (6.x returns the old `TextTheme` type).

Plain `dart fix --apply` (without `--code`) imported `material_ui` and `cupertino_ui` twice each on my run.

## Run it

```
flutter create . --platforms=web   # platform folders are not committed
flutter pub get
flutter analyze
flutter test
flutter build web --release --web-content-hash
```

Tested with Flutter 3.50.0 (stable), Dart 3.14.0.
