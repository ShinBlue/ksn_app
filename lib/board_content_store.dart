import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'board_defaults.dart';
import 'board_type.dart';
import 'illustration_board_pattern.dart';
import 'illustration_defaults.dart';
import 'text_board_pattern.dart';

class BoardContentStore extends ChangeNotifier {
  BoardContentStore._();

  static final BoardContentStore instance = BoardContentStore._();

  final Map<BoardType, List<String>> _labels = {};
  final Map<TextBoardPattern, List<String>> _textPatternLabels = {};
  List<Color> _colors = List<Color>.from(BoardDefaults.colors);
  TextBoardPattern _textPattern = TextBoardPattern.pattern1;
  IllustrationBoardPattern _illustrationPattern = IllustrationBoardPattern.animal;

  List<String> labelsForTextPattern(TextBoardPattern pattern) {
    return List<String>.from(
      _textPatternLabels[pattern] ?? BoardDefaults.textPatternLabels(pattern),
    );
  }

  List<String> labels(BoardType type) {
    if (type == BoardType.text) {
      return labelsForTextPattern(_textPattern);
    }
    return List<String>.from(_labels[type] ?? BoardDefaults.labelsFor(type));
  }

  List<String> illustrationImages() =>
      IllustrationDefaults.imagesFor(_illustrationPattern);

  List<Color> colors() => List<Color>.from(_colors);

  TextBoardPattern get textPattern => _textPattern;

  IllustrationBoardPattern get illustrationPattern => _illustrationPattern;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final textPatternIndex = prefs.getInt(BoardDefaults.textPatternStorageKey);
    if (textPatternIndex != null &&
        textPatternIndex >= 0 &&
        textPatternIndex < TextBoardPattern.values.length) {
      _textPattern = TextBoardPattern.values[textPatternIndex];
    }

    final illustrationPatternIndex =
        prefs.getInt(IllustrationDefaults.illustrationPatternStorageKey);
    if (illustrationPatternIndex != null &&
        illustrationPatternIndex >= 0 &&
        illustrationPatternIndex < IllustrationBoardPattern.values.length) {
      _illustrationPattern =
          IllustrationBoardPattern.values[illustrationPatternIndex];
    }

    for (final type in BoardType.values) {
      if (type == BoardType.color ||
          type == BoardType.illustration ||
          type == BoardType.text) {
        continue;
      }
      _labels[type] = List.generate(BoardDefaults.cellCount, (i) {
        return prefs.getString(BoardDefaults.storageKey(type, i)) ??
            BoardDefaults.labelsFor(type)[i];
      });
    }

    for (final pattern in TextBoardPattern.values) {
      _textPatternLabels[pattern] = List.generate(BoardDefaults.cellCount, (i) {
        final patternKey = BoardDefaults.textPatternLabelStorageKey(pattern, i);
        final legacyKey = BoardDefaults.storageKey(BoardType.text, i);
        return prefs.getString(patternKey) ??
            (pattern == _textPattern ? prefs.getString(legacyKey) : null) ??
            BoardDefaults.textPatternLabels(pattern)[i];
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
    notifyListeners();
  }

  Future<void> saveTextPatternLabels(
    TextBoardPattern pattern,
    List<String> values,
  ) async {
    if (values.length != BoardDefaults.cellCount) return;
    final prefs = await SharedPreferences.getInstance();
    _textPatternLabels[pattern] = List<String>.from(values);
    for (var i = 0; i < values.length; i++) {
      await prefs.setString(
        BoardDefaults.textPatternLabelStorageKey(pattern, i),
        values[i],
      );
    }
    notifyListeners();
  }

  Future<void> resetTextPattern(TextBoardPattern pattern) async {
    final prefs = await SharedPreferences.getInstance();
    _textPatternLabels[pattern] =
        List<String>.from(BoardDefaults.textPatternLabels(pattern));
    for (var i = 0; i < BoardDefaults.cellCount; i++) {
      await prefs.remove(BoardDefaults.textPatternLabelStorageKey(pattern, i));
    }
    notifyListeners();
  }

  Future<void> applyIllustrationPattern(IllustrationBoardPattern pattern) async {
    _illustrationPattern = pattern;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      IllustrationDefaults.illustrationPatternStorageKey,
      pattern.index,
    );
    notifyListeners();
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
    } else if (type != BoardType.illustration) {
      _labels[type] = List<String>.from(BoardDefaults.labelsFor(type));
      for (var i = 0; i < BoardDefaults.cellCount; i++) {
        await prefs.remove(BoardDefaults.storageKey(type, i));
      }
    }
    notifyListeners();
  }
}
