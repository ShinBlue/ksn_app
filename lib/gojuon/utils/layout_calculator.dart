import 'package:flutter/material.dart';
import '../models/layout_info.dart';

// レイアウト計算を集約するクラス
class LayoutCalculator {
  // 定数
  static const double cellWidth = 48.0;
  static const double spacing = 4.0;
  static const double checkboxWidth = 40.0;
  static const double checkboxSpacing = 8.0;
  static const double leftPadding = 16.0;
  static const double minWidthForDisplayTargets = 800.0;
  static const double rowHeight = 56.0; // 48 + 8
  static const double mainSectionRows = 5.0;
  static const double yoonSectionRows = 3.0;
  static const double columnCheckboxRowHeight = 56.0;
  static const double yoonSectionSpacing = 16.0;
  static const double containerPadding = 32.0; // top 16 + bottom 16
  static const double containerSpacing = 16.0;
  static const double topContainerHeightRatio = 10.0;
  static const double bottomContainerHeightRatio = 1.44;
  static const double minScale = 0.5;
  static const double maxScale = 1.0;
  static const double screenPadding = 32.0; // 左右のパディング
  static const double screenPaddingVertical = 24.0; // 上下のパディング

  // 利用可能な幅を計算
  static double calculateAvailableWidth(double screenWidth) {
    return screenWidth - screenPadding;
  }

  // 利用可能な高さを計算
  static double calculateAvailableHeight(
    double screenHeight,
    double topPadding,
    double bottomPadding,
  ) {
    return screenHeight - topPadding - bottomPadding - screenPaddingVertical;
  }

  // コンテンツ幅を計算
  static double calculateContentWidth(int totalCellCount) {
    return (totalCellCount * cellWidth) +
        ((totalCellCount - 1) * spacing) +
        checkboxSpacing +
        checkboxWidth;
  }

  // コンテナ幅を計算
  static double calculateContainerWidth(double contentWidth) {
    final baseContainerWidth = contentWidth + leftPadding + leftPadding;
    return baseContainerWidth > minWidthForDisplayTargets
        ? baseContainerWidth
        : minWidthForDisplayTargets;
  }

  // ベースのContainerの高さを推定
  static double calculateEstimatedBaseHeight() {
    return columnCheckboxRowHeight + // 列選択チェックボックス行
        (mainSectionRows * rowHeight) + // あ段からお段
        yoonSectionSpacing + // 拗音セクションとの間隔
        columnCheckboxRowHeight + // 拗音の列選択チェックボックス行
        (yoonSectionRows * rowHeight) + // 拗音の行
        containerPadding; // Padding
  }

  // トップコンテナの高さを計算
  static double calculateTopContainerHeight(double estimatedBaseHeight) {
    return estimatedBaseHeight / topContainerHeightRatio;
  }

  // 総高さを計算
  static double calculateEstimatedTotalHeight(
    double topContainerHeight,
    double estimatedBaseHeight,
  ) {
    return topContainerHeight +
        estimatedBaseHeight +
        containerSpacing + // ベースと下側のContainerの間隔
        (topContainerHeight * bottomContainerHeightRatio); // 下側のContainerの高さ
  }

  // スケールを計算
  static double calculateScale(
    double availableWidth,
    double availableHeight,
    double containerWidth,
    double estimatedTotalHeight,
  ) {
    final widthScale = availableWidth / containerWidth;
    final heightScale = availableHeight / estimatedTotalHeight;
    final scale = widthScale < heightScale ? widthScale : heightScale;
    // スケールが1.0を超える場合は拡大しない（scaleDown）
    // 最小スケールを0.5に設定（小さすぎる場合はスクロール）
    return (scale > maxScale ? maxScale : scale).clamp(minScale, maxScale);
  }

  // すべてのレイアウト情報を一度に計算
  static LayoutInfo calculateLayout(BuildContext context, int totalCellCount) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    final availableWidth = calculateAvailableWidth(screenWidth);
    final availableHeight = calculateAvailableHeight(
      screenHeight,
      topPadding,
      bottomPadding,
    );

    final contentWidth = calculateContentWidth(totalCellCount);
    final containerWidth = calculateContainerWidth(contentWidth);
    final estimatedBaseHeight = calculateEstimatedBaseHeight();
    final topContainerHeight = calculateTopContainerHeight(estimatedBaseHeight);
    final estimatedTotalHeight = calculateEstimatedTotalHeight(
      topContainerHeight,
      estimatedBaseHeight,
    );
    final scale = calculateScale(
      availableWidth,
      availableHeight,
      containerWidth,
      estimatedTotalHeight,
    );

    return LayoutInfo(
      availableWidth: availableWidth,
      availableHeight: availableHeight,
      contentWidth: contentWidth,
      containerWidth: containerWidth,
      estimatedBaseHeight: estimatedBaseHeight,
      topContainerHeight: topContainerHeight,
      estimatedTotalHeight: estimatedTotalHeight,
      scale: scale,
      leftPadding: leftPadding,
      rightPadding: leftPadding,
    );
  }
}
