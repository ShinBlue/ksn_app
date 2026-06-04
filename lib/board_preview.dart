import 'package:flutter/material.dart';

import 'board_type.dart';

class BoardPreview extends StatelessWidget {
  final BoardType boardType;
  final List<String>? labels;
  final List<Color>? colors;

  const BoardPreview({
    super.key,
    required this.boardType,
    this.labels,
    this.colors,
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
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 0.5),
          ),
          child: Center(
            child: FittedBox(
              child: Text(labels![i], style: const TextStyle(fontSize: 10)),
            ),
          ),
        );
      },
    );
  }
}
