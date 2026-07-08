import 'package:flutter/material.dart';

import 'sugoroku_board_layout.dart';
import 'sugoroku_models.dart';

/// 進行用すごろく盤（散らしたマス＋矢印で接続）
class SugorokuProgressBoardView extends StatelessWidget {
  final SugorokuBoardSize size;
  final List<SugorokuCellDef> cells;
  final List<SugorokuPiece> pieces;
  final int? selectedPieceId;
  final bool compact;
  final bool framed;
  final bool editable;
  final ValueChanged<int>? onCellTap;

  const SugorokuProgressBoardView({
    super.key,
    required this.size,
    required this.cells,
    required this.pieces,
    required this.selectedPieceId,
    this.compact = false,
    this.framed = true,
    this.editable = false,
    this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = SugorokuBoardLayout.centersFor(size);
    final cellFraction = SugorokuBoardLayout.cellFraction(size);

    final board = AspectRatio(
      aspectRatio: SugorokuBoardLayout.aspectRatio(size),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardSize = Size(constraints.maxWidth, constraints.maxHeight);
          final cellSize = boardSize.shortestSide * cellFraction;
          final cellRadius = cellSize / 2;
          // マス中心を内側に寄せ、端のマスがはみ出さないようにする
          const selectionRing = 3.0;
          final inset = cellRadius + selectionRing;
          final innerW = (boardSize.width - inset * 2).clamp(1.0, double.infinity);
          final innerH =
              (boardSize.height - inset * 2).clamp(1.0, double.infinity);
          final centers = normalized
              .map(
                (p) => Offset(
                  inset + p.dx * innerW,
                  inset + p.dy * innerH,
                ),
              )
              .toList();

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              CustomPaint(
                size: boardSize,
                painter: SugorokuBoardArrowsPainter(
                  centers: centers,
                  cellRadius: cellRadius,
                ),
              ),
              for (var i = 0; i < cells.length; i++)
                Positioned(
                  left: centers[i].dx - cellSize / 2,
                  top: centers[i].dy - cellSize / 2,
                  width: cellSize,
                  height: cellSize,
                  child: _BoardCell(
                    cell: cells[i],
                    index: i,
                    cellCount: cells.length,
                    boardSize: size,
                    piecesHere: pieces.where((p) => p.position == i).toList(),
                    selectedPieceId: selectedPieceId,
                    compactPieces: compact || size == SugorokuBoardSize.long20,
                    editable: editable,
                    onTap: editable && onCellTap != null
                        ? () => onCellTap!(i)
                        : null,
                  ),
                ),
            ],
          );
        },
      ),
    );

    if (!framed) return board;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF455A64), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: board,
    );
  }
}

class _BoardCell extends StatelessWidget {
  final SugorokuCellDef cell;
  final int index;
  final int cellCount;
  final SugorokuBoardSize boardSize;
  final List<SugorokuPiece> piecesHere;
  final int? selectedPieceId;
  final bool compactPieces;
  final bool editable;
  final VoidCallback? onTap;

