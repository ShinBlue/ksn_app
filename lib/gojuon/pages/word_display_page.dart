import 'dart:math';

import 'package:flutter/material.dart';
import '../excluded_sounds.dart';
import '../models/display_item.dart';
import '../models/word_data.dart';
import '../utils/kana_highlight.dart';
import '../utils/word_printer.dart';

/// 表示指定のラベルから番号上限を返す。指定なしは null。
int? maxNumberForDisplaySpec(String displaySpec) {
  switch (displaySpec) {
    case '1〜5':
      return 5;
    case '1〜10':
      return 10;
    default:
      return null;
  }
}

// 単語表示ページ
class WordDisplayPage extends StatefulWidget {
  final List<WordData> wordDataList;
  final List<String> selectedKanas;
  final List<String> selectedLevels;
  final bool includeShortText;
  final String displayFormat;
  final String displaySpec;
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
    this.displaySpec = '指定なし',
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
  List<DisplayItem> displayItems = [];
  final Set<int> _framed = {};
  final Set<int> _circled = {};

  static const _sideTapWidth = 56.0;
  static const _listFontSize = 32.0;

  @override
  void initState() {
    super.initState();
    _filterAndPrepareData();
  }

  void _filterAndPrepareData() {
    final List<DisplayItem> items = [];
    final maxNumber = maxNumberForDisplaySpec(widget.displaySpec);

    for (final wordData in widget.wordDataList) {
      // 選択された音を含むかチェック
      if (!widget.selectedKanas.contains(wordData.kana)) {
        continue;
      }

      // 表示指定（No.1〜N）
      if (maxNumber != null &&
          (wordData.number < 1 || wordData.number > maxNumber)) {
        continue;
      }

      // 種類が「短文」の場合：レベル1の列に含まれているデータを表示
      if (wordData.type == '短文') {
        if (widget.includeShortText) {
          // 短文の場合はレベル1の列に入っているデータを表示
          if (wordData.level1 != null && wordData.level1!.isNotEmpty) {
            _addIfAllowed(items, wordData.level1!, isShortSentence: true);
          }
        }
        continue;
      }

      // 種類が「単語」の場合：選択されたレベル（レベル1〜3）に対応する列のデータを表示
      if (wordData.type == '単語') {
        // 選択されたレベル1がある場合、レベル1列のデータを追加
        if (widget.selectedLevels.contains('レベル1')) {
          if (wordData.level1 != null && wordData.level1!.isNotEmpty) {
            _addIfAllowed(items, wordData.level1!, isShortSentence: false);
          }
        }
        // 選択されたレベル2がある場合、レベル2列のデータを追加
        if (widget.selectedLevels.contains('レベル2')) {
          if (wordData.level2 != null && wordData.level2!.isNotEmpty) {
            _addIfAllowed(items, wordData.level2!, isShortSentence: false);
          }
        }
        // 選択されたレベル3がある場合、レベル3列のデータを追加
        if (widget.selectedLevels.contains('レベル3')) {
          if (wordData.level3 != null && wordData.level3!.isNotEmpty) {
            _addIfAllowed(items, wordData.level3!, isShortSentence: false);
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
    });
  }

  void _addIfAllowed(
    List<DisplayItem> items,
    String text, {
    required bool isShortSentence,
  }) {
    if (ExcludedSounds.containsAny(text, widget.excludedSounds)) {
      return;
    }
    items.add(DisplayItem(text: text, isShortSentence: isShortSentence));
  }

  Future<void> _onPrintPressed() async {
    if (displayItems.isEmpty) return;

    try {
      await printSelectedWords(
        displayItems,
        enableKanaColor: widget.enableKanaColor,
        selectedKanas: widget.selectedKanas,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('印刷を開始できませんでした: $e')));
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar();
  }

  Widget? _buildPrintButton() {
    if (displayItems.isEmpty) return null;
    return FloatingActionButton(
      key: const Key('print-words-button'),
      tooltip: '印刷',
      backgroundColor: const Color(0xFF1E88E5),
      foregroundColor: Colors.white,
      elevation: 4,
      onPressed: _onPrintPressed,
      child: const Icon(Icons.print, size: 28),
    );
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
        appBar: _buildAppBar(),
        body: const Center(child: Text('表示するデータがありません')),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: _buildPrintButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: widget.displayFormat == 'リスト'
          ? _buildListView()
          : _buildSingleView(),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: displayItems.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildMarkedItem(
                index: index,
                text: displayItems[index].text,
                fontSize: _listFontSize,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSingleView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMarkedItem(
            index: currentIndex,
            text: displayItems[currentIndex].text,
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

    final spans = [
      for (final segment in splitHighlightedSegments(
        text,
        widget.selectedKanas,
      ))
        TextSpan(
          text: segment.text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: segment.highlighted ? Colors.red : Colors.black,
          ),
        ),
    ];

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
