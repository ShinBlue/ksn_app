class LayoutInfo {
  final double availableWidth;
  final double availableHeight;
  final double contentWidth;
  final double containerWidth;
  final double estimatedBaseHeight;
  final double topContainerHeight;
  final double estimatedTotalHeight;
  final double scale;
  final double leftPadding;
  final double rightPadding;

  LayoutInfo({
    required this.availableWidth,
    required this.availableHeight,
    required this.contentWidth,
    required this.containerWidth,
    required this.estimatedBaseHeight,
    required this.topContainerHeight,
    required this.estimatedTotalHeight,
    required this.scale,
    required this.leftPadding,
    required this.rightPadding,
  });
}