  const _BoardCell({
    required this.cell,
    required this.index,
    required this.cellCount,
    required this.boardSize,
    required this.piecesHere,
    required this.selectedPieceId,
    required this.compactPieces,
    this.editable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isStart = index == 0;
    final isGoal = index == cellCount - 1;

    Color fill;
    if (isStart) {
      fill = const Color(0xFFA5D6A7);
    } else if (isGoal) {
      fill = const Color(0xFFF8BBD0);
    } else if (cell.action != SugorokuCellAction.none) {
      fill = const Color(0xFFFFF176);
    } else {
      fill = const Color(0xFFB3E5FC);
    }

    final showLabel = cell.hasLabel && (piecesHere.isEmpty || editable);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: editable
                  ? const Color(0xFF43A047)
                  : const Color(0xFF455A64),
              width: editable ? 2.5 : 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 2),
                blurRadius: 3,
              ),
            ],
          ),
          child: Stack(
            children: [
              if (showLabel)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        cell.label,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: boardSize == SugorokuBoardSize.long20
                              ? 13
                              : 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF263238),
                          height: 1.15,
                        ),
                      ),
                    ),
                  ),
                ),
              if (piecesHere.isNotEmpty)
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _PiecesCluster(
                      pieces: piecesHere,
                      selectedPieceId: selectedPieceId,
                      compact: compactPieces,
                    ),
                  ),
                ),
              if (editable && !cell.hasLabel)
                Center(
                  child: Icon(
                    Icons.add,
                    size: compactPieces ? 12 : 14,
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PiecesCluster extends StatelessWidget {
  final List<SugorokuPiece> pieces;
  final int? selectedPieceId;
  final bool compact;

  const _PiecesCluster({
    required this.pieces,
    required this.selectedPieceId,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (pieces.length == 1) {
      final size = compact ? 20.0 : 26.0;
      return _PieceMarker(
        piece: pieces.first,
        selected: pieces.first.id == selectedPieceId,
        size: size,
      );
    }

    final size = compact ? 14.0 : 18.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < pieces.length; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          _PieceMarker(
            piece: pieces[i],
            selected: pieces[i].id == selectedPieceId,
            size: size,
          ),
        ],
      ],
    );
  }
}

class _PieceMarker extends StatelessWidget {
  final SugorokuPiece piece;
  final bool selected;
  final double size;

  const _PieceMarker({
    required this.piece,
    required this.selected,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PiecePainter(piece: piece, selected: selected),
    );
  }
}

class _PiecePainter extends CustomPainter {
  final SugorokuPiece piece;
  final bool selected;

  _PiecePainter({required this.piece, required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.38;

    if (selected) {
      canvas.drawCircle(
        center,
        r + 3,
        Paint()
          ..color = Colors.orange
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    final fill = Paint()..color = piece.color;
    final border = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    if (piece.shape == SugorokuPieceShape.circle) {
      canvas.drawCircle(center, r, fill);
      canvas.drawCircle(center, r, border);
    } else {
      final path = Path()
        ..moveTo(center.dx, center.dy - r)
        ..lineTo(center.dx - r, center.dy + r * 0.85)
        ..lineTo(center.dx + r, center.dy + r * 0.85)
        ..close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, border);
    }
  }

  @override
  bool shouldRepaint(covariant _PiecePainter oldDelegate) =>
      oldDelegate.piece.position != piece.position ||
      oldDelegate.selected != selected;
}

class SugorokuDiceFace extends StatelessWidget {
  final int value;
  final double size;

  const SugorokuDiceFace({super.key, required this.value, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF455A64), width: 2),
      ),
      child: CustomPaint(painter: _DiceDotsPainter(value: value)),
    );
  }
}

class _DiceDotsPainter extends CustomPainter {
  final int value;

  _DiceDotsPainter({required this.value});

  static const _positions = {
    1: [Offset(0.5, 0.5)],
    2: [Offset(0.28, 0.28), Offset(0.72, 0.72)],
    3: [Offset(0.28, 0.28), Offset(0.5, 0.5), Offset(0.72, 0.72)],
    4: [
      Offset(0.28, 0.28),
      Offset(0.72, 0.28),
      Offset(0.28, 0.72),
      Offset(0.72, 0.72),
    ],
    5: [
      Offset(0.28, 0.28),
      Offset(0.72, 0.28),
      Offset(0.5, 0.5),
      Offset(0.28, 0.72),
      Offset(0.72, 0.72),
    ],
    6: [
      Offset(0.28, 0.25),
      Offset(0.72, 0.25),
      Offset(0.28, 0.5),
      Offset(0.72, 0.5),
      Offset(0.28, 0.75),
      Offset(0.72, 0.75),
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = const Color(0xFF263238);
    final r = size.shortestSide * 0.07;
    for (final p in _positions[value] ?? _positions[1]!) {
      canvas.drawCircle(
        Offset(p.dx * size.width, p.dy * size.height),
        r,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DiceDotsPainter oldDelegate) =>
      oldDelegate.value != value;
}
