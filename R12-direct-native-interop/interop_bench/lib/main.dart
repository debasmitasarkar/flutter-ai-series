import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import 'src/bench.dart';
import 'src/race_page.dart';

void main() => runApp(const BenchApp());

class BenchApp extends StatelessWidget {
  const BenchApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    home: const bool.fromEnvironment('AUTORACE')
        ? const RacePage()
        : const BenchPage(),
  );
}

class BenchPage extends StatefulWidget {
  const BenchPage({super.key});

  @override
  State<BenchPage> createState() => _BenchPageState();
}

class _BenchPageState extends State<BenchPage> {
  Map<String, Object>? _out;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      final out = await runAll();
      // One line the laptop can grep from the device log.
      debugPrint('BENCH ${jsonEncode(out)}');
      setState(() => _out = out);
    });
  }

  @override
  Widget build(BuildContext context) {
    final out = _out;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channel vs direct interop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const RacePage()),
            ),
          ),
        ],
      ),
      body: out == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('1,000 calls each, median / p95 in µs',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                for (final r in (out['results']! as List).cast<Map>())
                  if (r.containsKey('medianUs'))
                    ListTile(
                      dense: true,
                      title: Text('${r['name']}'),
                      trailing: Text('${r['medianUs']} / ${r['p95Us']}',
                          style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
                    ),
                const Divider(),
                Text('main isolate on main thread: ${jsonEncode(out['mainIsolate isMainThread'])}'),
                Text('OS: ${out['osVersion']}'),
              ],
            ),
    );
  }
}
