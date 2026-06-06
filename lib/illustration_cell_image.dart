import 'package:flutter/material.dart';

import 'illustration_board_pattern.dart';

class IllustrationCellImage extends StatelessWidget {
  final String assetPath;
  final IllustrationBoardPattern? pattern;

  const IllustrationCellImage({
    super.key,
    required this.assetPath,
    this.pattern,
  });

  @override
  Widget build(BuildContext context) {
    final isVehicle = pattern == IllustrationBoardPattern.vehicle;

    return ClipRect(
      child: Padding(
        padding: EdgeInsets.all(isVehicle ? 8 : 2),
        child: Image.asset(
          assetPath,
          fit: isVehicle ? BoxFit.contain : BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.broken_image, size: 12),
          ),
        ),
      ),
    );
  }
}
