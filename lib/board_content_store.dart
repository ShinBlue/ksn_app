import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'board_defaults.dart';
import 'board_type.dart';
import 'text_board_pattern.dart';

class BoardContentStore extends ChangeNotifier {
  BoardContentStore._();

  static final BoardContentStore instance = BoardContentStore._();

  final Map<BoardType, List<String>> _labels = {};
  List<Color> _colors = List<Color>.from(BoardDefaults.colors);
  TextBoardPattern _textPattern = TextBoardPattern.pattern4;

  List<String> labels(BoardType type) {
    if (type == BoardType.text) {
      return List<String>.from(
        _labels[type] ?? BoardDefaults.textPatternLabels(_textPattern),
      );
    }
    return List<String>.from(_labels[type] ?? BoardDefaults.labelsFor(type));
  }

  List<Color> colors() => List<Color>.from(_colors);

  TextBoardPattern get textPattern => _textPattern;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final patternIndex = prefs.getInt(BoardDefaults.textPatternStorageKey);
    if (patternIndex != null &&
        patternIndex >= 0 &&
        patternIndex < TextBoardPattern.values.length) {
      _textPattern = TextBoardPattern.values[patternIndex];
    }
    for (final type in BoardType.values) {
      if (type == BoardType.color) continue;
      _labels[type] = List.generate(BoardDefaults.cellCount, (i) {
        final fallback = type == BoardType.text
            ? BoardDefaults.textPatternLabels(_textPattern)[i]
            : BoardDefaults.labelsFor(type)[i];
        return prefs.getString(BoardDefaults.storageKey(type, i)) ?? fallback;
      });
    }
    _colors = List.generate(BoardDefaults.cellCount, (i) {
      final value = prefs.getInt(BoardDefaults.colorStorageKey(i));
      return value != null ? Color(value) : BoardDefaults.colors[i];
    });
    notifyListeners();
  }

  Future<void> saveLabels(BoardType type, List<String> values) async {
    if (values.length != BoardDefaults.cellCount) return;
    final prefs = await SharedPreferences.getInstance();
    _labels[type] = List<String>.from(values);
    for (var i = 0; i < values.length; i++) {
      await prefs.setString(BoardDefaults.storageKey(type, i), values[i]);
    }
    notifyListeners();
  }

  Future<void> applyTextPattern(TextBoardPattern pattern) async {
    _textPattern = pattern;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(BoardDefaults.textPatternStorageKey, pattern.index);
    await saveLabels(BoardType.text, BoardDefaults.textPatternLabels(pattern));
  }

  Future<void> saveColors(List<Color> values) async {
    if (values.length != BoardDefaults.cellCount) return;
    final prefs = await SharedPreferences.getInstance();
    _colors = List<Color>.from(values);
    for (var i = 0; i < values.length; i++) {
      await prefs.setInt(BoardDefaults.colorStorageKey(i), values[i].toARGB32());
    }
    notifyListeners();
  }

  Future<void> reset(BoardType type) async {
    final prefs = await SharedPreferences.getInstance();
    if (type == BoardType.color) {
      _colors = List<Color>.from(BoardDefaults.colors);
      for (var i = 0; i < BoardDefaults.cellCount; i++) {
        await prefs.remove(BoardDefaults.colorStorageKey(i));
      }
    } else if (type == BoardType.text) {
      _labels[type] = List<String>.from(BoardDefaults.textPatternLabels(_textPattern));
      for (var i = 0; i < BoardDefaults.cellCount; i++) {
        await prefs.remove(BoardDefaults.storageKey(type, i));
      }
    } else {
      _labels[type] = List<String>.from(BoardDefaults.labelsFor(type));
      for (var i = 0; i < BoardDefaults.cellCount; i++) {
        await prefs.remove(BoardDefaults.storageKey(type, i));
      }
    }
    notifyListeners();
  }
}
