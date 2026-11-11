import 'dart:convert';

/// Emits a big structured-output reply in small chunks, like an SSE stream would.
Stream<String> fakeStructuredReply({int products = 4000, int chunkSize = 2048}) async* {
  final raw = jsonEncode({
    'query': 'headphones under 300 for flights',
    'summary': 'Here are the best matches.',
    'products': [
      for (var i = 0; i < products; i++)
        {
          'id': 'sku-$i',
          'name': 'Headphones model $i',
          'price': 199.0 + i % 50,
          'currency': 'EUR',
          'tags': ['audio', 'anc'],
          'specs': [
            {'label': 'Battery', 'value': '${20 + i % 20} h'},
          ],
          'why': 'Strong noise cancelling and a long battery, which you asked for.',
        },
    ],
  });
  for (var i = 0; i < raw.length; i += chunkSize) {
    await Future<void>.delayed(const Duration(milliseconds: 2));
    yield raw.substring(i, i + chunkSize > raw.length ? raw.length : i + chunkSize);
  }
}
