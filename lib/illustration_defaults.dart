import 'package:flutter/material.dart';

import 'illustration_board_pattern.dart';

class IllustrationDefaults {
  IllustrationDefaults._();

  static const illustrationPatternStorageKey = 'board_illustration_pattern';

  // macOS上の実ファイル名（NFD）に合わせたパス
  static const List<String> animalImages = [
    'assets/images/動物/うさぎ.jpg',
    'assets/images/動物/さる.jpg',
    'assets/images/動物/ねこ.jpg',
    'assets/images/動物/ゴリラ.jpg',
    'assets/images/動物/コアラ.jpg',
    'assets/images/動物/パンダ.jpg',
    'assets/images/動物/ペンギン.jpg',
    'assets/images/動物/ライオン.jpg',
    'assets/images/動物/犬.jpg',
  ];

  static const List<String> fruitImages = [
    'assets/images/果物/ぶどう.jpg',
    'assets/images/果物/みかん.jpg',
    'assets/images/果物/りんご.jpg',
    'assets/images/果物/イチゴ.jpg',
    'assets/images/果物/キウイ.jpg',
    'assets/images/果物/バナナ.jpg',
    'assets/images/果物/パイナップル.jpg',
    'assets/images/果物/モモ.jpg',
    'assets/images/果物/レモン.jpg',
  ];

  static const List<String> vehicleImages = [
    'assets/images/乗り物/トラック.jpg',
    'assets/images/乗り物/バス.jpg',
    'assets/images/乗り物/パトカー.jpg',
    'assets/images/乗り物/ブルドーザー.jpg',
    'assets/images/乗り物/新幹線.jpg',
    'assets/images/乗り物/自転車.jpg',
    'assets/images/乗り物/船.jpg',
    'assets/images/乗り物/車.jpg',
    'assets/images/乗り物/飛行機.jpg',
  ];

  static const List<String> foodImages = [
    'assets/images/食べ物/うどん.jpg',
    'assets/images/食べ物/おにぎり.jpg',
    'assets/images/食べ物/オムライス.jpg',
    'assets/images/食べ物/カレー.jpg',
    'assets/images/食べ物/ケーキ.jpg',
    'assets/images/食べ物/パスタ.jpg',
    'assets/images/食べ物/パンケーキ.jpg',
    'assets/images/食べ物/ハンバーガー.jpg',
    'assets/images/食べ物/ラーメン.jpg',
  ];

  static String patternName(IllustrationBoardPattern pattern) {
    switch (pattern) {
      case IllustrationBoardPattern.animal:
        return '動物';
      case IllustrationBoardPattern.fruit:
        return '果物';
      case IllustrationBoardPattern.vehicle:
        return '乗り物';
      case IllustrationBoardPattern.food:
        return '食べ物';
    }
  }

  static List<String> imagesFor(IllustrationBoardPattern pattern) {
    switch (pattern) {
      case IllustrationBoardPattern.animal:
        return List<String>.from(animalImages);
      case IllustrationBoardPattern.fruit:
        return List<String>.from(fruitImages);
      case IllustrationBoardPattern.vehicle:
        return List<String>.from(vehicleImages);
      case IllustrationBoardPattern.food:
        return List<String>.from(foodImages);
    }
  }

  static const List<Color> patternPastelFills = [
    Color(0xFFE1F5FE),
    Color(0xFFFFF3E0),
    Color(0xFFF3E5F5),
    Color(0xFFFFFDE7),
  ];

  static const List<Color> patternPastelBorders = [
    Color(0xFF81D4FA),
    Color(0xFFFFCC80),
    Color(0xFFCE93D8),
    Color(0xFFFFF176),
  ];

  static const List<Color> patternPastelAccents = [
    Color(0xFF039BE5),
    Color(0xFFFB8C00),
    Color(0xFF8E24AA),
    Color(0xFFF9A825),
  ];
}
