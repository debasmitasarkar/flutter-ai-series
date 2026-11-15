import 'dart:io';

import 'package:jnigen/jnigen.dart';

void main(List<String> args) async {
  final root = Platform.script.resolve('../');
  final generator = JniGenerator(
    input: Input(
      classes: [
        'android.os.SystemClock',
        'android.os.Build',
        'android.os.Looper',
      ],
      androidSdk: AndroidSdk(addGradleDeps: true, androidExample: root),
    ),
    output: Output(
      dart: DartOutput(
        path: root.resolve('lib/android_api.g.dart'),
        structure: OutputStructure.singleFile,
      ),
    ),
  );
  await generator.generate();
}
