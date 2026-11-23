# V17: Big Fonts Broke My Flutter App

Code for the Medium article "Big Fonts Broke My Flutter App".

- `app/lib/checkout_screen.dart`: the checkout screen as first written (`CheckoutScreen`) and fixed (`CheckoutScreenFixed`).
- `app/test/widget_test.dart`: 3 screen sizes x 4 text scales, counts overflow errors and checks the Pay button and the Pickup chip are tappable. Loads Roboto from `test/fonts` so text has real widths.
- `screens/`: Android 16 emulator (release, 360x640 dp) and iOS 26 simulator screenshots.
- `RESULTS.md`: every number in the article.

Run it with Flutter 3.50.0:

```
cd app
flutter test                                  # results/run.txt, goldens in test/shots
flutter run --release                         # the screen as first written
flutter run --release --dart-define=FIXED=true  # the fixed screen
```

Change the font size in the phone's settings, then reopen the app.
