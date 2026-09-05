class WordData {
  final String type; // 種類（単語/短文）
  final String kana; // 音
  final int number; // 番号
  final String? level1; // レベル1
  final String? level2; // レベル2
  final String? level3; // レベル3

  WordData({
    required this.type,
    required this.kana,
    required this.number,
    this.level1,
    this.level2,
    this.level3,
  });

  /// ヘッダー付きCSVを読む。空行は無視し、列が足りない行は飛ばす。
  static List<WordData> parseCsv(String csvString) {
    var normalized = csvString.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    if (normalized.startsWith('\uFEFF')) {
      normalized = normalized.substring(1);
    }

    final rows = <List<String>>[];
    for (final line in normalized.split('\n')) {
      if (line.trim().isEmpty) continue;
      rows.add(line.split(',').map(_unquoteCell).toList());
    }

    final loaded = <WordData>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 6) continue;

      final type = row[0];
      final kana = row[1];
      if (type.isEmpty || kana.isEmpty) continue;

      final level1 = row[3];
      final level2 = row[4];
      final level3 = row[5];

      loaded.add(
        WordData(
          type: type,
          kana: kana,
          number: int.tryParse(row[2]) ?? 0,
          level1: level1.isEmpty ? null : level1,
          level2: level2.isEmpty ? null : level2,
          level3: level3.isEmpty ? null : level3,
        ),
      );
    }
    return loaded;
  }

  static String _unquoteCell(String cell) {
    var value = cell.trim();
    if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
      value = value.substring(1, value.length - 1).replaceAll('""', '"');
    }
    return value.trim();
  }

  @override
  bool operator ==(Object other) {
    return other is WordData &&
        other.type == type &&
        other.kana == kana &&
        other.number == number &&
        other.level1 == level1 &&
        other.level2 == level2 &&
        other.level3 == level3;
  }

  @override
  int get hashCode => Object.hash(type, kana, number, level1, level2, level3);
}
