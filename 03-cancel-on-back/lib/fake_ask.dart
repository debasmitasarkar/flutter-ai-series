import 'dart:async';

import 'package:flutter/foundation.dart';

Stream<String> fakeAsk(String prompt) {
  const words = ['Sure', ', ', 'cancelling ', 'is ', 'two ', 'calls', '.'];
  Timer? timer;
  var i = 0;
  late final StreamController<String> c;
  c = StreamController<String>(
    onListen: () {
      timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
        if (i < words.length) {
          c.add(words[i++]);
        } else {
          timer?.cancel();
          c.close();
        }
      });
    },
    onCancel: () {
      timer?.cancel();
      debugPrint('fakeAsk: stopped after $i words');
    },
  );
  return c.stream;
}
