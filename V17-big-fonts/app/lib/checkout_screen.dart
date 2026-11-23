import 'package:material_ui/material_ui.dart';

/// The screen as I'd write it on a Friday afternoon.
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product card with a fixed height.
            Container(
              height: 96,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EEFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.headphones, size: 48),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Noise-cancelling headphones',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Midnight blue · 1 item'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Delivery options as chips in a Row.
            Row(
              children: const [
                ChoiceChip(label: Text('Standard'), selected: true),
                SizedBox(width: 8),
                ChoiceChip(label: Text('Express'), selected: false),
                SizedBox(width: 8),
                ChoiceChip(label: Text('Pickup'), selected: false),
              ],
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'Discount code'),
            ),
            const SizedBox(height: 16),
            const _PriceRow('Subtotal', '€129.00'),
            const _PriceRow('Delivery', '€4.99'),
            const _PriceRow('Total', '€133.99', bold: true),
            const Spacer(),
            Row(
              children: [
                const Text('By paying you accept the terms of sale.'),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: FilledButton(
                key: const Key('pay'),
                onPressed: () {},
                child: const Text('Pay €133.99'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow(this.label, this.value, {this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: bold ? FontWeight.bold : null);
    return SizedBox(
      height: 28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}

/// The same screen after the fixes.
class CheckoutScreenFixed extends StatelessWidget {
  const CheckoutScreenFixed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // No fixed height: the card grows with its text.
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EEFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.headphones, size: 48),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Noise-cancelling headphones',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('Midnight blue · 1 item'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Wrap instead of Row: chips go to the next line.
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(label: Text('Standard'), selected: true),
                      ChoiceChip(label: Text('Express'), selected: false),
                      ChoiceChip(label: Text('Pickup'), selected: false),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(labelText: 'Discount code'),
                  ),
                  const SizedBox(height: 16),
                  const _PriceRowFixed('Subtotal', '€129.00'),
                  const _PriceRowFixed('Delivery', '€4.99'),
                  const _PriceRowFixed('Total', '€133.99', bold: true),
                  const SizedBox(height: 16),
                  const Text('By paying you accept the terms of sale.'),
                ],
              ),
            ),
            // The button stays pinned and always reachable.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: FilledButton(
                  key: const Key('pay'),
                  onPressed: () {},
                  child: const Text('Pay €133.99', textAlign: TextAlign.center),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRowFixed extends StatelessWidget {
  const _PriceRowFixed(this.label, this.value, {this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: bold ? FontWeight.bold : null);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 8),
          Text(value, style: style),
        ],
      ),
    );
  }
}
