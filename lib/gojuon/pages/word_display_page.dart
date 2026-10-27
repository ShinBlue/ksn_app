import 'package:flutter/material.dart';
import '../../app_layout.dart';
import '../models/display_item.dart';
import '../utils/kana_highlight.dart';
import '../utils/word_printer.dart';

// 単語表示ページ（確定済みの候補を表示する）
class WordDisplayPage extends StatefulWidget {
  final List<DisplayItem> displayItems;
  final List<String> selectedKanas;
  final String displayFormat;
  final bool enableKanaColor;
  final bool enableBlueFrame;
  final bool enableRedDoubleCircle;

  const WordDisplayPage({
    super.key,
    required this.displayItems,
    required this.selectedKanas,
    required this.displayFormat,
    required this.enableKanaColor,
    this.enableBlueFrame = true,
    this.enableRedDoubleCircle = true,
  });

  @override
  State<WordDisplayPage> createState() => _WordDisplayPageState();
}

class _WordDisplayPageState extends State<WordDisplayPage> {
  int currentIndex = 0;
  final Set<int> _framed = {};
  final Set<int> _circled = {};

  static const _sideTapWidth = 56.0;
  static const _sideTapWidthCompact = 28.0;
  static const _listFontSize = 32.0;
  static const _listFontSizeCompact = 26.0;
  static const _singleFontSize = 48.0;
  static const _singleFontSizeCompact = 36.0;
  static const _frameToggleSize = 28.0;

  List<DisplayItem> get displayItems => widget.displayItems;

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
    // 選択画面へ戻す。離脱防止は親の五十音設定側で行う。
    return AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        key: const Key('word-display-back'),
        icon: const BackButtonIcon(),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget? _buildPrintButton({required bool compact}) {
    if (displayItems.isEmpty) return null;
    return FloatingActionButton(
      key: const Key('print-words-button'),
      tooltip: '印刷',
      mini: compact,
      backgroundColor: const Color(0xFF1E88E5),
      foregroundColor: Colors.white,
      elevation: 4,
      onPressed: _onPrintPressed,
      child: Icon(Icons.print, size: compact ? 22 : 28),
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
    final compact = AppLayout.isCompact(context);
    if (displayItems.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: Text('表示するデータがありません')),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: _buildPrintButton(compact: compact),
      floatingActionButtonLocation: compact
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.endTop,
      body: widget.displayFormat == 'リスト'
          ? _buildListView(compact: compact)
          : _buildSingleView(compact: compact),
    );
  }

  Widget _buildListView({required bool compact}) {
    final fontSize = compact ? _listFontSizeCompact : _listFontSize;
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: compact ? 8 : 16),
      itemCount: displayItems.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildMarkedItem(
            index: index,
            text: displayItems[index].text,
            fontSize: fontSize,
            expandToRow: true,
            compact: compact,
          ),
        );
      },
    );
  }

  Widget _buildSingleView({required bool compact}) {
    final fontSize = compact ? _singleFontSizeCompact : _singleFontSize;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _buildMarkedItem(
                    index: currentIndex,
                    text: displayItems[currentIndex].text,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    compact: compact,
                  ),
                ),
              ),
            ),
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
            SizedBox(height: compact ? 8 : 16),
          ],
        ),
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
    bool expandToRow = false,
    bool compact = false,
  }) {
    final framed = widget.enableBlueFrame && _framed.contains(index);
    final circled = widget.enableRedDoubleCircle && _circled.contains(index);
    final sideTapWidth = compact ? _sideTapWidthCompact : _sideTapWidth;

    final textWidget = GestureDetector(
      key: Key('word-text-$index'),
      onTap: widget.enableRedDoubleCircle ? () => _toggleCircle(index) : null,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            key: framed ? Key('word-blue-frame-$index') : null,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );

    final frameToggle = widget.enableBlueFrame
        ? GestureDetector(
            key: Key('word-frame-toggle-$index'),
            behavior: HitTestBehavior.opaque,
            onTap: () => _toggleFrame(index),
            child: Container(
              width: _frameToggleSize,
              height: _frameToggleSize,
              decoration: BoxDecoration(
                color: framed
                    ? const Color(0xFF81D4FA)
                    : const Color(0xFFB3E5FC),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          )
        : SizedBox(width: _frameToggleSize, height: _frameToggleSize);

    if (expandToRow) {
      return Row(
        children: [
          const SizedBox(width: _frameToggleSize),
          Expanded(
            child: Center(
              child: FittedBox(fit: BoxFit.scaleDown, child: textWidget),
            ),
          ),
          frameToggle,
        ],
      );
    }

    // １つずつ表示: 左右の余白で中央揃えしつつ、右端に強調枠トグルを置く
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: sideTapWidth, height: fontSize * 1.8),
        textWidget,
        SizedBox(
          width: sideTapWidth,
          height: fontSize * 1.8,
          child: Align(alignment: Alignment.centerRight, child: frameToggle),
        ),
      ],
    );
  }

  Widget _buildHighlightedText(
    String text, {
    double fontSize = 24,
    FontWeight? fontWeight,
  }) {
    if (!widget.enableKanaColor || widget.selectedKanas.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.black,
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
