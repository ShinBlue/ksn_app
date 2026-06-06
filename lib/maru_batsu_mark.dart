import 'package:flutter/material.dart';

/// まる（○）を描画するマーク
class MaruMark extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const MaruMark({
    super.key,
    required this.size,
    this.color = Colors.red,
    this.strokeWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MaruPainter(color: color, strokeWidth: strokeWidth),
    );
  }
}

class _MaruPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _MaruPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final outlineWidth = (strokeWidth * 0.65).clamp(2.0, 5.0);
    final inset = strokeWidth / 2 + outlineWidth + 2;
    final rect = Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2);

    canvas.drawOval(
      rect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + outlineWidth * 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MaruPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// ばつ（×）を描画するマーク
class BatsuMark extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const BatsuMark({
    super.key,
    required this.size,
    this.color = Colors.blue,
    this.strokeWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BatsuPainter(color: color, strokeWidth: strokeWidth),
    );
  }
}

class _BatsuPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _BatsuPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final outlineWidth = (strokeWidth * 0.65).clamp(2.0, 5.0);
    final inset = strokeWidth / 2 + outlineWidth + 4;
    final start1 = Offset(inset, inset);
    final end1 = Offset(size.width - inset, size.height - inset);
    final start2 = Offset(size.width - inset, inset);
    final end2 = Offset(inset, size.height - inset);

    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + outlineWidth * 2
      ..strokeCap = StrokeCap.round;

    final mainPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start1, end1, outlinePaint);
    canvas.drawLine(start2, end2, outlinePaint);
    canvas.drawLine(start1, end1, mainPaint);
    canvas.drawLine(start2, end2, mainPaint);
  }

  @override
  bool shouldRepaint(covariant _BatsuPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// まる（1）かばつ（2）かを表示
class MaruBatsuMark extends StatelessWidget {
  final int player;
  final double size;

  const MaruBatsuMark({
    super.key,
    required this.player,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (player == 1) {
      return MaruMark(size: size);
    }
    return BatsuMark(size: size);
  }
}
