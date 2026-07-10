import 'sugoroku_models.dart';

abstract final class SugorokuBoardDefaults {
  static SugorokuCellDef defaultCellAt(SugorokuBoardSize size, int index) =>
      cellsFor(size)[index];

  static List<SugorokuCellDef> cellsFor(SugorokuBoardSize size) {
    final count = size.cellCount;
    return List.generate(count, (i) {
      if (i == 0) {
        return const SugorokuCellDef(label: 'スタート');
      }
      if (i == count - 1) {
        return const SugorokuCellDef(label: 'ゴール');
      }
      return _defaultSpecial(i, size);
    });
  }

  static SugorokuCellDef _defaultSpecial(int index, SugorokuBoardSize size) {
    if (size == SugorokuBoardSize.short10) {
      return switch (index) {
        3 => const SugorokuCellDef(
            label: 'ひとつ\nすすむ',
            action: SugorokuCellAction.moveForward,
            value: 1,
          ),
        6 => const SugorokuCellDef(
            label: 'おやすみ',
            action: SugorokuCellAction.skipTurn,
          ),
        _ => const SugorokuCellDef(),
      };
    }
    return switch (index) {
      4 => const SugorokuCellDef(
          label: 'ひとつ\nすすむ',
          action: SugorokuCellAction.moveForward,
          value: 1,
        ),
      9 => const SugorokuCellDef(
          label: 'ふたつ\nすすむ',
          action: SugorokuCellAction.moveForward,
          value: 2,
        ),
      14 => const SugorokuCellDef(
          label: 'おやすみ',
          action: SugorokuCellAction.skipTurn,
        ),
      17 => const SugorokuCellDef(
          label: 'ひとつ\nもどる',
          action: SugorokuCellAction.moveBackward,
          value: 1,
        ),
      _ => const SugorokuCellDef(),
    };
  }
}
