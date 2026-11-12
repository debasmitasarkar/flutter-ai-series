import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final demo = Uri.base.queryParameters['demo'] ?? 'clip';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF0175C2)),
      home: switch (demo) {
        'blur' => const BlurDialogDemo(),
        'motion' => const ReduceMotionDemo(),
        _ => const SliverClipDemo(),
      },
    );
  }
}

// 1. SliverClipRRect: rounded sections that slide under a pinned header.
class SliverClipDemo extends StatelessWidget {
  const SliverClipDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Flutter 3.50 favourites'),
            backgroundColor: scheme.primary.withValues(alpha: 0.85),
            foregroundColor: scheme.onPrimary,
          ),
          for (final section in const ['Framework', 'Web', 'iOS', 'Android'])
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverClipRRect(
                borderRadius: BorderRadius.circular(24),
                clipOverlap: ClipOverlapBehavior.preserveShape,
                sliver: SliverList.builder(
                  itemCount: 6,
                  itemBuilder: (context, i) => Container(
                    height: 64,
                    color: i == 0 ? scheme.primaryContainer : scheme.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      i == 0 ? section : '$section update #$i',
                      style: i == 0
                          ? Theme.of(context).textTheme.titleMedium
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 400)),
        ],
      ),
    );
  }
}

// 2. barrierBuilder on showGeneralDialog: a blurred backdrop.
class BlurDialogDemo extends StatelessWidget {
  const BlurDialogDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My very busy screen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 1; i <= 8; i++)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('$i')),
                title: Text('Something important #$i'),
                subtitle: const Text('Very distracting content'),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showBlurDialog(context),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Ask the AI'),
      ),
    );
  }
}

Future<void> showBlurDialog(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    transitionDuration: const Duration(milliseconds: 300),
    barrierBuilder: (context, details, barrier) => AnimatedBuilder(
      animation: details.animation,
      builder: (context, child) {
        final sigma = 8 * details.animation.value;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: child,
        );
      },
      child: barrier,
    ),
    pageBuilder: (context, animation, secondaryAnimation) => Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Focus mode', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 12),
              const Text('Everything behind me is blurred.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to the chaos'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// 3. MediaQueryData.reduceMotion: fade instead of slide.
class ReduceMotionDemo extends StatefulWidget {
  const ReduceMotionDemo({super.key});

  @override
  State<ReduceMotionDemo> createState() => _ReduceMotionDemoState();
}

class _ReduceMotionDemoState extends State<ReduceMotionDemo> {
  // Simulates the OS Reduce Motion setting so the demo can toggle it.
  bool _reduceMotion = false;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(reduceMotion: _reduceMotion),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Reduce Motion')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Reduce Motion (OS setting)'),
                  value: _reduceMotion,
                  onChanged: (v) => setState(() => _reduceMotion = v),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(context)
                          .push(gentleRoute(context, const DetailsPage())),
                  child: const Text('Open details'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Route<void> gentleRoute(BuildContext context, Widget page) {
  final reduceMotion = MediaQuery.reduceMotionOf(context);
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 450),
    reverseTransitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (reduceMotion) {
        return FadeTransition(opacity: animation, child: child);
      }
      return SlideTransition(
        position: Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
        child: child,
      );
    },
  );
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: const Center(
        child: Text('Arrived!', style: TextStyle(fontSize: 28)),
      ),
    );
  }
}
