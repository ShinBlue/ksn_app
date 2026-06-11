import 'dart:ui';

import 'karuta_models.dart';
import 'karuta_scatter_layout.dart';

/// 画面内に全カードが収まるグリッド配置を計算する。
List<PlacedKarutaCard> computeKarutaGridLayout({
  required List<KarutaCard> cards,
  required Size area,
}) {
  if (cards.isEmpty || area.width <= 0 || area.height <= 0) {
    return const [];
  }

  const horizontalPadding = 12.0;
  const topPadding = 12.0;
  const bottomPadding = 12.0;
  const spacing = 8.0;
  const aspect = 1024 / 1506;

  final usableWidth = area.width - horizontalPadding * 2;
  final usableHeight = area.height - topPadding - bottomPadding;
  final count = cards.length;

  var bestCols = 1;
  var bestCardWidth = 0.0;
  var bestCardHeight = 0.0;

  for (var cols = 1; cols <= count; cols++) {
    final rows = (count / cols).ceil();
    final cellWidth = (usableWidth - spacing * (cols - 1)) / cols;
    final cellHeight = (usableHeight - spacing * (rows - 1)) / rows;
    if (cellWidth <= 0 || cellHeight <= 0) continue;

    var cardWidth = cellWidth;
    var cardHeight = cardWidth / aspect;
    if (cardHeight > cellHeight) {
      cardHeight = cellHeight;
      cardWidth = cardHeight * aspect;
    }

    final areaScore = cardWidth * cardHeight;
    final bestScore = bestCardWidth * bestCardHeight;
    if (areaScore > bestScore) {
      bestCols = cols;
      bestCardWidth = cardWidth;
      bestCardHeight = cardHeight;
    }
  }

  if (bestCardWidth <= 0 || bestCardHeight <= 0) return const [];

  final rows = (count / bestCols).ceil();
  final gridWidth = bestCols * bestCardWidth + spacing * (bestCols - 1);
  final gridHeight = rows * bestCardHeight + spacing * (rows - 1);
  final offsetX = horizontalPadding + (usableWidth - gridWidth) / 2;
  final offsetY = topPadding + (usableHeight - gridHeight) / 2;

  final result = <PlacedKarutaCard>[];
  for (var i = 0; i < count; i++) {
    final col = i % bestCols;
    final row = i ~/ bestCols;
    result.add(
      PlacedKarutaCard(
        card: cards[i],
        x: offsetX + col * (bestCardWidth + spacing),
        y: offsetY + row * (bestCardHeight + spacing),
        width: bestCardWidth,
        height: bestCardHeight,
      ),
    );
  }

  return result;
}
