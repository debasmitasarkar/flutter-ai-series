import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --dart-define=FIXED=true builds the version with the state fix.
const fixed = bool.fromEnvironment('FIXED');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // The classic "phone app" lock. Android ignores it on large screens
  // for apps that target API 36.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const FoldLabApp());
  // Same starting point on every run: scroll, open an order, type, play.
  Timer(const Duration(seconds: 3), Lab.instance.setUp);
}

class FoldLabApp extends StatelessWidget {
  const FoldLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: fixed ? const FixedHome() : const NaiveHome(),
    );
  }
}

final orders = List.generate(200, (i) => 'Order #${1000 + i}');

// ---------------------------------------------------------------------------
// BEFORE: the adaptive layout most of us write first.
// ---------------------------------------------------------------------------
class NaiveHome extends StatefulWidget {
  const NaiveHome({super.key});

  @override
  State<NaiveHome> createState() => _NaiveHomeState();
}

class _NaiveHomeState extends State<NaiveHome> {
  int? selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders (before)')),
      body: LayoutBuilder(
        builder: (context, box) {
          if (box.maxWidth >= 600) {
            return Row(
              children: [
                Expanded(child: OrderList(onTap: _select)),
                const VerticalDivider(width: 1),
                Expanded(
                  child: selected == null
                      ? const Center(child: Text('Pick an order'))
                      : OrderDetail(index: selected!),
                ),
              ],
            );
          }
          return selected == null
              ? OrderList(onTap: _select)
              : OrderDetail(index: selected!, onBack: () => _select(null));
        },
      ),
    );
  }

  void _select(int? i) => setState(() => selected = i);
}

// ---------------------------------------------------------------------------
// AFTER: same screens, but every pane keeps its State when the layout changes.
// ---------------------------------------------------------------------------
class FixedHome extends StatefulWidget {
  const FixedHome({super.key});

  @override
  State<FixedHome> createState() => _FixedHomeState();
}

class _FixedHomeState extends State<FixedHome> {
  final _listKey = GlobalKey();
  final _detailKey = GlobalKey();
  int? selected;

  @override
  Widget build(BuildContext context) {
    final list = OrderList(key: _listKey, onTap: _select);
    final detail = selected == null
        ? const Center(child: Text('Pick an order'))
        : OrderDetail(
            key: _detailKey,
            index: selected!,
            onBack: () => _select(null),
          );
    return Scaffold(
      appBar: AppBar(title: const Text('Orders (after)')),
      body: LayoutBuilder(
        builder: (context, box) {
          if (box.maxWidth >= 600) {
            return Row(
              children: [
                Expanded(child: list),
                const VerticalDivider(width: 1),
                Expanded(child: detail),
              ],
            );
          }
          // Narrow: keep both panes alive, show one.
          return IndexedStack(
            index: selected == null ? 0 : 1,
            children: [list, detail],
          );
        },
      ),
    );
  }

  void _select(int? i) => setState(() => selected = i);
}

// ---------------------------------------------------------------------------
// The panes. Each owns its state the way most apps do: in its own State.
// ---------------------------------------------------------------------------
class OrderList extends StatefulWidget {
  const OrderList({super.key, required this.onTap});
  final ValueChanged<int> onTap;

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
    Lab.instance.list = this;
    Lab.instance.log('list initState');
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      itemCount: orders.length,
      itemExtent: 64,
      itemBuilder: (context, i) => ListTile(
        title: Text(orders[i]),
        subtitle: const Text('2 items · Pickup'),
        onTap: () => widget.onTap(i),
      ),
    );
  }
}

class OrderDetail extends StatefulWidget {
  const OrderDetail({super.key, required this.index, this.onBack});
  final int index;
  final VoidCallback? onBack;

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  final note = TextEditingController();
  // Stand-in for a video: a playback position that ticks every 100 ms.
  int positionMs = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    Lab.instance.detail = this;
    Lab.instance.log('detail initState');
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() => positionMs += 100);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    if (Lab.instance.detail == this) Lab.instance.detail = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = positionMs ~/ 1000;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            if (widget.onBack != null)
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
              ),
            Text(
              orders[widget.index],
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 160,
          color: Colors.black87,
          alignment: Alignment.center,
          child: Text(
            '▶ ${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white, fontSize: 32),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: note,
          decoration: const InputDecoration(
            labelText: 'Delivery note',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Lab: logs the state we care about after every window change, and sets up
// the same starting state on every run (scroll, select, type, play).
// ---------------------------------------------------------------------------
class Lab with WidgetsBindingObserver {
  Lab._();
  static final instance = Lab._()..start();

  _OrderListState? list;
  _OrderDetailState? detail;
  Timer? _debounce;

  void start() => WidgetsBinding.instance.addObserver(this);

  void setUp() {
    list!.controller.jumpTo(2400);
    list!.widget.onTap(40);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      detail!.note.text = 'Leave at the back door';
      Timer(const Duration(seconds: 2), () => log('setup'));
    });
  }

  void log(String event) {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    final scroll = (list?.controller.hasClients ?? false)
        ? list!.controller.offset.round()
        : -1;
    // ignore: avoid_print
    print('V15STATE $event '
        'size=${size.width.round()}x${size.height.round()} '
        'scroll=$scroll '
        'note="${detail?.note.text ?? '-'}" '
        'playMs=${detail?.positionMs ?? -1}');
  }

  @override
  void didChangeMetrics() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1500), () => log('metrics'));
  }
}
