/// 選択音ハイライト用の共通処理（画面表示・印刷PDFで共有）。
String toHiragana(String text) {
  return String.fromCharCodes(
    text.runes.map((code) {
      // カタカナ（ァ〜ヶ）→ ひらがな（ぁ〜ゖ）
      if (code >= 0x30A1 && code <= 0x30F6) {
        return code - 0x60;
      }
      return code;
    }),
  );
}

/// テキストを選択音／それ以外の断片に分割する。
/// 拗音など長い音を先にマッチさせる。
List<({String text, bool highlighted})> splitHighlightedSegments(
  String text,
  List<String> selectedKanas,
) {
  if (selectedKanas.isEmpty || text.isEmpty) {
    return [(text: text, highlighted: false)];
  }

  final selectedNormalized = selectedKanas.map(toHiragana).toList()
    ..sort((a, b) => b.length.compareTo(a.length));

  final segments = <({String text, bool highlighted})>[];
  final runes = text.runes.toList();
  var i = 0;

  while (i < runes.length) {
    var matchLength = 0;

    for (final kana in selectedNormalized) {
      final kanaRunes = kana.runes.toList();
      if (i + kanaRunes.length > runes.length) continue;

      final slice = String.fromCharCodes(
        runes.sublist(i, i + kanaRunes.length),
      );
      if (toHiragana(slice) == kana) {
        matchLength = kanaRunes.length;
        break;
      }
    }

    if (matchLength > 0) {
      segments.add((
        text: String.fromCharCodes(runes.sublist(i, i + matchLength)),
        highlighted: true,
      ));
      i += matchLength;
    } else {
      segments.add((text: String.fromCharCode(runes[i]), highlighted: false));
      i++;
    }
  }

  return segments;
}
