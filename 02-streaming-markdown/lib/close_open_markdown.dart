String closeOpenMarkdown(String src) {
  // Inside a code fence? Just close the fence and skip inline fixes.
  final fences = RegExp(r'^\s*```', multiLine: true).allMatches(src).length;
  if (fences.isOdd) return '$src\n```';

  var s = src;

  // A link that hasn't finished: render only its text for now.
  s = s.replaceFirstMapped(
    RegExp(r'\[([^\]]*)(?:\]\([^)]*)?$'),
    (m) => m[1]!,
  );

  // Inline code.
  if ('`'.allMatches(s).length.isOdd) s = '$s`';

  // Bold first, then italic. A lone * at the start of a line is a bullet,
  // not an emphasis marker, so those are skipped.
  if ('**'.allMatches(s).length.isOdd) s = '$s**';
  final singles = RegExp(r'(?<!\*)\*(?!\*)').allMatches(s).where((m) {
    final lineStart = s.lastIndexOf('\n', m.start) + 1;
    return s.substring(lineStart, m.start).trim().isNotEmpty;
  }).length;
  if (singles.isOdd) s = '$s*';

  return s;
}
