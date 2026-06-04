import 'package:flutter/material.dart';
import 'board_type.dart';

class BoardDefaults {
  BoardDefaults._();

  static const cellCount = 9;

  static const List<Color> colors = [
    Color(0xFF64B5F6),
    Color(0xFF8BC34A),
    Color(0xFFFFEB3B),
    Color(0xFF7B1FA2),
    Color(0xFFFFFFFF),
    Color(0xFFCE93D8),
    Color(0xFFF44336),
    Color(0xFFFF9800),
    Color(0xFF388E3C),
  ];

  /// カラー盤面の編集で選べる色
  static const List<Color> colorPickerPalette = [
    Color(0xFF64B5F6),
    Color(0xFF8BC34A),
    Color(0xFFFFEB3B),
    Color(0xFF7B1FA2),
    Color(0xFFFFFFFF),
    Color(0xFFCE93D8),
    Color(0xFFF44336),
    Color(0xFFFF9800),
    Color(0xFF388E3C),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
    Color(0xFF795548),
    Color(0xFF607D8B),
    Color(0xFF000000),
  ];

  static const List<String> numbers = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9',
  ];

  static const List<String> texts = [
    'ガム', 'ゴリラ', 'どんぐり',
    'オムライス', 'りんご', 'さんご',
    'かれーらいす', 'ぐらたん', 'たいこ',
  ];

  static const List<String> animals = [
    '🐢', '🐇', '🐈',
    '🐒', '🐘', '🐳',
    '🐷', '🐙', '🦐',
  ];

  static List<String> labelsFor(BoardType type) {
    switch (type) {
      case BoardType.color:
        return List.filled(cellCount, '');
      case BoardType.number:
        return List<String>.from(numbers);
      case BoardType.text:
        return List<String>.from(texts);
      case BoardType.animal:
        return List<String>.from(animals);
    }
  }

  static String storageKey(BoardType type, int index) {
    return 'board_${type.name}_$index';
  }

  static String colorStorageKey(int index) => 'board_color_$index';
}
