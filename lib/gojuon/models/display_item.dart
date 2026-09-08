/// 画面表示・印刷用の1件。単語と短文を区別する。
class DisplayItem {
  final String text;
  final bool isShortSentence;

  const DisplayItem({required this.text, required this.isShortSentence});

  @override
  bool operator ==(Object other) {
    return other is DisplayItem &&
        other.text == text &&
        other.isShortSentence == isShortSentence;
  }

  @override
  int get hashCode => Object.hash(text, isShortSentence);
}
