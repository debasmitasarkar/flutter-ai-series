import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  const BrandColors({required this.accent});
  final Color accent;
  @override
  BrandColors copyWith({Color? accent}) => BrandColors(accent: accent ?? this.accent);
  @override
  BrandColors lerp(BrandColors? other, double t) =>
      BrandColors(accent: Color.lerp(accent, other?.accent, t)!);
}

final router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
  GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
]);

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        textTheme: GoogleFonts.interTextTheme(),
        extensions: const [BrandColors(accent: Colors.pink)],
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en'), Locale('de')],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: Center(child: Text('Hello', style: TextStyle(color: brand.accent))),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: CupertinoSwitch(value: true, onChanged: (_) {}),
      ),
    );
  }
}
