// ignore_for_file: avoid_print
// Lists every package in this app that picks an implementation with
// `if (dart.library.html)` and has no `dart.library.js_interop` branch in the
// same import. With --no-deprecated-js-interop and with --wasm, those imports
// resolve to false, so the package quietly takes its other branch.
//
// Run from the app folder after `flutter pub get`:
//   dart run tool/find_html_conditionals.dart
import 'dart:convert';
import 'dart:io';

final _directive = RegExp(r'''(?:import|export)\s+['"][^'"]+['"]([^;]*);''');

void main() {
  final config = File('.dart_tool/package_config.json');
  final packages = (jsonDecode(config.readAsStringSync())['packages'] as List)
      .cast<Map<String, dynamic>>();
  var found = 0;
  for (final package in packages) {
    // sky_engine is Flutter's own engine library; the SDK handles it.
    if (package['name'] == 'sky_engine') continue;
    final rootUri = package['rootUri'] as String;
    final root = config.absolute.uri.resolve(rootUri.endsWith('/') ? rootUri : '$rootUri/');
    final lib = Directory.fromUri(root.resolve(package['packageUri'] as String? ?? 'lib/'));
    if (!lib.existsSync()) continue;
    for (final file in lib.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      for (final match in _directive.allMatches(file.readAsStringSync())) {
        final branches = match.group(1)!;
        if (branches.contains('dart.library.html') &&
            !branches.contains('dart.library.js_interop')) {
          found++;
          print('${package['name']}: ${file.path.substring(lib.path.length)}');
        }
      }
    }
  }
  print(found == 0 ? 'No dart.library.html-only conditionals.' : '$found import(s) to check.');
}
