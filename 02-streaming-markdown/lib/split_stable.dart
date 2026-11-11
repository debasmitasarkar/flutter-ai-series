({String done, String live}) splitStable(String src) {
  var inFence = false;
  var cut = -1;
  var offset = 0;
  for (final line in src.split('\n')) {
    if (line.trimLeft().startsWith('```')) inFence = !inFence;
    if (!inFence && line.trim().isEmpty) cut = offset;
    offset += line.length + 1;
  }
  if (cut <= 0) return (done: '', live: src);
  return (done: src.substring(0, cut), live: src.substring(cut));
}
