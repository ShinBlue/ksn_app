import 'package:flutter/material.dart';

import 'sugoroku_animals.dart';
import 'sugoroku_heart_number.dart';
import 'sugoroku_models.dart';

enum AnimalBoardLayout {
  /// 盤面下または画像盤（デフォルト）
  standard,

  /// 20マス用・右パネル内の2列カード
  sidePanel,
}

/// 動物選択盤（③④用）。10マス=2×5カード、20マス=画像+タップ。
class SugorokuAnimalBoardView extends StatelessWidget {
  final SugorokuBoardSize size;
  final SugorokuPlayMode mode;
  final HiddenNumberBoardState? hiddenState;
  final ValueChanged<AnimalSpot> onAnimalSelected;
  final bool enabled;
  final AnimalBoardLayout layout;

  /// 表示する動物リストの明示指定（省略時は [SugorokuAnimals.forSize]）。
  /// 10マス盤はゲーム開始ごとにランダム抽選した固定リストを渡す想定。
  final List<AnimalSpot>? animals;

  const SugorokuAnimalBoardView({
    super.key,
    required this.size,
    required this.mode,
    required this.onAnimalSelected,
    this.hiddenState,
    this.enabled = true,
    this.layout = AnimalBoardLayout.standard,
    this.animals,
  });

  @override
  Widget build(BuildContext context) {
    final animals = this.animals ?? SugorokuAnimals.forSize(size);
    if (size == SugorokuBoardSize.long20 &&
        layout == AnimalBoardLayout.sidePanel) {
      return _AnimalSidePanelGrid(
        animals: animals,
        mode: mode,
        hiddenState: hiddenState,
        onAnimalSelected: onAnimalSelected,
        enabled: enabled,
      );
    }
    if (size == SugorokuBoardSize.long20) {
      return _AnimalImageBoard(
        animals: animals,
        mode: mode,
        hiddenState: hiddenState,
        onAnimalSelected: onAnimalSelected,
        enabled: enabled,
      );
    }
    return _AnimalCardGrid(
      animals: animals,
      columns: size.gridColumns,
      mode: mode,
      hiddenState: hiddenState,
      onAnimalSelected: onAnimalSelected,
      enabled: enabled,
    );
  }
}

class _AnimalImageBoard extends StatelessWidget {
  final List<AnimalSpot> animals;
  final SugorokuPlayMode mode;
  final HiddenNumberBoardState? hiddenState;
  final ValueChanged<AnimalSpot> onAnimalSelected;
  final bool enabled;

  const _AnimalImageBoard({
    required this.animals,
    required this.mode,
    required this.hiddenState,
    required this.onAnimalSelected,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    const columns = SugorokuAnimals.boardColumns20;
    const rows = SugorokuAnimals.boardRows20;
    return AspectRatio(
      aspectRatio: SugorokuAnimals.boardAspectRatio20,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardSize = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                SugorokuAnimals.boardImage20,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: Colors.grey.shade200,
                  child: const Center(child: Text('どうぶつばんめんをよみこめません')),
                ),
              ),
              for (final animal in animals)
                _gridTapTarget(
                  boardSize: boardSize,
                  index: animal.index,
                  columns: columns,
                  rows: rows,
                  child: _overlayContent(animal),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _overlayContent(AnimalSpot animal) {
    if (mode == SugorokuPlayMode.hiddenNumber && hiddenState != null) {
      if (hiddenState!.isRevealed(animal.index)) {
        return _revealedLabel(animal.name);
      }
      return HeartNumberBadge(
        number: hiddenState!.numberAt(animal.index),
        color: hiddenState!.colorAt(animal.index),
      );
    }
    if (mode == SugorokuPlayMode.animalPick) {
      return _pickHint();
    }
    return const SizedBox.shrink();
  }

  Widget _gridTapTarget({
    required Size boardSize,
    required int index,
    required int columns,
    required int rows,
    required Widget child,
  }) {
    final col = index % columns;
    final row = index ~/ columns;
    final cellW = boardSize.width / columns;
    final cellH = boardSize.height / rows;
    return Positioned(
      left: col * cellW,
      top: row * cellH,
      width: cellW,
      height: cellH,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: !enabled
              ? null
              : () => onAnimalSelected(
                    animals.firstWhere((a) => a.index == index),
                  ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _AnimalSidePanelGrid extends StatelessWidget {
  final List<AnimalSpot> animals;
  final SugorokuPlayMode mode;
  final HiddenNumberBoardState? hiddenState;
  final ValueChanged<AnimalSpot> onAnimalSelected;
  final bool enabled;

  const _AnimalSidePanelGrid({
    required this.animals,
    required this.mode,
    required this.hiddenState,
    required this.onAnimalSelected,
    required this.enabled,
  });

  static const _columns = 2;
  static const _spacing = 3.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = (animals.length / _columns).ceil();
        final availW = constraints.maxWidth.clamp(1.0, double.infinity);
        final availH = constraints.maxHeight.clamp(1.0, double.infinity);
        final cellW = (availW - _spacing * (_columns - 1)) / _columns;
        final cellH = (availH - _spacing * (rows - 1)) / rows;
        final cardStyle = _AnimalCardStyle.forCell(cellW, cellH);

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns,
            crossAxisSpacing: _spacing,
            mainAxisSpacing: _spacing,
            childAspectRatio: cellW / cellH,
          ),
          itemCount: animals.length,
          itemBuilder: (context, i) {
            final animal = animals[i];
            return _AnimalCard(
              animal: animal,
              mode: mode,
              hiddenState: hiddenState,
              enabled: enabled,
              style: cardStyle,
              onTap: () => onAnimalSelected(animal),
            );
          },
        );
      },
    );
  }
}

class _AnimalCardStyle {
  final double borderRadius;
  final double borderWidth;
  final double padding;
  final double nameFontSize;
  final double badgeSize;
  final double hintIconSize;
  final bool showHint;
  final bool showName;

