import 'package:flutter_test/flutter_test.dart';
import 'package:ksn_app/gojuon/models/word_data.dart';
import 'package:ksn_app/gojuon/utils/display_items_builder.dart';

void main() {
  test('display spec limits to five items per kana after exclusions', () {
    final items = buildDisplayItems(
      wordDataList: [
        for (var i = 1; i <= 8; i++)
          WordData(type: '単語', kana: 'あ', number: i, level1: '語$i'),
      ],
      selectedKanas: const ['あ'],
      selectedLevels: const ['レベル1'],
      includeShortText: false,
      displaySpec: 'No.1〜5',
      // 語2・語4 を除外しても、その音の後ろから補って5件にする
      excludedSounds: const ['2', '4'],
    );

    expect(items.map((e) => e.text).toList(), [
      '語1',
      '語3',
      '語5',
      '語6',
      '語7',
    ]);
  });

  test(
    'display spec takes five items for each remaining kana after exclusion',
    () {
      final items = buildDisplayItems(
        wordDataList: [
          for (final kana in ['あ', 'い', 'う', 'え', 'お'])
            for (var i = 1; i <= 8; i++)
              WordData(type: '単語', kana: kana, number: i, level1: '$kana$i'),
        ],
        selectedKanas: const ['あ', 'い', 'う', 'え', 'お'],
        selectedLevels: const ['レベル1'],
        includeShortText: false,
        displaySpec: 'No.1〜5',
        excludedSounds: const ['あ'],
      );

      expect(items.where((e) => e.text.startsWith('あ')), isEmpty);
      for (final kana in ['い', 'う', 'え', 'お']) {
        final texts = items
            .where((e) => e.text.startsWith(kana))
            .map((e) => e.text)
            .toList();
        expect(texts, [
          for (var i = 1; i <= 5; i++) '$kana$i',
        ]);
      }
    },
  );

  test('excluded sounds drop matching words and short sentences', () {
    final items = buildDisplayItems(
      wordDataList: [
        WordData(type: '単語', kana: 'あ', number: 1, level1: 'あか'),
        WordData(type: '単語', kana: 'あ', number: 2, level1: 'あめ'),
        WordData(type: '短文', kana: 'あ', number: 1, level1: 'ドアを あける'),
      ],
      selectedKanas: const ['あ'],
      selectedLevels: const ['レベル1'],
      includeShortText: true,
      excludedSounds: const ['か', 'け'],
    );

    expect(items.map((e) => e.text).toList(), ['あめ']);
  });

  test('buildDisplayItems does not shuffle', () {
    final originals = ['あか', 'あお', 'あき', 'あめ'];
    final items = buildDisplayItems(
      wordDataList: [
        for (var i = 0; i < originals.length; i++)
          WordData(
            type: '単語',
            kana: 'あ',
            number: i + 1,
            level1: originals[i],
          ),
      ],
      selectedKanas: const ['あ'],
      selectedLevels: const ['レベル1'],
      includeShortText: false,
    );

    expect(items.map((e) => e.text).toList(), originals);
  });
}
