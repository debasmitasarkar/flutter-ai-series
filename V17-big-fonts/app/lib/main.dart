import 'package:material_ui/material_ui.dart';

import 'checkout_screen.dart';

void main() =>
    runApp(const BigFontsApp(fixed: bool.fromEnvironment('FIXED')));

class BigFontsApp extends StatelessWidget {
  const BigFontsApp({super.key, this.fixed = false});

  /// false = the screen as I first wrote it, true = after the fixes.
  final bool fixed;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        // Logs what the OS font setting turns 14 and 24 pt into.
        final s = MediaQuery.textScalerOf(context);
        debugPrint('textScaler 14->${s.scale(14).toStringAsFixed(1)} '
            '24->${s.scale(24).toStringAsFixed(1)}');
        return child!;
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF5B4BDB)),
      home: fixed ? const CheckoutScreenFixed() : const CheckoutScreen(),
    );
  }
}
