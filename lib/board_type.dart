enum BoardType { color, number, text, animal }

extension BoardTypeExtension on BoardType {
  String get label {
    switch (this) {
      case BoardType.color:
        return 'カラー盤面';
      case BoardType.number:
        return '数字盤面';
      case BoardType.text:
        return 'テキスト盤面';
      case BoardType.animal:
        return '動物盤面';
    }
  }

  bool get usesLabels => this != BoardType.color;
}
