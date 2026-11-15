import 'package:material_ui/material_ui.dart';

import 'native_api.dart';

/// 10,000 calls each way, side by side. Same native API, two paths.
class RacePage extends StatefulWidget {
  const RacePage({super.key});

  @override
  State<RacePage> createState() => _RacePageState();
}

class _RacePageState extends State<RacePage> {
  static const total = 10000;
  final _direct = DirectApi.forPlatform();
  final _channel = ChannelApi();
  int _directDone = 0, _channelDone = 0;
  Duration? _directTime, _channelTime;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    // Used to record the demo GIF: --dart-define=AUTORACE=true
    if (const bool.fromEnvironment('AUTORACE')) {
      Future.delayed(const Duration(milliseconds: 1500), _race);
    }
  }

  Future<void> _race() async {
    setState(() {
      _running = true;
      _directDone = _channelDone = 0;
      _directTime = _channelTime = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // Direct: synchronous, so 10,000 calls fit in one go.
    final sw = Stopwatch()..start();
    for (var i = 0; i < total; i++) {
      _direct.uptimeMs();
    }
    setState(() {
      _directDone = total;
      _directTime = sw.elapsed;
    });

    // Channel: every call is a message to the platform thread and back.
    sw.reset();
    for (var i = 1; i <= total; i++) {
      await _channel.uptimeMs();
      if (i % 250 == 0) setState(() => _channelDone = i);
    }
    setState(() {
      _channelTime = sw.elapsed;
      _running = false;
    });
  }

  Widget _lane(String label, int done, Duration? time, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(
              time == null ? '$done / $total' : '${(time.inMicroseconds / 1000).toStringAsFixed(1)} ms',
              style: const TextStyle(fontSize: 18, fontFeatures: [FontFeature.tabularFigures()]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: done / total,
            minHeight: 22,
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('10,000 native calls')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _lane('Direct (${DirectApi.label})', _directDone, _directTime, Colors.teal),
          _lane('MethodChannel', _channelDone, _channelTime, Colors.deepOrange),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _running ? null : _race,
            child: const Text('Race'),
          ),
        ],
      ),
    ),
  );
}