  const _AnimalCardStyle({
    required this.borderRadius,
    required this.borderWidth,
    required this.padding,
    required this.nameFontSize,
    required this.badgeSize,
    required this.hintIconSize,
    required this.showHint,
    required this.showName,
  });

  factory _AnimalCardStyle.standard({required bool compact}) {
    return _AnimalCardStyle(
      borderRadius: compact ? 8 : 14,
      borderWidth: compact ? 1.5 : 2.5,
      padding: compact ? 3 : 6,
      nameFontSize: compact ? 9 : 12,
      badgeSize: compact ? 32 : 48,
      hintIconSize: compact ? 12 : 16,
      showHint: true,
      showName: true,
    );
  }

  factory _AnimalCardStyle.forCell(double width, double height) {
    final minSide = width < height ? width : height;
    return _AnimalCardStyle(
      borderRadius: (minSide * 0.14).clamp(3.0, 8.0),
      borderWidth: (minSide * 0.04).clamp(1.0, 2.0),
      padding: (minSide * 0.06).clamp(1.0, 4.0),
      nameFontSize: (minSide * 0.16).clamp(6.0, 10.0),
      badgeSize: (minSide * 0.72).clamp(18.0, 36.0),
      hintIconSize: (minSide * 0.22).clamp(8.0, 14.0),
      showHint: minSide >= 34,
      showName: minSide >= 28,
    );
  }
}

class _AnimalCardGrid extends StatelessWidget {
  final List<AnimalSpot> animals;
  final int columns;
  final SugorokuPlayMode mode;
  final HiddenNumberBoardState? hiddenState;
  final ValueChanged<AnimalSpot> onAnimalSelected;
  final bool enabled;

  const _AnimalCardGrid({
    required this.animals,
    required this.columns,
    required this.mode,
    required this.hiddenState,
    required this.onAnimalSelected,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: columns / 2,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: animals.length,
        itemBuilder: (context, i) {
          final animal = animals[i];
          return _AnimalCard(
            animal: animal,
            mode: mode,
            hiddenState: hiddenState,
            enabled: enabled,
            onTap: () => onAnimalSelected(animal),
          );
        },
      ),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  final AnimalSpot animal;
  final SugorokuPlayMode mode;
  final HiddenNumberBoardState? hiddenState;
  final VoidCallback onTap;
  final bool enabled;
  final _AnimalCardStyle style;

  _AnimalCard({
    required this.animal,
    required this.mode,
    required this.hiddenState,
    required this.onTap,
    required this.enabled,
    _AnimalCardStyle? style,
  }) : style = style ?? _AnimalCardStyle.standard(compact: false);

  @override
  Widget build(BuildContext context) {
    final imagePath = SugorokuAnimals.imageByName[animal.name];
    final hidden = mode == SugorokuPlayMode.hiddenNumber &&
        hiddenState != null &&
        !hiddenState!.isRevealed(animal.index);

    return Material(
      color: const Color(0xFFFFF8E1),
      borderRadius: BorderRadius.circular(style.borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(style.borderRadius),
        onTap: enabled ? onTap : null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(style.borderRadius),
            border: Border.all(
              color: const Color(0xFF66BB6A),
              width: style.borderWidth,
            ),
          ),
          padding: EdgeInsets.all(style.padding),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (!hidden) ...[
                if (imagePath != null)
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(style.borderRadius * 0.5),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _nameFallback(style.nameFontSize),
                    ),
                  )
                else
                  _nameFallback(style.nameFontSize),
                if (style.showName)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: style.padding.clamp(0, 2),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(
                          style.borderRadius * 0.5,
                        ),
                      ),
                      child: Text(
                        animal.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: style.nameFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
              if (hidden)
                Center(
                  child: HeartNumberBadge(
                    number: hiddenState!.numberAt(animal.index),
                    color: hiddenState!.colorAt(animal.index),
                    size: style.badgeSize,
                  ),
                ),
              if (mode == SugorokuPlayMode.animalPick && !hidden && style.showHint)
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.touch_app,
                    size: style.hintIconSize,
                    color: Colors.green.shade700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nameFallback(double fontSize) {
    return Center(
      child: Text(
        animal.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF455A64),
        ),
      ),
    );
  }
}

Widget _revealedLabel(String name) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFF66BB6A), width: 2),
    ),
    child: Text(
      name,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Color(0xFF37474F),
      ),
    ),
  );
}

Widget _pickHint() {
  return Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.75),
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFF66BB6A), width: 2),
    ),
    child: Icon(Icons.touch_app, size: 20, color: Colors.green.shade700),
  );
}
