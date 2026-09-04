import 'package:flutter/material.dart';
import '../models/word_data.dart';

// 単語表示ページ
class WordDisplayPage extends StatefulWidget {
  final List<WordData> wordDataList;
  final List<String> selectedKanas;
  final List<String> selectedLevels;
  final bool includeShortText;
  final String displayFormat;
  final bool enableKanaColor;

  const WordDisplayPage({
    super.key,
    required this.wordDataList,
    required this.selectedKanas,
    required this.selectedLevels,
    required this.includeShortText,
    required this.displayFormat,
    required this.enableKanaColor,
  });

  @override
  State<WordDisplayPage> createState() => _WordDisplayPageState();
}

class _WordDisplayPageState extends State<WordDisplayPage> {
  int currentIndex = 0;
  List<String> displayItems = [];

  @override
  void initState() {
    super.initState();
    _filterAndPrepareData();
  }

  void _filterAndPrepareData() {
    final List<String> items = [];

    for (final wordData in widget.wordDataList) {
      // 選択された音を含むかチェック
      if (!widget.selectedKanas.contains(wordData.kana)) {
        continue;
      }

      // 種類が「短文」の場合：レベル1の列に含まれているデータを表示
      if (wordData.type == '短文') {
        if (widget.includeShortText) {
          // 短文の場合はレベル1の列に入っているデータを表示
          if (wordData.level1 != null && wordData.level1!.isNotEmpty) {
            items.add(wordData.level1!);
          }
        }
        continue;
      }

      // 種類が「単語」の場合：選択されたレベル（レベル1〜3）に対応する列のデータを表示
      if (wordData.type == '単語') {
        // 選択されたレベル1がある場合、レベル1列のデータを追加
        if (widget.selectedLevels.contains('レベル1')) {
          if (wordData.level1 != null && wordData.level1!.isNotEmpty) {
            items.add(wordData.level1!);
          }
        }
        // 選択されたレベル2がある場合、レベル2列のデータを追加
        if (widget.selectedLevels.contains('レベル2')) {
          if (wordData.level2 != null && wordData.level2!.isNotEmpty) {
            items.add(wordData.level2!);
          }
        }
        // 選択されたレベル3がある場合、レベル3列のデータを追加
        if (widget.selectedLevels.contains('レベル3')) {
          if (wordData.level3 != null && wordData.level3!.isNotEmpty) {
            items.add(wordData.level3!);
          }
        }
      }
    }

    setState(() {
      displayItems = items;
      currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (displayItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('リスト表示')),
        body: const Center(child: Text('表示するデータがありません')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('リスト表示')),
      body: widget.displayFormat == 'リスト'
          ? _buildListView()
          : _buildSingleView(),
    );
  }

  Widget _buildListView() {
    return Center(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        itemCount: displayItems.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: _buildHighlightedText(displayItems[index], fontSize: 24),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSingleView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHighlightedText(
            displayItems[currentIndex],
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: currentIndex > 0
                    ? () {
                        setState(() {
                          currentIndex--;
                        });
                      }
                    : null,
              ),
              Text(
                '${currentIndex + 1} / ${displayItems.length}',
                style: const TextStyle(fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: currentIndex < displayItems.length - 1
                    ? () {
                        setState(() {
                          currentIndex++;
                        });
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // カタカナをひらがなに変換（比較用）
  String _toHiragana(String text) {
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

  // 選択された音の文字を赤く表示するヘルパーメソッド
  Widget _buildHighlightedText(
    String text, {
    double fontSize = 24,
    FontWeight? fontWeight,
  }) {
    // 選択音カラーがOFFの場合、または選択された音がない場合は通常表示
    if (!widget.enableKanaColor || widget.selectedKanas.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.black, // テキストのデフォルト色を指定（Material3対応）
        ),
        textAlign: TextAlign.center,
      );
    }

    // 選択音をひらがなに正規化（拗音など2文字を先にマッチさせるため長い順）
    final selectedNormalized = widget.selectedKanas
        .map(_toHiragana)
        .toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    final List<TextSpan> spans = [];
    final runes = text.runes.toList();
    int i = 0;

    while (i < runes.length) {
      int matchLength = 0;

      for (final kana in selectedNormalized) {
        final kanaRunes = kana.runes.toList();
        if (i + kanaRunes.length > runes.length) continue;

        final slice = String.fromCharCodes(
          runes.sublist(i, i + kanaRunes.length),
        );
        if (_toHiragana(slice) == kana) {
          matchLength = kanaRunes.length;
          break;
        }
      }

      if (matchLength > 0) {
        spans.add(
          TextSpan(
            text: String.fromCharCodes(runes.sublist(i, i + matchLength)),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: Colors.red,
            ),
          ),
        );
        i += matchLength;
      } else {
        spans.add(
          TextSpan(
            text: String.fromCharCode(runes[i]),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: Colors.black,
            ),
          ),
        );
        i++;
      }
    }

    return Text.rich(TextSpan(children: spans), textAlign: TextAlign.center);
  }
}
