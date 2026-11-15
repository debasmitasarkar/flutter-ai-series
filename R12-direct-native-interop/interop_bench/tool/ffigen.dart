import 'dart:io';

import 'package:ffigen/ffigen.dart';

const wanted = {'NSProcessInfo', 'NSThread'};

Future<void> main() async {
  final root = Platform.script.resolve('../');
  final sdk = (Process.runSync('xcrun', ['--sdk', 'iphoneos', '--show-sdk-path']).stdout as String).trim();
  final generator = FfiGenerator(
    input: Input(
      entryPoints: [
        Uri.file(
          '$sdk/System/Library/Frameworks/Foundation.framework/Headers/Foundation.h',
        ),
      ],
    ),
    objectiveC: const ObjectiveC(),
    visitors: [
      Visitor(
        objCInterface: (node) => node.isIncluded = wanted.contains(node.originalName),
      ),
    ],
    output: Output(
      dart: DartOutput(path: root.resolve('lib/ios_api.g.dart')),
      objectiveCFile: root.resolve('ios/Runner/ios_api.g.m'),
    ),
  );
  await generator.generate();
}
