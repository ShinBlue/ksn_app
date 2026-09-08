import '../models/display_item.dart';

/// 印刷1行。単語行は最大 [wordColumns] セル、短文行は1セル。
class WordPrintRow {
  final List<String> cells;
  final bool isShortSentence;

  const WordPrintRow({required this.cells, required this.isShortSentence});
}

/// 単語は [wordColumns] 列、短文は1列で行を組み立てる。
/// 短文の直前に未完了の単語行があれば確定してから短文行を置く。
List<WordPrintRow> buildWordPrintRows(
  List<DisplayItem> items, {
  int wordColumns = 3,
}) {
  assert(wordColumns > 0);
  final rows = <WordPrintRow>[];
  final wordBuffer = <String>[];

  void flushWords() {
    if (wordBuffer.isEmpty) return;
    rows.add(
      WordPrintRow(
        cells: List<String>.from(wordBuffer),
        isShortSentence: false,
      ),
    );
    wordBuffer.clear();
  }

  for (final item in items) {
    if (item.isShortSentence) {
      flushWords();
      rows.add(WordPrintRow(cells: [item.text], isShortSentence: true));
      continue;
    }
    wordBuffer.add(item.text);
    if (wordBuffer.length >= wordColumns) {
      flushWords();
    }
  }
  flushWords();
  return rows;
}
