import 'package:flutter/material.dart';

import 'shop_screen.dart';

void main() => runApp(const UpgradeApp());

class UpgradeApp extends StatelessWidget {
  const UpgradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF00796B)),
      home: const ShopScreen(),
    );
  }
}
