import 'dart:ui';

import 'sugoroku_models.dart';

/// コマ候補（2人が重複なく選ぶ）
class PieceCandidate {
  final String id;
  final String name;
  final Color color;
  final SugorokuPieceShape shape;

  const PieceCandidate({
    required this.id,
    required this.name,
    required this.color,
    required this.shape,
  });

  SugorokuPiece toPiece(int playerId) => SugorokuPiece(
        id: playerId,
        name: name,
        color: color,
        shape: shape,
      );
}

abstract final class SugorokuPieceCatalog {
  /// 2人が重複なく選ぶ（黄・橙は色が近いため除外）
  static const candidates = [
    PieceCandidate(
      id: 'blue_circle',
      name: 'あおまる',
      color: Color(0xFF1565C0),
      shape: SugorokuPieceShape.circle,
    ),
    PieceCandidate(
      id: 'red_circle',
      name: 'あかまる',
      color: Color(0xFFE53935),
      shape: SugorokuPieceShape.circle,
    ),
    PieceCandidate(
      id: 'green_triangle',
      name: 'みどりさんかく',
      color: Color(0xFF43A047),
      shape: SugorokuPieceShape.triangle,
    ),
    PieceCandidate(
      id: 'purple_circle',
      name: 'むらさきまる',
      color: Color(0xFF8E24AA),
      shape: SugorokuPieceShape.circle,
    ),
  ];
}
