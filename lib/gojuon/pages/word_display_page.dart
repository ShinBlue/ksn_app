import 'dart:math';

import 'package:flutter/material.dart';
import '../excluded_sounds.dart';
import '../models/word_data.dart';

// 単語表示ページ
class WordDisplayPage extends StatefulWidget {
  final List<WordData> wordDataList;
  final List<String> selectedKanas;
  final List<String> selectedLevels;
  final bool includeShortText;
  final String displayFormat;
  final int pageSize;
  final bool enableKanaColor;
  final bool enableBlueFrame;
  final bool enableRedDoubleCircle;
  final bool enableRandomOrder;
  final List<String> excludedSounds;
  final Random? random;

  const WordDisplayPage({
    super.key,
    required this.wordDataList,
    required this.selectedKanas,
    required this.selectedLevels,
    required this.includeShortText,
    required this.displayFormat,
    required this.enableKanaColor,
    this.pageSize = 5,
    this.enableBlueFrame = true,
    this.enableRedDoubleCircle = true,
    this.enableRandomOrder = false,
    this.excludedSounds = const [],
    this.random,
  });

  @override
  State<WordDisplayPage> createState() => _WordDisplayPageState();
}

class _WordDisplayPageState extends State<WordDisplayPage> {
  int currentIndex = 0;
  int currentPage = 0;
  List<String> displayItems = [];
  final Set<int> _framed = {};
  final Set<int> _circled = {};

  static const _sideTapWidth = 56.0;

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
            _addIfAllowed(items, wordData.level1!);
          }
        }
        continue;
      }

      // 種類が「単語」の場合：選択されたレベル（レベル1〜3）に対応する列のデータを表示
      if (wordData.type == '単語') {
        // 選択されたレベル1がある場合、レベル1列のデータを追加
        if (widget.selectedLevels.contains('レベル1')) {
          if (wordData.level1 != null && wordData.level1!.isNotEmpty) {
            _addIfAllowed(items, wordData.level1!);
          }
        }
        // 選択されたレベル2がある場合、レベル2列のデータを追加
        if (widget.selectedLevels.contains('レベル2')) {
          if (wordData.level2 != null && wordData.level2!.isNotEmpty) {
            _addIfAllowed(items, wordData.level2!);
          }
        }
        // 選択されたレベル3がある場合、レベル3列のデータを追加
        if (widget.selectedLevels.contains('レベル3')) {
          if (wordData.level3 != null && wordData.level3!.isNotEmpty) {
            _addIfAllowed(items, wordData.level3!);
          }
        }
      }
    }

    if (widget.enableRandomOrder && items.length > 1) {
      items.shuffle(widget.random);
    }

    setState(() {
      displayItems = items;
      currentIndex = 0;
      currentPage = 0;
    });
  }

  void _addIfAllowed(List<String> items, String text) {
    if (ExcludedSounds.containsAny(text, widget.excludedSounds)) {
      return;
    }
    items.add(text);
  }

  int get _pageCount {
    if (displayItems.isEmpty) return 1;
    return ((displayItems.length - 1) ~/ widget.pageSize) + 1;
  }

  List<(int, String)> get _currentPageItems {
    final start = currentPage * widget.pageSize;
    final end = (start + widget.pageSize).clamp(0, displayItems.length);
    return [for (var i = start; i < end; i++) (i, displayItems[i])];
  }

  void _toggleFrame(int index) {
    setState(() {
      if (_framed.contains(index)) {
        _framed.remove(index);
      } else {
        _framed.add(index);
      }
    });
  }

  void _toggleCircle(int index) {
    setState(() {
      if (_circled.contains(index)) {
        _circled.remove(index);
      } else {
        _circled.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (displayItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('表示するデータがありません')),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: widget.displayFormat == 'リスト'
          ? _buildListView()
          : _buildSingleView(),
    );
  }

  double get _listFontSize => widget.pageSize == 5 ? 48 : 24;

  Widget _buildListView() {
    final pageItems = _currentPageItems;
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (pageItems.isEmpty) {
                return const SizedBox.shrink();
              }
              final rowHeight = constraints.maxHeight / pageItems.length;
              return Column(
                children: [
                  for (final (index, text) in pageItems)
                    SizedBox(
                      height: rowHeight,
                      width: constraints.maxWidth,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildMarkedItem(
                              index: index,
                              text: text,
                              fontSize: _listFontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        _buildPageControls(
          label: '${currentPage + 1} / $_pageCount',
          canGoBack: currentPage > 0,
          canGoForward: currentPage < _pageCount - 1,
          onBack: () {
            setState(() {
              currentPage--;
            });
          },
          onForward: () {
            setState(() {
              currentPage++;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSingleView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMarkedItem(
            index: currentIndex,
            text: displayItems[currentIndex],
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 32),
          _buildPageControls(
            label: '${currentIndex + 1} / ${displayItems.length}',
            canGoBack: currentIndex > 0,
            canGoForward: currentIndex < displayItems.length - 1,
            onBack: () {
              setState(() {
                currentIndex--;
              });
            },
            onForward: () {
              setState(() {
                currentIndex++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageControls({
    required String label,
    required bool canGoBack,
    required bool canGoForward,
    required VoidCallback onBack,
    required VoidCallback onForward,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            key: const Key('display-page-back'),
            icon: const Icon(Icons.arrow_back),
            onPressed: canGoBack ? onBack : null,
          ),
          Text(label, style: const TextStyle(fontSize: 18)),
          IconButton(
            key: const Key('display-page-forward'),
            icon: const Icon(Icons.arrow_forward),
            onPressed: canGoForward ? onForward : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMarkedItem({
    required int index,
    required String text,
    required double fontSize,
    FontWeight? fontWeight,
  }) {
    final framed = widget.enableBlueFrame && _framed.contains(index);
    final circled = widget.enableRedDoubleCircle && _circled.contains(index);

    // 左側の青枠タップ領域と同じ幅を右にも置き、下の操作ボタンと中央を揃える。
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          key: Key('word-left-$index'),
          behavior: HitTestBehavior.opaque,
          onTap: widget.enableBlueFrame ? () => _toggleFrame(index) : null,
          child: SizedBox(width: _sideTapWidth, height: fontSize * 1.8),
        ),
        GestureDetector(
          key: Key('word-text-$index'),
          onTap: widget.enableRedDoubleCircle
              ? () => _toggleCircle(index)
              : null,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                key: framed ? Key('word-blue-frame-$index') : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: framed ? Colors.blue : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: _buildHighlightedText(
                  text,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
              ),
              if (circled)
                IgnorePointer(
                  child: CustomPaint(
                    key: Key('word-double-circle-$index'),
                    size: Size.square(fontSize * 1.55),
                    painter: _RedDoubleCirclePainter(),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: _sideTapWidth, height: fontSize * 1.8),
      ],
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
    final selectedNormalized = widget.selectedKanas.map(_toHiragana).toList()
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

class _RedDoubleCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.shortestSide * 0.08).clamp(2.5, 5.0)
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.shortestSide * 0.46, paint);
    canvas.drawCircle(center, size.shortestSide * 0.30, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
