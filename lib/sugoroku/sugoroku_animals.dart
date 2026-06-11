import 'sugoroku_models.dart';

abstract final class SugorokuAnimals {
  static const boardImage20 = 'assets/images/盤面/動物盤面.png';

  /// 20マス盤の動物（画像上 4列×5行、左上から右へ）
  static const all20 = [
    AnimalSpot(index: 0, name: 'ぶた'),
    AnimalSpot(index: 1, name: 'たぬき'),
    AnimalSpot(index: 2, name: 'こあら'),
    AnimalSpot(index: 3, name: 'やぎ'),
    AnimalSpot(index: 4, name: 'からす'),
    AnimalSpot(index: 5, name: 'かば'),
    AnimalSpot(index: 6, name: 'うま'),
    AnimalSpot(index: 7, name: 'こうもり'),
    AnimalSpot(index: 8, name: 'ぱんだ'),
    AnimalSpot(index: 9, name: 'さる'),
    AnimalSpot(index: 10, name: 'らいおん'),
    AnimalSpot(index: 11, name: 'うさぎ'),
    AnimalSpot(index: 12, name: 'ぞう'),
    AnimalSpot(index: 13, name: 'ごりら'),
    AnimalSpot(index: 14, name: 'うし'),
    AnimalSpot(index: 15, name: 'ひつじ'),
    AnimalSpot(index: 16, name: 'しまうま'),
    AnimalSpot(index: 17, name: 'いのしし'),
    AnimalSpot(index: 18, name: 'ねこ'),
    AnimalSpot(index: 19, name: 'なまけもの'),
  ];

  /// 10マス盤の動物（2列×5行、別デザインのカード用）
  static List<AnimalSpot> get all10 =>
      all20.take(10).toList(growable: false);

  static List<AnimalSpot> forSize(SugorokuBoardSize size) =>
      size == SugorokuBoardSize.short10 ? all10 : all20;

  /// 個別イラストがある動物（10マスカード表示用）
  static const imageByName = {
    'うさぎ': 'assets/images/動物/うさぎ.jpg',
    'さる': 'assets/images/動物/さる.jpg',
    'ねこ': 'assets/images/動物/ねこ.jpg',
    'ごりら': 'assets/images/動物/ゴリラ.jpg',
    'こあら': 'assets/images/動物/コアラ.jpg',
    'ぱんだ': 'assets/images/動物/パンダ.jpg',
    'らいおん': 'assets/images/動物/ライオン.jpg',
  };
}
