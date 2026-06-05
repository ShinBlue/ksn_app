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
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final inset = strokeWidth / 2 + 2;
    final rect = Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2);
    canvas.drawOval(rect, paint);
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
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final inset = strokeWidth / 2 + 4;
    canvas.drawLine(
      Offset(inset, inset),
      Offset(size.width - inset, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      paint,
    );
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
