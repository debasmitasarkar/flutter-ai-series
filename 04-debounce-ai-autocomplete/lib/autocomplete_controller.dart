import 'dart:async';
import 'package:dio/dio.dart'; // CancelToken: not in the article's imports
import 'package:flutter/material.dart';

import 'suggester.dart';

class AutocompleteController {
  AutocompleteController(this.text, this.suggester) {
    text.addListener(_onChanged);
  }

  final TextEditingController text;
  final Suggester suggester;

  /// The grey text we propose after the caret. Null when there is none.
  final ghost = ValueNotifier<String?>(null);

  static const _pause = Duration(milliseconds: 700);
  static const _boundary = Duration(milliseconds: 150);
  static const _minChars = 3;

  Timer? _timer;
  CancelToken? _inFlight;
  int _seq = 0;
  String _lastInput = '';
  String? _lastFull; // input + suggestion we last showed

  void _onChanged() {
    final input = text.text;
    if (input == _lastInput) return; // caret moved, text didn't
    _lastInput = input;
    _timer?.cancel();

    // Change 3: still typing what we predicted? Trim, don't fetch.
    final full = _lastFull;
    if (full != null && full.startsWith(input) && input.length < full.length) {
      ghost.value = full.substring(input.length);
      return;
    }

    // They diverged. Whatever is in flight is stale now.
    ghost.value = null;
    _inFlight?.cancel('typing'); // Change 2

    if (input.trim().length < _minChars) return;

    // Change 1: fast on a boundary, patient mid-word.
    final last = input.characters.last;
    final atBoundary = last == ' ' || '.,!?'.contains(last);
    _timer = Timer(atBoundary ? _boundary : _pause, () => _fetch(input));
  }

  Future<void> _fetch(String input) async {
    final token = CancelToken();
    _inFlight = token;
    final mySeq = ++_seq;

    final suggestion = await suggester.complete(input, cancelToken: token);

    if (mySeq != _seq) return;            // a newer request exists
    if (text.text != input) return;       // user moved on meanwhile
    if (suggestion == null || suggestion.isEmpty) return;

    _lastFull = input + suggestion;
    ghost.value = suggestion;
  }

  void accept() {
    final s = ghost.value;
    if (s == null) return;
    final next = text.text + s;
    text.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    ghost.value = null;
  }

  void dispose() {
    _timer?.cancel();
    _inFlight?.cancel('dispose');
    text.removeListener(_onChanged);
    ghost.dispose();
  }
}
