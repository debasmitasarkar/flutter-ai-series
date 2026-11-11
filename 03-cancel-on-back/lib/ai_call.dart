import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AiCall {
  AiCall(this.prompt);

  final String prompt;
  final text = ValueNotifier<String>('');
  final isDone = ValueNotifier<bool>(false);

  final _token = CancelToken();
  StreamSubscription<String>? _sub;

  Future<void> start(Dio dio) async {
    try {
      final res = await dio.post<ResponseBody>(
        '/v1/chat/stream',
        data: {'prompt': prompt},
        options: Options(responseType: ResponseType.stream),
        cancelToken: _token,
      );
      _sub = res.data!.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .where((l) => l.startsWith('data: ') && l != 'data: [DONE]')
          .map((l) => l.substring(6))
          .listen(
            (chunk) => text.value += chunk,
            onDone: () => isDone.value = true,
            onError: (Object e) {
              if (_token.isCancelled) return; // we asked for this
              isDone.value = true;
            },
          );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return; // user left, nothing to show
      rethrow;
    }
  }

  void cancel([String reason = 'cancelled']) {
    _sub?.cancel();
    _sub = null;
    if (!_token.isCancelled) _token.cancel(reason);
    if (!isDone.value) isDone.value = true; // keep the partial answer
  }

  void dispose() {
    cancel('screen closed');
    text.dispose();
    isDone.dispose();
  }
}
