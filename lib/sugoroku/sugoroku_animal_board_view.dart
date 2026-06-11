import 'package:flutter/material.dart';

import 'sugoroku_animals.dart';
import 'sugoroku_heart_number.dart';
import 'sugoroku_models.dart';

/// 動物選択盤（③④用）。10マス=2×5カード、20マス=画像+タップ。
class SugorokuAnimalBoardView extends StatelessWidget {
  final SugorokuBoardSize size;
  final SugorokuPlayMode mode;
  final HiddenNumberBoardState? hiddenState;
  final ValueChanged<AnimalSpot> onAnimalSelected;
  final bool enabled;

  const SugorokuAnimalBoardView({
    super.key,
    required this.size,
    required this.mode,
    required this.onAnimalSelected,
    this.hiddenState,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final animals = SugorokuAnimals.forSize(size);
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
    const columns = 4;
    const rows = 5;
    return AspectRatio(
      aspectRatio: 842 / 595,
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
                  child: const Center(child: Text('動物盤面を読み込めません')),
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

  const _AnimalCard({
    required this.animal,
    required this.mode,
    required this.hiddenState,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = SugorokuAnimals.imageByName[animal.name];
    final hidden = mode == SugorokuPlayMode.hiddenNumber &&
        hiddenState != null &&
        !hiddenState!.isRevealed(animal.index);

    return Material(
      color: const Color(0xFFFFF8E1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onTap : null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF66BB6A), width: 2.5),
          ),
          padding: const EdgeInsets.all(6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (!hidden) ...[
                if (imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _nameFallback(),
                    ),
                  )
                else
                  _nameFallback(),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      animal.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
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
                    size: 48,
                  ),
                ),
              if (mode == SugorokuPlayMode.animalPick && !hidden)
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.touch_app,
                    size: 16,
                    color: Colors.green.shade700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nameFallback() {
    return Center(
      child: Text(
        animal.name,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF455A64),
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
