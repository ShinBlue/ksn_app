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
}
