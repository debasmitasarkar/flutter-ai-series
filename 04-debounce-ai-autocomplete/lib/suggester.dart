import 'package:dio/dio.dart';

abstract interface class Suggester {
  /// Returns the text to append after [input], or null if nothing useful.
  Future<String?> complete(String input, {CancelToken? cancelToken});
}

class FakeSuggester implements Suggester {
  FakeSuggester({this.latency = const Duration(milliseconds: 900)});
  final Duration latency;

  static const _canned = {
    'how do i stream ': 'tokens in flutter without rebuilding the screen',
    'the user taps ': 'back and the request keeps running',
    'debounce ': 'is a bet about when the user has stopped typing',
  };

  @override
  Future<String?> complete(String input, {CancelToken? cancelToken}) async {
    // A cancellable delay: whichever finishes first wins.
    await Future.any([
      Future<void>.delayed(latency),
      if (cancelToken != null) cancelToken.whenCancel,
    ]);
    if (cancelToken?.isCancelled ?? false) return null;

    final key = _canned.keys
        .where((k) => input.toLowerCase().endsWith(k))
        .firstOrNull;
    return key == null ? null : _canned[key];
  }
}

class ProxySuggester implements Suggester {
  ProxySuggester(this._dio);
  final Dio _dio;

  @override
  Future<String?> complete(String input, {CancelToken? cancelToken}) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/v1/complete',
        data: {'text': input, 'max_tokens': 24},
        cancelToken: cancelToken,
      );
      return res.data?['completion'] as String?;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return null;
      rethrow;
    }
  }
}
