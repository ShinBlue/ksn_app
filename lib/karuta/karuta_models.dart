enum KarutaLayoutMode {
  aligned('整列'),
  scatter('ランダム');

  final String label;
  const KarutaLayoutMode(this.label);
}

class KarutaCard {
  final String character;
  final String imagePath;
  final String? sentence;

  const KarutaCard({
    required this.character,
    required this.imagePath,
    this.sentence,
  });
}

class KarutaRow {
  final String label;
  final List<String> characters;
  /// 5マス表内の表示位置（0〜4）。省略時は左から詰める。
  final List<int>? characterSlots;

  const KarutaRow({
    required this.label,
    required this.characters,
    this.characterSlots,
  });
}

/// 50音表の1表示行（清音＋濁音のペア、または単独行）
class KarutaDisplayLine {
  final List<KarutaRow> rows;
  final bool alignToSecondaryColumn;

  const KarutaDisplayLine({
    required this.rows,
    this.alignToSecondaryColumn = false,
  });
}
