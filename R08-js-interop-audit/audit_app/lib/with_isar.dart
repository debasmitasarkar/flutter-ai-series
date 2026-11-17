// Finding 1 from the article: build this entry point with the flag (or --wasm)
// and count the errors.
//   flutter build web --no-deprecated-js-interop -t lib/with_isar.dart
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';

void main() {
  debugPrint('isar ${Isar.version}');
  runApp(const Center(child: Text('isar', textDirection: TextDirection.ltr)));
}
