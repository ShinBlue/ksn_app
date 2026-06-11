import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'sugoroku_models.dart';

/// すごろく盤のマス位置（0〜1 の正規化座標）と矢印描画。
abstract final class SugorokuBoardLayout {
  /// 10マス：ジグザグに散らし、順番どおり矢印で接続。
  static const short10Centers = <Offset>[
    Offset(0.10, 0.78),
    Offset(0.30, 0.88),
    Offset(0.52, 0.74),
    Offset(0.74, 0.86),
    Offset(0.92, 0.70),
    Offset(0.78, 0.50),
    Offset(0.54, 0.58),
    Offset(0.30, 0.44),
    Offset(0.12, 0.30),
    Offset(0.50, 0.10),
  ];

  /// 20マス：縦長に散らしたジグザグ経路（端は内側に収める）。
  static const long20Centers = <Offset>[
    Offset(0.12, 0.90),
    Offset(0.30, 0.85),
    Offset(0.50, 0.92),
    Offset(0.70, 0.87),
    Offset(0.88, 0.80),
    Offset(0.80, 0.68),
    Offset(0.58, 0.72),
    Offset(0.34, 0.66),
    Offset(0.14, 0.70),
    Offset(0.12, 0.54),
    Offset(0.32, 0.48),
    Offset(0.56, 0.52),
    Offset(0.78, 0.46),
    Offset(0.88, 0.36),
    Offset(0.74, 0.26),
    Offset(0.52, 0.30),
    Offset(0.28, 0.24),
    Offset(0.12, 0.18),
    Offset(0.38, 0.10),
    Offset(0.68, 0.08),
  ];

  static List<Offset> centersFor(SugorokuBoardSize size) =>
      size == SugorokuBoardSize.short10 ? short10Centers : long20Centers;

  static double aspectRatio(SugorokuBoardSize size) =>
      size == SugorokuBoardSize.short10 ? 1.15 : 0.72;

  static double cellFraction(SugorokuBoardSize size) =>
      size == SugorokuBoardSize.short10 ? 0.17 : 0.11;
}

class SugorokuBoardArrowsPainter extends CustomPainter {
  final List<Offset> centers;
  final double cellRadius;

  SugorokuBoardArrowsPainter({
    required this.centers,
    required this.cellRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.length < 2) return;

    final stroke = Paint()
      ..color = const Color(0xFF546E7A)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final headFill = Paint()
      ..color = const Color(0xFF546E7A)
      ..style = PaintingStyle.fill;

    const headLen = 9.0;

    for (var i = 0; i < centers.length - 1; i++) {
      final from = centers[i];
      final to = centers[i + 1];
      final delta = to - from;
      final len = delta.distance;
      if (len < 1) continue;

      final unit = Offset(delta.dx / len, delta.dy / len);
      final start = from + unit * cellRadius;
      final end = to - unit * (cellRadius + headLen * 0.6);

      canvas.drawLine(start, end, stroke);
      _drawArrowhead(
        canvas,
        tip: to - unit * cellRadius,
        unit: unit,
        fill: headFill,
      );
    }
  }

  void _drawArrowhead(Canvas canvas, {required Offset tip, required Offset unit, required Paint fill}) {
    const headLen = 9.0;
    const headAngle = 0.45;
    final base = tip - unit * headLen;
    final perp = Offset(-unit.dy, unit.dx);
    final wing = headLen * math.tan(headAngle);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base.dx + perp.dx * wing, base.dy + perp.dy * wing)
      ..lineTo(base.dx - perp.dx * wing, base.dy - perp.dy * wing)
      ..close();
    canvas.drawPath(path, fill);
  }

  @override
  bool shouldRepaint(covariant SugorokuBoardArrowsPainter oldDelegate) => false;
}
