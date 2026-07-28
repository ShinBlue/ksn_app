import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sugoroku_models.dart';

const sugorokuSavedBoardsMax = 10;
const _storageKey = 'sugoroku_saved_boards';

class SugorokuSavedBoard {
  final String id;
  final String title;
  final SugorokuBoardSize size;
  final List<String> labels;
  final DateTime savedAt;

  const SugorokuSavedBoard({
    required this.id,
    required this.title,
    required this.size,
    required this.labels,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'size': size.name,
        'labels': labels,
        'savedAt': savedAt.toIso8601String(),
      };

  static SugorokuSavedBoard fromJson(Map<String, dynamic> json) {
    return SugorokuSavedBoard(
      id: json['id'] as String,
      title: json['title'] as String,
      size: SugorokuBoardSize.values.firstWhere(
        (s) => s.name == json['size'],
      ),
      labels: List<String>.from(json['labels'] as List),
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }
}

/// すごろく盤面（マスのことば＋タイトル）をローカルに保存・呼び出しするストア。
/// 保存できる盤面は最大 [sugorokuSavedBoardsMax] 件まで。
class SugorokuBoardStore extends ChangeNotifier {
  SugorokuBoardStore._();

  static final instance = SugorokuBoardStore._();

  List<SugorokuSavedBoard> _boards = [];

  List<SugorokuSavedBoard> get boards => List.unmodifiable(_boards);

  bool get isFull => _boards.length >= sugorokuSavedBoardsMax;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _boards = list
          .map((e) => SugorokuSavedBoard.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_boards.map((b) => b.toJson()).toList()),
    );
  }

  /// 保存に成功したら true。すでに [sugorokuSavedBoardsMax] 件保存されている場合は
  /// 何もせず false を返す（呼び出し側で削除を促す）。
  Future<bool> save({
    required String title,
    required SugorokuBoardSize size,
    required List<String> labels,
  }) async {
    if (isFull) return false;
    _boards.add(
      SugorokuSavedBoard(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        size: size,
        labels: labels,
        savedAt: DateTime.now(),
      ),
    );
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> delete(String id) async {
    _boards.removeWhere((b) => b.id == id);
    await _persist();
    notifyListeners();
  }
}
