import '../excluded_sounds.dart';
import '../models/display_item.dart';
import '../models/word_data.dart';

/// 表示指定のラベルから、音ごとの件数上限を返す。指定なしは null。
/// 除外音で落ちた分は、その音の後ろの候補から補う。
int? itemLimitForDisplaySpec(String displaySpec) {
  switch (displaySpec) {
    case 'No.1〜5':
    case '1〜5': // 旧ラベル互換
      return 5;
    case 'No.1〜10':
    case '1〜10': // 旧ラベル互換
      return 10;
    default:
      return null;
  }
}

/// 設定条件から表示候補を組み立てる。シャッフルはしない。
List<DisplayItem> buildDisplayItems({
  required List<WordData> wordDataList,
  required List<String> selectedKanas,
  required List<String> selectedLevels,
  required bool includeShortText,
  String displaySpec = '指定なし',
  List<String> excludedSounds = const [],
}) {
  final List<DisplayItem> items = [];
  final itemLimit = itemLimitForDisplaySpec(displaySpec);

  for (final kana in selectedKanas) {
    final kanaItems = <DisplayItem>[];

    for (final wordData in wordDataList) {
      if (wordData.kana != kana) {
        continue;
      }

      if (wordData.type == '短文') {
        if (includeShortText) {
          if (wordData.level1 != null && wordData.level1!.isNotEmpty) {
            _addIfAllowed(
              kanaItems,
              wordData.level1!,
              excludedSounds: excludedSounds,
              isShortSentence: true,
              level: null,
            );
          }
        }
        continue;
      }

      if (wordData.type == '単語') {
        if (selectedLevels.contains('レベル1')) {
          if (wordData.level1 != null && wordData.level1!.isNotEmpty) {
            _addIfAllowed(
              kanaItems,
              wordData.level1!,
              excludedSounds: excludedSounds,
              isShortSentence: false,
              level: 1,
            );
          }
        }
        if (selectedLevels.contains('レベル2')) {
          if (wordData.level2 != null && wordData.level2!.isNotEmpty) {
            _addIfAllowed(
              kanaItems,
              wordData.level2!,
              excludedSounds: excludedSounds,
              isShortSentence: false,
              level: 2,
            );
          }
        }
        if (selectedLevels.contains('レベル3')) {
          if (wordData.level3 != null && wordData.level3!.isNotEmpty) {
            _addIfAllowed(
              kanaItems,
              wordData.level3!,
              excludedSounds: excludedSounds,
              isShortSentence: false,
              level: 3,
            );
          }
        }
      }
    }

    if (itemLimit == null) {
      items.addAll(kanaItems);
    } else {
      items.addAll(kanaItems.take(itemLimit));
    }
  }

  return items;
}

/// 候補をレベル順・モーラ数順に並べ替える。
List<DisplayItem> sortDisplayItemsForSelection(List<DisplayItem> items) {
  final sorted = List<DisplayItem>.from(items);
  sorted.sort((a, b) {
    final levelCmp = _levelRank(a).compareTo(_levelRank(b));
    if (levelCmp != 0) return levelCmp;
    final moraCmp = a.moraCount.compareTo(b.moraCount);
    if (moraCmp != 0) return moraCmp;
    return a.text.compareTo(b.text);
  });
  return sorted;
}

int _levelRank(DisplayItem item) {
  if (item.isShortSentence) return 4;
  return item.level ?? 4;
}

void _addIfAllowed(
  List<DisplayItem> items,
  String text, {
  required List<String> excludedSounds,
  required bool isShortSentence,
  required int? level,
}) {
  if (ExcludedSounds.containsAny(text, excludedSounds)) {
    return;
  }
  items.add(
    DisplayItem(
      text: text,
      isShortSentence: isShortSentence,
      level: level,
    ),
  );
}
