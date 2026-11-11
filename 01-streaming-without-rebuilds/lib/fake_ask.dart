Stream<String> fakeAsk(String prompt) async* {
  const reply = 'Flutter renders at 60 frames a second, so anything that '
      'rebuilds more often than that is wasted work. ';
  for (final word in reply.split(' ')) {
    await Future<void>.delayed(const Duration(milliseconds: 12));
    yield '$word ';
  }
}
