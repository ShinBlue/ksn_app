import 'dart:math';
import 'dart:ui';

import 'karuta_models.dart';

class PlacedKarutaCard {
  final KarutaCard card;
  final double x;
  final double y;
  final double width;
  final double height;

  const PlacedKarutaCard({
    required this.card,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

/// 画面内に全カードが収まるようサイズを調整し、ランダムに配置する。
List<PlacedKarutaCard> computeKarutaScatterLayout({
  required List<KarutaCard> cards,
  required Size area,
  required Random random,
}) {
  if (cards.isEmpty || area.width <= 0 || area.height <= 0) {
    return const [];
  }

  const horizontalPadding = 12.0;
  const topPadding = 20.0;
  const bottomPadding = 12.0;
  const minGap = 5.0;
  const aspect = 1024 / 1506;
  const minCardHeight = 48.0;

  final usableWidth = area.width - horizontalPadding * 2;
  final usableHeight = area.height - topPadding - bottomPadding;
  final count = cards.length;

  final areaPerCard = usableWidth * usableHeight / count * 0.52;
  var cardHeight =
      sqrt(areaPerCard / aspect).clamp(minCardHeight, usableHeight);
  var cardWidth = cardHeight * aspect;

  while (cardHeight >= minCardHeight) {
    final placedRects = <Rect>[];
    final result = <PlacedKarutaCard>[];

    for (final card in cards) {
      var found = false;
      for (var attempt = 0; attempt < 120; attempt++) {
        final maxX = usableWidth - cardWidth;
        final maxY = usableHeight - cardHeight;
        if (maxX < 0 || maxY < 0) break;

        final x = horizontalPadding + random.nextDouble() * maxX;
        final y = topPadding + random.nextDouble() * maxY;
        final rect = Rect.fromLTWH(x, y, cardWidth, cardHeight);

        if (!_overlaps(rect, placedRects, minGap)) {
          placedRects.add(rect);
          result.add(
            PlacedKarutaCard(
              card: card,
              x: x,
              y: y,
              width: cardWidth,
              height: cardHeight,
            ),
          );
          found = true;
          break;
        }
      }
      if (!found) break;
    }

    if (result.length == count) return result;

    cardHeight *= 0.9;
    cardWidth = cardHeight * aspect;
  }

  return _fallbackLayout(
    cards: cards,
    area: area,
    cardWidth: cardWidth.clamp(40.0, usableWidth),
    cardHeight: cardHeight,
    horizontalPadding: horizontalPadding,
    topPadding: topPadding,
    bottomPadding: bottomPadding,
    minGap: minGap,
    random: random,
  );
}

bool _overlaps(Rect candidate, List<Rect> placed, double gap) {
  final expanded = candidate.inflate(gap);
  for (final rect in placed) {
    if (expanded.overlaps(rect)) return true;
  }
  return false;
}

List<PlacedKarutaCard> _fallbackLayout({
  required List<KarutaCard> cards,
  required Size area,
  required double cardWidth,
  required double cardHeight,
  required double horizontalPadding,
  required double topPadding,
  required double bottomPadding,
  required double minGap,
  required Random random,
}) {
  final usableWidth = area.width - horizontalPadding * 2;
  final usableHeight = area.height - topPadding - bottomPadding;
  final placedRects = <Rect>[];
  final result = <PlacedKarutaCard>[];

  for (final card in cards) {
    for (var attempt = 0; attempt < 200; attempt++) {
      final w = cardWidth.clamp(40.0, usableWidth);
      final h = cardHeight;
      final maxX = usableWidth - w;
      final maxY = usableHeight - h;
      if (maxX < 0 || maxY < 0) continue;

      final x = horizontalPadding + random.nextDouble() * maxX;
      final y = topPadding + random.nextDouble() * maxY;
      final rect = Rect.fromLTWH(x, y, w, h);

      if (!_overlaps(rect, placedRects, minGap * 0.5)) {
        placedRects.add(rect);
        result.add(
          PlacedKarutaCard(
            card: card,
            x: x,
            y: y,
            width: w,
            height: h,
          ),
        );
        break;
      }
    }
  }

  return result;
}
