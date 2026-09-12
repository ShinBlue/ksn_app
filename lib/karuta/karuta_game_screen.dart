import 'dart:math';

import 'package:flutter/material.dart';

import '../analytics_service.dart';
import 'karuta_grid_layout.dart';
import 'karuta_models.dart';
import 'karuta_repository.dart';
import 'karuta_scatter_layout.dart';

class KarutaGameScreen extends StatefulWidget {
  final List<String> selectedCharacters;
  final KarutaLayoutMode layoutMode;
  final VoidCallback? onBack;

  const KarutaGameScreen({
    super.key,
    required this.selectedCharacters,
    this.layoutMode = KarutaLayoutMode.scatter,
    this.onBack,
  });

  @override
  State<KarutaGameScreen> createState() => _KarutaGameScreenState();
}

class _KarutaGameScreenState extends State<KarutaGameScreen> {
  late final List<KarutaCard> _cards;
  final _shuffleRandom = Random();
  String? _readingText;

  List<KarutaCard> get _cardsWithReading => _cards
      .where(
        (card) => card.sentence != null && card.sentence!.trim().isNotEmpty,
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _cards = List<KarutaCard>.from(
      KarutaRepository.instance.cardsFor(widget.selectedCharacters),
    )..shuffle(_shuffleRandom);
    AnalyticsService.instance.logScreen('/karuta/game');
    AnalyticsService.instance.logEvent(
      'karuta_game_view',
      params: {
        'card_count': '${_cards.length}',
        'layout_mode': widget.layoutMode.name,
      },
    );
  }

