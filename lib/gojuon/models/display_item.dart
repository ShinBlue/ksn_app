import '../utils/mora_count.dart';

/// 画面表示・印刷用の1件。単語と短文を区別する。
class DisplayItem {
  final String text;
  final bool isShortSentence;

  /// 単語のレベル（1〜3）。短文は null。
  final int? level;

  const DisplayItem({
    required this.text,
    required this.isShortSentence,
    this.level,
  });

  int get moraCount => countMoras(text);

  @override
  bool operator ==(Object other) {
    return other is DisplayItem &&
        other.text == text &&
        other.isShortSentence == isShortSentence &&
        other.level == level;
  }

  @override
  int get hashCode => Object.hash(text, isShortSentence, level);
}
