/// 選択した単語・短文から、入っていたら困る音を除く。
abstract final class ExcludedSounds {
  static const singleKana = {
    'あ',
    'い',
    'う',
    'え',
    'お',
    'か',
    'き',
    'く',
    'け',
    'こ',
    'が',
    'ぎ',
    'ぐ',
    'げ',
    'ご',
    'さ',
    'し',
    'す',
    'せ',
    'そ',
    'ざ',
    'じ',
    'ず',
    'ぜ',
    'ぞ',
    'た',
    'ち',
    'つ',
    'て',
    'と',
    'だ',
    'で',
    'ど',
    'な',
    'に',
    'ぬ',
    'ね',
    'の',
    'は',
    'ひ',
    'ふ',
    'へ',
    'ほ',
    'ば',
    'び',
    'ぶ',
    'べ',
    'ぼ',
    'ぱ',
    'ぴ',
    'ぷ',
    'ぺ',
    'ぽ',
    'ま',
    'み',
    'む',
    'め',
    'も',
    'や',
    'ゆ',
    'よ',
    'ら',
    'り',
    'る',
    'れ',
    'ろ',
    'わ',
    'ん',
    'っ',
  };

  static const youon = {
    'きゃ',
    'きゅ',
    'きょ',
    'しゃ',
    'しゅ',
    'しょ',
    'ちゃ',
    'ちゅ',
    'ちょ',
    'にゃ',
    'にゅ',
    'にょ',
    'ひゃ',
    'ひゅ',
    'ひょ',
    'みゃ',
    'みゅ',
    'みょ',
    'りゃ',
    'りゅ',
    'りょ',
    'ぎゃ',
    'ぎゅ',
    'ぎょ',
    'じゃ',
    'じゅ',
    'じょ',
    'びゃ',
    'びゅ',
    'びょ',
    'ぴゃ',
    'ぴゅ',
    'ぴょ',
  };

  static String toHiragana(String text) {
    return String.fromCharCodes(
      text.runes.map((code) {
        if (code >= 0x30A1 && code <= 0x30F6) {
          return code - 0x60;
        }
        return code;
      }),
    );
  }

  /// 「きくけ」「き く け」「きゃ、しゅ」のように書いた文字列を音に分ける。
  static List<String> parse(String input) {
    final normalized = toHiragana(input);
    final parts = normalized.split(RegExp(r'[\s,、，/／]+'));
    final sounds = <String>{};

    for (final part in parts) {
      if (part.isEmpty) continue;
      final runes = part.runes.toList();
      var i = 0;
      while (i < runes.length) {
        if (i + 1 < runes.length) {
          final two = String.fromCharCodes(runes.sublist(i, i + 2));
          if (youon.contains(two)) {
            sounds.add(two);
            i += 2;
            continue;
          }
        }
        final one = String.fromCharCode(runes[i]);
        if (singleKana.contains(one)) {
          sounds.add(one);
        }
        i++;
      }
    }
    return sounds.toList();
  }

  /// 決定後に枠へ残す表示。五十音表にある音だけを空白区切りで出す。
  static String displayText(String input) => parse(input).join(' ');

  static bool containsAny(String text, Iterable<String> sounds) {
    if (sounds.isEmpty) return false;
    final normalized = toHiragana(text).replaceAll(RegExp(r'\s+'), '');
    return sounds.any(
      (sound) => sound.isNotEmpty && normalized.contains(sound),
    );
  }
}
