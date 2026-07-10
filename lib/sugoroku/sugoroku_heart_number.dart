import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'sugoroku_models.dart';

/// カラフルなハートの土台 + 白数字。
abstract final class SugorokuHeartNumbers {
  static const heartPalette = [
    Color(0xFFFF8A80),
    Color(0xFFFFB74D),
    Color(0xFFFFF176),
    Color(0xFFA5D6A7),
    Color(0xFF81D4FA),
    Color(0xFFCE93D8),
    Color(0xFFF48FB1),
    Color(0xFF80CBC4),
    Color(0xFFFFCC80),
    Color(0xFFB39DDB),
    Color(0xFF90CAF9),
    Color(0xFFAED581),
    Color(0xFFFFAB91),
    Color(0xFF80DEEA),
    Color(0xFFE6EE9C),
    Color(0xFFBCAAA4),
    Color(0xFF9FA8DA),
    Color(0xFFF06292),
    Color(0xFF4DD0E1),
    Color(0xFFDCE775),
  ];

  static HiddenNumberBoardState create(int count, math.Random random) {
    final numbers = List.generate(count, (i) => i + 1)..shuffle(random);
    final colors = List<Color>.from(heartPalette)..shuffle(random);
    return HiddenNumberBoardState(
      shuffledNumbers: numbers,
      revealedIndices: const {},
      heartColors: List.generate(
        count,
        (i) => colors[i % colors.length],
      ),
    );
  }
}

class HeartNumberBadge extends StatelessWidget {
  final int number;
  final Color color;
  final double size;

  const HeartNumberBadge({
    super.key,
    required this.number,
    required this.color,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HeartPainter(color: color),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              color: const Color(0xFF263238),
              fontSize: size * 0.38,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(
                  color: Color(0x66FFFFFF),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeartPainter extends CustomPainter {
  final Color color;

  _HeartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = _heartPath(
      Offset(size.width / 2, size.height * 0.52),
      size.shortestSide * 0.92,
    );
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF455A64)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  Path _heartPath(Offset center, double size) {
    final w = size;
    final h = size;
    final x = center.dx;
    final y = center.dy;
    return Path()
      ..moveTo(x, y + h * 0.28)
      ..cubicTo(x - w * 0.5, y - h * 0.12, x - w * 0.5, y + h * 0.22, x, y + h * 0.48)
      ..cubicTo(x + w * 0.5, y + h * 0.22, x + w * 0.5, y - h * 0.12, x, y + h * 0.28)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _HeartPainter oldDelegate) =>
      oldDelegate.color != color;
}
