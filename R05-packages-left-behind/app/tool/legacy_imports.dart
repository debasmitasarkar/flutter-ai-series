// ignore_for_file: avoid_print
// Lists the packages in your app that still import the old design libraries.
// Run from your app folder after `flutter pub get`:
//   dart run tool/legacy_imports.dart
import 'dart:convert';
import 'dart:io';

final legacy = RegExp(
  r'''^\s*(import|export)\s+['"]package:flutter/(material|cupertino)\.dart['"]''',
  multiLine: true,
);

void main() {
  final config =
      jsonDecode(File('.dart_tool/package_config.json').readAsStringSync())
          as Map<String, dynamic>;
  final base = Directory.current.uri.resolve('.dart_tool/');

  for (final pkg in config['packages'] as List) {
    final name = pkg['name'] as String;
    final rootUri = pkg['rootUri'] as String;
    if (rootUri == '../') continue; // your own app
    // Their compatibility bridges import the old libraries on purpose.
    if (name == 'material_ui' || name == 'cupertino_ui') continue;
    final root = base.resolve(rootUri.endsWith('/') ? rootUri : '$rootUri/');
    if (root.path.contains('/packages/flutter')) continue; // the SDK itself
    final lib = Directory.fromUri(root.resolve('lib/'));
    if (!lib.existsSync()) continue;

    final hits = lib
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => legacy.hasMatch(f.readAsStringSync()))
        .length;
    if (hits > 0)
      print('$name: $hits file(s) still import flutter/material or cupertino');
  }
}
