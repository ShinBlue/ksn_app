import 'package:flutter/material.dart';
import 'board_type.dart';
import 'text_board_pattern.dart';

class BoardDefaults {
  BoardDefaults._();

  static const cellCount = 9;

  static const boardScale = 1.25;
  static const boardMinSize = 225.0;
  static const boardMaxSize = 500.0;
  static const previewSizeHome = 100.0;
  static const previewSizePattern = 90.0;
  static const boardEditMaxWidth = 600.0;

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

  static const List<String> textPattern1 = [
    'かめ', 'くるま', 'きのこ',
    'げた', 'ごりら', 'てがみ',
    'おにぎり', 'いけ', 'もぐら',
  ];

  static const List<String> textPattern2 = [
    'すずめ', 'けしごむ', 'はやぶさ',
    'かたつむり', 'ちらしずし', 'じてんしゃ',
    'りょうり', 'さんどいっち', 'とうもろこし',
  ];

  static const List<String> textPattern3 = [
    'まめ', 'ぱん', 'こっぷ',
    'ろば', 'うま', 'ぶた',
    'めがね', 'みかん', 'たんぽぽ',
  ];

  static const textPatternStorageKey = 'board_text_pattern';

  static String textPatternName(TextBoardPattern pattern) {
    return 'パターン${pattern.index + 1}';
  }

  /// パターン選択画面用のパステルカラー
  static const List<Color> textPatternPastelFills = [
    Color(0xFFE3F2FD),
    Color(0xFFE8F5E9),
    Color(0xFFFFF8E1),
    Color(0xFFFCE4EC),
  ];

  static const List<Color> textPatternPastelBorders = [
    Color(0xFF90CAF9),
    Color(0xFFA5D6A7),
    Color(0xFFFFE082),
    Color(0xFFF48FB1),
  ];

  static const List<Color> textPatternPastelAccents = [
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFFFCA28),
    Color(0xFFEC407A),
  ];

  static List<String> textPatternLabels(TextBoardPattern pattern) {
    switch (pattern) {
      case TextBoardPattern.pattern1:
        return List<String>.from(textPattern1);
      case TextBoardPattern.pattern2:
        return List<String>.from(textPattern2);
      case TextBoardPattern.pattern3:
        return List<String>.from(textPattern3);
      case TextBoardPattern.pattern4:
        return List<String>.from(texts);
    }
  }

  static List<String> labelsFor(BoardType type) {
    switch (type) {
      case BoardType.color:
        return List.filled(cellCount, '');
      case BoardType.number:
        return List<String>.from(numbers);
      case BoardType.text:
        return List<String>.from(textPattern1);
      case BoardType.illustration:
        return List.filled(cellCount, '');
    }
  }

  static String storageKey(BoardType type, int index) {
    return 'board_${type.name}_$index';
  }

  static String colorStorageKey(int index) => 'board_color_$index';
}
