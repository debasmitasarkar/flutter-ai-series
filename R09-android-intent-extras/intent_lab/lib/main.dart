import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Widgets only (no material/material_ui), so this file builds on 3.38 and 3.50.
const _lab = MethodChannel('intent_lab');

void main() => _start('main');

// A second entrypoint, the kind a QA build might launch with `--es dart_entrypoint`.
@pragma('vm:entry-point')
void qaMain() => _start('qaMain');

void _start(String entry) {
  WidgetsFlutterBinding.ensureInitialized();
  final route = PlatformDispatcher.instance.defaultRouteName;
  // One greppable line per launch: `adb logcat -s flutter`.
  debugPrint('LAB entry=$entry route=$route');
  runApp(LabApp(entry: entry, route: route));
}

class LabApp extends StatelessWidget {
  const LabApp({super.key, required this.entry, required this.route});

  final String entry;
  final String route;

  @override
  Widget build(BuildContext context) {
    // A deep link arrives as the full URI (intentlab://open/checkout), so compare the path.
    final path = Uri.parse(route).path;
    final landed = path == '/' || path.isEmpty ? 'HOME' : path.toUpperCase();
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: landed == 'HOME' ? const Color(0xFF1E293B) : const Color(0xFF0F766E),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(landed, style: const TextStyle(fontSize: 44, color: Color(0xFFFFFFFF))),
              const SizedBox(height: 12),
              Text('route: $route', style: _small),
              Text('entrypoint: $entry', style: _small),
              const SizedBox(height: 32),
              _Button('notify with route /checkout', () => _lab.invokeMethod('notify')),
              const SizedBox(height: 12),
              _Button('relaunch myself with /checkout', () => _lab.invokeMethod('relaunch')),
              const SizedBox(height: 24),
              _Button('notify with deep link', () => _lab.invokeMethod('notify_link')),
              const SizedBox(height: 12),
              _Button('relaunch with deep link', () => _lab.invokeMethod('relaunch_link')),
            ],
          ),
        ),
      ),
    );
  }
}

const _small = TextStyle(fontSize: 18, color: Color(0xFFCBD5E1));

class _Button extends StatelessWidget {
  const _Button(this.label, this.onTap);

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, color: Color(0xFFFFFFFF))),
      ),
    );
  }
}
