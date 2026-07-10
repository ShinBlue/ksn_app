import 'dart:ui';

enum SugorokuBoardSize { short10, long20 }

enum SugorokuPlayMode {
  dice,
  janken,
  animalPick,
  hiddenNumber,
}

extension SugorokuBoardSizeX on SugorokuBoardSize {
  int get cellCount => this == SugorokuBoardSize.short10 ? 10 : 20;

  int get gridColumns => this == SugorokuBoardSize.short10 ? 5 : 4;

  int get gridRows => this == SugorokuBoardSize.short10 ? 2 : 5;

  String get label => this == SugorokuBoardSize.short10 ? '10ます（みじかい）' : '20ます（ながい）';
}

extension SugorokuPlayModeX on SugorokuPlayMode {
  String get label => switch (this) {
        SugorokuPlayMode.dice => 'サイコロ',
        SugorokuPlayMode.janken => 'じゃんけん',
        SugorokuPlayMode.animalPick => 'どうぶつをえらぶ',
        SugorokuPlayMode.hiddenNumber => 'すうじあて',
      };

  String get description => switch (this) {
        SugorokuPlayMode.dice => 'サイコロのめのかずだけすすむ',
        SugorokuPlayMode.janken => 'グー・チョキは2ます、パーは3ます',
        SugorokuPlayMode.animalPick => 'どうぶつをえらんで、なまえのかずだけすすむ',
        SugorokuPlayMode.hiddenNumber => 'すうじをタップしてどうぶつをあてて、かずだけすすむ',
      };

  bool get usesAnimalBoard =>
      this == SugorokuPlayMode.animalPick ||
      this == SugorokuPlayMode.hiddenNumber;
}

enum SugorokuCellAction {
  none,
  moveForward,
  moveBackward,
  skipTurn,
  backToStart,
}

enum SugorokuPieceShape { circle, triangle }

class SugorokuCellDef {
  final SugorokuCellAction action;
  final int value;
  final String label;

  const SugorokuCellDef({
    this.action = SugorokuCellAction.none,
    this.value = 0,
    this.label = '',
  });

  bool get hasLabel => label.isNotEmpty;

  SugorokuCellDef copyWith({
    SugorokuCellAction? action,
    int? value,
    String? label,
  }) {
    return SugorokuCellDef(
      action: action ?? this.action,
      value: value ?? this.value,
      label: label ?? this.label,
    );
  }
}

class SugorokuPiece {
  final int id;
  final String name;
  final Color color;
  final SugorokuPieceShape shape;
  int position;

  SugorokuPiece({
    required this.id,
    required this.name,
    required this.color,
    required this.shape,
    this.position = 0,
  });
}

class AnimalSpot {
  final int index;
  final String name;

  const AnimalSpot({required this.index, required this.name});

  int get stepCount => name.length;
}

class HiddenNumberBoardState {
  final List<int> shuffledNumbers;
  final Set<int> revealedIndices;
  final List<Color> heartColors;

  const HiddenNumberBoardState({
    required this.shuffledNumbers,
    required this.revealedIndices,
    required this.heartColors,
  });

  bool isRevealed(int index) => revealedIndices.contains(index);

  int numberAt(int index) => shuffledNumbers[index];

  Color colorAt(int index) => heartColors[index];

  HiddenNumberBoardState reveal(int index) {
    if (revealedIndices.contains(index)) return this;
    return HiddenNumberBoardState(
      shuffledNumbers: shuffledNumbers,
      revealedIndices: {...revealedIndices, index},
      heartColors: heartColors,
    );
  }
}
