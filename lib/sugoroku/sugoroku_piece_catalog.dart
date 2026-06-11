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
      name: '青丸',
      color: Color(0xFF1565C0),
      shape: SugorokuPieceShape.circle,
    ),
    PieceCandidate(
      id: 'red_circle',
      name: '赤丸',
      color: Color(0xFFE53935),
      shape: SugorokuPieceShape.circle,
    ),
    PieceCandidate(
      id: 'green_triangle',
      name: '緑三角',
      color: Color(0xFF43A047),
      shape: SugorokuPieceShape.triangle,
    ),
    PieceCandidate(
      id: 'purple_circle',
      name: '紫丸',
      color: Color(0xFF8E24AA),
      shape: SugorokuPieceShape.circle,
    ),
  ];
}