  void _drawYomifuda() {
    final candidates = _cardsWithReading;
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('読み札がありません')));
      return;
    }
    final picked = candidates[_shuffleRandom.nextInt(candidates.length)];
    setState(() {
      _readingText = picked.sentence!.trim();
    });
    AnalyticsService.instance.logEvent(
      'karuta_yomifuda_draw',
      params: {'character': picked.character},
    );
  }

  void _showCardDetail(KarutaCard card) {
    final phrases = (card.sentence ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Material(
                color: Colors.white,
                elevation: 8,
                shadowColor: Colors.black38,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        card.character,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          card.imagePath,
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (phrases.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        // 1行に収まる文節はそのまま並べ、はみ出すときだけ文節単位で改行
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            for (final phrase in phrases)
                              Text(
                                phrase,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        Text(
                          'よみふだはまだありません',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          (widget.onBack ?? () => Navigator.of(context).maybePop()).call();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFBFE),
        appBar: AppBar(
          leading: IconButton(
            key: const Key('karuta-game-back'),
            icon: const BackButtonIcon(),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
          ),
          title: Text('カルタ（${_cards.length}まい）'),
          backgroundColor: const Color(0xFFFFF3E0),
        ),
        body: _cards.isEmpty
            ? const Center(child: Text('カルタがえらばれていません'))
            : LayoutBuilder(
                builder: (context, constraints) {
                  // 縦はそのまま、横は画面幅の90%を左寄せ（右側に空白）
                  final playWidth = constraints.maxWidth * 0.9;
                  final sideWidth = constraints.maxWidth - playWidth;
                  final area = Size(playWidth, constraints.maxHeight);
                  final placements = switch (widget.layoutMode) {
                    KarutaLayoutMode.aligned => computeKarutaGridLayout(
                      cards: _cards,
                      area: area,
                    ),
                    KarutaLayoutMode.scatter => computeKarutaScatterLayout(
                      cards: _cards,
                      area: area,
                      random: Random(
                        _cards.length * 1000 +
                            playWidth.floor() * 17 +
                            constraints.maxHeight.floor(),
                      ),
                    ),
                  };

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: playWidth,
                        height: constraints.maxHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            for (var i = 0; i < placements.length; i++)
                              Positioned(
                                left: placements[i].x,
                                top: placements[i].y,
                                width: placements[i].width,
                                height: placements[i].height,
                                child: _KarutaCardTile(
                                  card: placements[i].card,
                                  number: i + 1,
                                  onTap: () =>
                                      _showCardDetail(placements[i].card),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: sideWidth,
                        child: _YomifudaSidePanel(
                          panelWidth: sideWidth,
                          readingText: _readingText,
                          onDraw: _drawYomifuda,
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _YomifudaSidePanel extends StatelessWidget {
  final double panelWidth;
  final String? readingText;
  final VoidCallback onDraw;

  const _YomifudaSidePanel({
    required this.panelWidth,
    required this.readingText,
    required this.onDraw,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSide = ((panelWidth - 8).clamp(36.0, 120.0)) * 0.8;
    // 2列縦書き用に、パネル幅に対してやや小さめの文字サイズ
    final readingFontSize = (panelWidth * 0.38).clamp(12.0, 24.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: buttonSide,
            height: buttonSide,
            child: FilledButton(
              key: const Key('karuta-yomifuda-button'),
              onPressed: onDraw,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFB74D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '読み札',
                  style: TextStyle(fontWeight: FontWeight.bold, height: 1.1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: readingText == null
                ? const SizedBox.shrink()
                : Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      child: _VerticalReadingText(
                        text: readingText!,
                        fontSize: readingFontSize,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// 空白以外の文字リストを返す（半角長音は全角ーに揃える）。
List<String> verticalYomifudaChars(String phrase) {
  return phrase.characters
      .map((c) => (c == 'ｰ') ? 'ー' : c)
      .where((c) => c.trim().isNotEmpty)
      .toList();
}

/// 文節の間に空文字（縦書きのスペース）を入れながら列の文字列を作る。
List<String> columnCharsFromPhrases(List<String> phrases) {
  final result = <String>[];
  for (var i = 0; i < phrases.length; i++) {
    if (i > 0) {
      result.add(''); // 文節間スペース
    }
    result.addAll(verticalYomifudaChars(phrases[i]));
  }
  return result;
}

/// 文節（空白区切り）のまとまりを保ったまま、文字数バランスで2列に分ける。
/// 返り値は `[左列, 右列]`。右列が読みの前半（先に読む側）。
List<List<String>> splitYomifudaIntoTwoColumns(String text) {
  final phrases = text
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (phrases.isEmpty) return const [[], []];

  if (phrases.length == 1) {
    return [[], columnCharsFromPhrases(phrases)];
  }

  final lengths = phrases.map((p) => p.characters.length).toList();
  final total = lengths.fold<int>(0, (a, b) => a + b);
  final target = total / 2;

  var bestSplit = 1;
  var bestDiff = double.infinity;
  for (var i = 1; i < phrases.length; i++) {
    final headCount = lengths.take(i).fold<int>(0, (a, b) => a + b);
    final diff = (headCount - target).abs();
    if (diff < bestDiff) {
      bestDiff = diff;
      bestSplit = i;
    }
  }

  final firstHalf = phrases.sublist(0, bestSplit);
  final secondHalf = phrases.sublist(bestSplit);
  final rightColumn = columnCharsFromPhrases(firstHalf);
  final leftColumn = columnCharsFromPhrases(secondHalf);
  return [leftColumn, rightColumn];
}

class _VerticalReadingText extends StatelessWidget {
  final String text;
  final double fontSize;

  const _VerticalReadingText({required this.text, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final columns = splitYomifudaIntoTwoColumns(text);
    final leftColumn = columns[0];
    final rightColumn = columns[1];
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      height: 1.15,
      color: const Color(0xFF5D4037),
    );
    final lineHeight = fontSize * 1.15;

    Widget buildChar(String char) {
      // 文節間スペース
      if (char.isEmpty) {
        return SizedBox(width: fontSize, height: lineHeight * 0.65);
      }
      final glyph = Text(char, textAlign: TextAlign.center, style: style);
      // 長音「ー」はフォントの字形を90度回転して縦棒にする
      if (char == 'ー') {
        return SizedBox(
          width: fontSize,
          height: lineHeight,
          child: Center(
            child: Transform.rotate(angle: pi / 2, child: glyph),
          ),
        );
      }
      return SizedBox(
        width: fontSize,
        height: lineHeight,
        child: Center(child: glyph),
      );
    }

    Widget buildColumn(List<String> chars) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [for (final char in chars) buildChar(char)],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leftColumn.isNotEmpty) buildColumn(leftColumn),
        if (leftColumn.isNotEmpty && rightColumn.isNotEmpty)
          SizedBox(width: (fontSize * 0.35).clamp(4.0, 10.0)),
        if (rightColumn.isNotEmpty) buildColumn(rightColumn),
      ],
    );
  }
}

class _KarutaCardTile extends StatelessWidget {
  final KarutaCard card;
  final int number;
  final VoidCallback onTap;

  const _KarutaCardTile({
    required this.card,
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      shadowColor: Colors.black26,
      clipBehavior: Clip.none,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ColoredBox(
                color: Colors.white,
                child: Image.asset(
                  card.imagePath,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  errorBuilder: (_, _, _) => Center(
                    child: Text(
                      card.character,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 2,
            top: 2,
            child: IgnorePointer(child: _CardNumberBadge(number: number)),
          ),
        ],
      ),
    );
  }
}

class _CardNumberBadge extends StatelessWidget {
  final int number;

  const _CardNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}
