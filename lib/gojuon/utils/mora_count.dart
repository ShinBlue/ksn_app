/// 日本語のモーラ数を概算する。
///
/// 拗音の小書き（ゃゅょ など）は直前の音に含め、空白・記号は数えない。
int countMoras(String text) {
  const smallKana = {
    'ゃ',
    'ゅ',
    'ょ',
    'ぁ',
    'ぃ',
    'ぅ',
    'ぇ',
    'ぉ',
    'ャ',
    'ュ',
    'ョ',
    'ァ',
    'ィ',
    'ゥ',
    'ェ',
    'ォ',
    'ゎ',
    'ヮ',
  };
  const ignore = {
    ' ',
    '　',
    '\t',
    '\n',
    '・',
    '、',
    '。',
    '！',
    '？',
    '!',
    '?',
    '「',
    '」',
    '（',
    '）',
    '(',
    ')',
  };

  var count = 0;
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    if (ignore.contains(char)) continue;
    if (smallKana.contains(char)) continue;
    count++;
  }
  return count;
}
