import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'sugoroku_models.dart';

/// すごろく盤のマス位置（0〜1 の正規化座標）と矢印描画。
abstract final class SugorokuBoardLayout {
  static const boardWidthScale = 1.5;
  static const boardHeightScale = 1.2;

  /// 10マス：ジグザグに散らし、順番どおり矢印で接続。
  static const short10Centers = <Offset>[
    Offset(0.06, 0.84),
    Offset(0.24, 0.92),
    Offset(0.44, 0.80),
    Offset(0.64, 0.90),
    Offset(0.90, 0.78),
    Offset(0.82, 0.54),
    Offset(0.58, 0.60),
    Offset(0.34, 0.46),
    Offset(0.10, 0.32),
    Offset(0.48, 0.06),
  ];

  /// 20マス：縦長に散らしたジグザグ経路（マス同士が重ならないよう間隔を確保）。
  static const long20Centers = <Offset>[
    Offset(0.05, 0.94),
    Offset(0.20, 0.88),
    Offset(0.36, 0.94),
    Offset(0.52, 0.88),
    Offset(0.68, 0.94),
    Offset(0.88, 0.86),
    Offset(0.82, 0.70),
    Offset(0.62, 0.74),
    Offset(0.42, 0.68),
    Offset(0.22, 0.74),
    Offset(0.05, 0.60),
    Offset(0.18, 0.46),
    Offset(0.36, 0.50),
    Offset(0.54, 0.44),
    Offset(0.72, 0.48),
    Offset(0.90, 0.38),
    Offset(0.76, 0.24),
    Offset(0.54, 0.28),
    Offset(0.30, 0.20),
    Offset(0.50, 0.04),
  ];

  static List<Offset> centersFor(SugorokuBoardSize size) =>
      size == SugorokuBoardSize.short10 ? short10Centers : long20Centers;

  static double maxBoardWidth(SugorokuBoardSize size) {
    final base = size == SugorokuBoardSize.short10 ? 400.0 : 480.0;
    return base * boardWidthScale;
  }

  static double aspectRatio(SugorokuBoardSize size) {
    final base = size == SugorokuBoardSize.short10 ? 1.15 : 0.72;
    return base * boardWidthScale / boardHeightScale;
  }

  static double cellFraction(SugorokuBoardSize size) =>
      size == SugorokuBoardSize.short10 ? 0.16 : 0.095;

  static const framedPadding = 24.0;

  /// 利用可能な領域に収まる盤面の幅を計算する。
  static double boardWidthFitting({
    required SugorokuBoardSize size,
    required double maxWidth,
    required double maxHeight,
    bool framed = true,
    double overheadTop = 0,
    double overheadBottom = 0,
    double gapBetween = 0,
    double? secondaryAspectRatio,
  }) {
    final aspect = aspectRatio(size);
    final framePad = framed ? framedPadding : 0.0;
    final availW = (maxWidth - framePad).clamp(1.0, double.infinity);
    final availH =
        (maxHeight - framePad - overheadTop - overheadBottom).clamp(1.0, double.infinity);

    double width;
    if (secondaryAspectRatio != null) {
      width = (availH - gapBetween) / (1 / aspect + 1 / secondaryAspectRatio);
    } else {
      width = availH * aspect;
    }

    return width.clamp(1.0, availW).clamp(1.0, maxBoardWidth(size));
  }

  static double boardHeightForWidth(SugorokuBoardSize size, double width) =>
      width / aspectRatio(size);

  /// 20マス＋動物盤を横並びにしたときの寸法（盤左・動物右）。
  static ({
    double boardWidth,
    double boardHeight,
    double animalWidth,
    double animalHeight,
    double totalWidth,
  }) sideBySideDimensionsFitting({
    required SugorokuBoardSize size,
    required double maxWidth,
    required double maxHeight,
    required double secondaryAspectRatio,
    double overheadTop = 0,
    double gapBetween = 12,
  }) {
    final aspect = aspectRatio(size);
    final framePad = framedPadding;
    final availW = (maxWidth - framePad).clamp(1.0, double.infinity);
    final availH =
        (maxHeight - framePad - overheadTop).clamp(1.0, double.infinity);

    final height =
        ((availW - gapBetween) / (aspect + secondaryAspectRatio))
            .clamp(1.0, availH);
    final boardWidth = height * aspect;
    final animalWidth = height * secondaryAspectRatio;

    return (
      boardWidth: boardWidth,
      boardHeight: height,
      animalWidth: animalWidth,
      animalHeight: height,
      totalWidth: boardWidth + gapBetween + animalWidth + framePad,
    );
  }

  /// 動物盤カラムの幅（従来レイアウトと同じ計算で維持）。
  static double animalColumnWidthFitting({
    required SugorokuBoardSize size,
    required double maxWidth,
    required double maxHeight,
    required double secondaryAspectRatio,
    double overheadTop = 0,
    double gapBetween = 12,
  }) {
    if (size == SugorokuBoardSize.long20) {
      return sideBySideDimensionsFitting(
        size: size,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        secondaryAspectRatio: secondaryAspectRatio,
        overheadTop: overheadTop,
        gapBetween: gapBetween,
      ).animalWidth;
    }
    return boardWidthFitting(
      size: size,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      overheadTop: overheadTop,
      gapBetween: gapBetween,
      secondaryAspectRatio: secondaryAspectRatio,
    );
  }
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
