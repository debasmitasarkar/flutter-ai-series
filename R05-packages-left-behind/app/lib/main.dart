// The 'package FAB' on the theme screen stands in for any un-migrated package.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:material_ui/material_ui.dart';

// --dart-define=BRIDGE=true wraps the screen in MaterialUiCompatibilityBridge.
// --dart-define=SCREEN=fab shows the ExpandableFab screen instead.
const useBridge = bool.fromEnvironment('BRIDGE');
const screen = String.fromEnvironment('SCREEN', defaultValue: 'theme');

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key, this.bridge = useBridge});

  final bool bridge;

  @override
  Widget build(BuildContext context) {
    final home = screen == 'fab' ? const FabScreen() : ThemeScreen(bridge: bridge);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE65100)),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: CircleBorder(),
        ),
      ),
      home: bridge
          // ignore: deprecated_member_use
          ? MaterialUiCompatibilityBridge(child: home)
          : home,
    );
  }
}

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key, required this.bridge});

  final bool bridge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(bridge ? 'With the bridge' : 'No bridge')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Labelled(
              label: 'my FAB\nmaterial_ui',
              child: FloatingActionButton(
                heroTag: 'mine',
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
            _Labelled(
              label: 'a package FAB\nflutter/material.dart',
              child: legacy.FloatingActionButton(
                heroTag: 'theirs',
                onPressed: () {},
                child: const legacy.Icon(legacy.Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 12),
        Text(label, textAlign: TextAlign.center),
      ],
    );
  }
}

class FabScreen extends StatefulWidget {
  const FabScreen({super.key});

  @override
  State<FabScreen> createState() => _FabScreenState();
}

class _FabScreenState extends State<FabScreen> {
  final _fabKey = GlobalKey<ExpandableFabState>();

  @override
  void initState() {
    super.initState();
    // Open and close the menu on a loop so the recording shows it working.
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(milliseconds: 1800));
      if (!mounted) return false;
      _fabKey.currentState?.toggle();
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutter_expandable_fab')),
      body: const Center(child: Text('The menu button lives bottom right.')),
      // Needs flutter_expandable_fab 3.0.0 (material_ui). With 2.5.2 this line
      // doesn't compile, and without it the button stays at opacity 0.
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _fabKey,
        children: [
          FloatingActionButton.small(
            heroTag: 'edit',
            onPressed: () {},
            child: const Icon(Icons.edit),
          ),
          FloatingActionButton.small(
            heroTag: 'share',
            onPressed: () {},
            child: const Icon(Icons.share),
          ),
        ],
      ),
    );
  }
}
