import 'sugoroku_models.dart';

abstract final class SugorokuMovement {
  static int clampPosition(int index, int cellCount) {
    return index.clamp(0, cellCount - 1);
  }

  static String applyCellEffect({
    required SugorokuPiece piece,
    required List<SugorokuCellDef> cells,
    required int cellCount,
    required void Function(int pieceId) markSkipNextTurn,
  }) {
    final cell = cells[piece.position];

    final message = switch (cell.action) {
      SugorokuCellAction.moveForward => () {
          piece.position =
              clampPosition(piece.position + cell.value, cellCount);
          return '${cell.label.replaceAll('\n', '')}！';
        }(),
      SugorokuCellAction.moveBackward => () {
          piece.position =
              clampPosition(piece.position - cell.value, cellCount);
          return '${cell.label.replaceAll('\n', '')}！';
        }(),
      SugorokuCellAction.backToStart => () {
          piece.position = 0;
          return 'さいしょから！';
        }(),
      SugorokuCellAction.skipTurn => () {
          markSkipNextTurn(piece.id);
          return 'おやすみ！';
        }(),
      SugorokuCellAction.none => '',
    };

    if (piece.position == cellCount - 1) {
      return '${piece.name}、ゴール！';
    }
    return message;
  }

  /// 1マス進め、残り歩数を返す。0になったらマス効果を適用しメッセージを返す。
  static ({int remaining, String message}) advanceOneStep({
    required SugorokuPiece piece,
    required List<SugorokuCellDef> cells,
    required int cellCount,
    required int remainingBefore,
    required void Function(int pieceId) markSkipNextTurn,
  }) {
    if (remainingBefore <= 0) {
      return (remaining: 0, message: '');
    }

    if (piece.position >= cellCount - 1) {
      return (remaining: 0, message: '${piece.name}、ゴール！');
    }

    piece.position = clampPosition(piece.position + 1, cellCount);
    final remaining = remainingBefore - 1;

    if (remaining > 0) {
      return (
        remaining: remaining,
        message: 'あと$remainingます（がめんをタップ）',
      );
    }

    final effect = applyCellEffect(
      piece: piece,
      cells: cells,
      cellCount: cellCount,
      markSkipNextTurn: markSkipNextTurn,
    );
    if (effect.isNotEmpty) {
      return (remaining: 0, message: effect);
    }
    return (remaining: 0, message: '${piece.name}がすすんだよ');
  }
}
