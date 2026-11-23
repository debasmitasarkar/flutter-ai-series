import 'package:flutter/material.dart';

/// Product names come from the CMS with soft hyphens (­) so long
/// German words can break inside narrow cards.
const products = [
  ('Geschirr­spül­maschine', '€499'),
  ('Kühl­schrank­thermo­meter', '€12'),
  ('Kopf­hörer­verstärker', '€89'),
  ('Wasser­kocher', '€35'),
];

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [for (final p in products) ProductCard(p.$1, p.$2)],
              ),
              const SizedBox(height: 24),
              const OrderStatusBubble(),
            ],
          ),
          // A loading overlay that blocks taps but keeps semantics.
          IgnorePointer(
            ignoring: busy,
            child: const SizedBox.expand(),
          ),
          // Checkout bar pinned to the bottom edge. No SafeArea: on mobile
          // web the page never reached the home indicator anyway.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              key: const Key('checkoutBar'),
              color: const Color(0xFF00796B),
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Checkout · €635',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard(this.name, this.price, {super.key});
  final String name;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(price),
        ],
      ),
    );
  }
}

/// Arabic order status with two inline icons: a truck, then a "2 items" badge.
/// In 3.38 the icons landed in source order inside RTL text, so I reversed
/// the spans for RTL to make them look right. (The usual workaround.)
class OrderStatusBubble extends StatelessWidget {
  const OrderStatusBubble({super.key, this.reverseForRtl = true});
  final bool reverseForRtl;

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[
      const WidgetSpan(child: Icon(Icons.local_shipping, size: 20, key: Key('truck'))),
      const TextSpan(text: ' تم شحن طلبك '),
      const WidgetSpan(child: _Badge('2', key: Key('badge'))),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text.rich(
          TextSpan(children: reverseForRtl ? spans.reversed.toList() : spans), // RTL workaround
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFFE65100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }
}
