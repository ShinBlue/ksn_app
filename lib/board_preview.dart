import 'package:flutter/material.dart';

import 'board_type.dart';
import 'illustration_board_pattern.dart';
import 'illustration_cell_image.dart';

class BoardPreview extends StatelessWidget {
  final BoardType boardType;
  final List<String>? labels;
  final List<Color>? colors;
  final List<String>? images;
  final IllustrationBoardPattern? illustrationPattern;

  const BoardPreview({
    super.key,
    required this.boardType,
    this.labels,
    this.colors,
    this.images,
    this.illustrationPattern,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: 9,
      itemBuilder: (_, i) {
        if (boardType == BoardType.color) {
          return Container(
            decoration: BoxDecoration(
              color: colors![i],
              border: Border.all(color: Colors.grey.shade400, width: 0.5),
            ),
          );
        }
        if (boardType == BoardType.illustration) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400, width: 0.5),
            ),
            child: IllustrationCellImage(
              assetPath: images![i],
              pattern: illustrationPattern,
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 0.5),
          ),
          child: Center(
            child: FittedBox(
              child: Text(labels![i], style: const TextStyle(fontSize: 12.5)),
            ),
          ),
        );
      },
    );
  }
}
