import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'board_defaults.dart';
import 'board_type.dart';

class BoardContentStore extends ChangeNotifier {
  BoardContentStore._();

  static final BoardContentStore instance = BoardContentStore._();

  final Map<BoardType, List<String>> _labels = {};
  List<Color> _colors = List<Color>.from(BoardDefaults.colors);

  List<String> labels(BoardType type) =>
      List<String>.from(_labels[type] ?? BoardDefaults.labelsFor(type));

  List<Color> colors() => List<Color>.from(_colors);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    for (final type in BoardType.values) {
      if (type == BoardType.color) continue;
      _labels[type] = List.generate(BoardDefaults.cellCount, (i) {
        return prefs.getString(BoardDefaults.storageKey(type, i)) ??
            BoardDefaults.labelsFor(type)[i];
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
    } else {
      _labels[type] = List<String>.from(BoardDefaults.labelsFor(type));
      for (var i = 0; i < BoardDefaults.cellCount; i++) {
        await prefs.remove(BoardDefaults.storageKey(type, i));
      }
    }
    notifyListeners();
  }
}
