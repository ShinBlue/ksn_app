import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ksn_app/gojuon/models/word_data.dart';
import 'package:ksn_app/gojuon/pages/word_display_page.dart';
import 'package:ksn_app/gojuon/pages/word_select_page.dart';

void main() {
  WordSelectPage buildSelectPage({
    List<String> words = const ['あか', 'あお', 'あき'],
    bool enableRandomOrder = false,
    Random? random,
    List<String> selectedLevels = const ['レベル1'],
    bool includeShortText = false,
    List<WordData>? wordDataList,
  }) {
    return WordSelectPage(
      wordDataList:
          wordDataList ??
          [
            for (var i = 0; i < words.length; i++)
              WordData(type: '単語', kana: 'あ', number: i + 1, level1: words[i]),
          ],
      selectedKanas: const ['あ'],
      selectedLevels: selectedLevels,
      includeShortText: includeShortText,
      displayFormat: 'リスト',
      enableKanaColor: false,
      enableRandomOrder: enableRandomOrder,
      random: random,
    );
  }

  testWidgets('candidates start unchecked and select-all enables display', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: buildSelectPage()));
    await tester.pumpAndSettle();

    expect(find.text('候補 0 / 3'), findsOneWidget);
    expect(find.text('あか'), findsOneWidget);
    expect(find.text('あお'), findsOneWidget);
    expect(find.text('あき'), findsOneWidget);

    final displayButton = tester.widget<FilledButton>(
      find.byKey(const Key('word-select-display')),
    );
    expect(displayButton.onPressed, isNull);

    await tester.tap(find.byKey(const Key('word-select-all')));
    await tester.pumpAndSettle();
    expect(find.text('候補 3 / 3'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('word-select-display')))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('display opens only selected words', (tester) async {
    await tester.pumpWidget(MaterialApp(home: buildSelectPage()));
    await tester.pumpAndSettle();

    // モーラ同数なら五十音順: あお, あか, あき
    await tester.tap(find.byKey(const Key('word-select-item-0')));
    await tester.pumpAndSettle();
    expect(find.text('候補 1 / 3'), findsOneWidget);

    await tester.tap(find.byKey(const Key('word-select-display')));
    await tester.pumpAndSettle();

    expect(find.byType(WordDisplayPage), findsOneWidget);
    expect(find.text('あお'), findsOneWidget);
    expect(find.text('あか'), findsNothing);
    expect(find.text('あき'), findsNothing);
  });

  testWidgets('shows level and sentence columns sorted by mora count', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: buildSelectPage(
          selectedLevels: const ['レベル1', 'レベル2'],
          includeShortText: true,
          wordDataList: [
            WordData(
              type: '単語',
              kana: 'あ',
              number: 1,
              level1: 'あか',
              level2: 'ドア',
            ),
            WordData(
              type: '単語',
              kana: 'あ',
              number: 2,
              level1: 'あいさつ',
              level2: 'ペア',
            ),
            WordData(type: '短文', kana: 'あ', number: 1, level1: 'ドアを あける'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('レベル1'), findsOneWidget);
    expect(find.text('レベル2'), findsOneWidget);
    expect(find.text('文'), findsOneWidget);
    expect(find.textContaining('モーラ'), findsNothing);

    // レベル1: あか(2) → あいさつ(4)
    expect(
      find.descendant(
        of: find.byKey(const Key('word-select-item-0')),
        matching: find.text('あか'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('word-select-item-1')),
        matching: find.text('あいさつ'),
      ),
      findsOneWidget,
    );
    // レベル2: ドア(2), ペア(2) → 五十音で ドア, ペア
    expect(
      find.descendant(
        of: find.byKey(const Key('word-select-item-2')),
        matching: find.text('ドア'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('word-select-item-3')),
        matching: find.text('ペア'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('word-select-item-4')),
        matching: find.text('ドアを あける'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('random order shuffles only when opening display', (
    tester,
  ) async {
    const originals = ['あか', 'あお', 'あき', 'あめ'];
    // 候補はモーラ同数のため五十音順に並ぶ
    const sortedForSelect = ['あお', 'あか', 'あき', 'あめ'];
    final expected = List<String>.from(sortedForSelect)..shuffle(Random(1));

    await tester.pumpWidget(
      MaterialApp(
        home: buildSelectPage(
          words: originals,
          enableRandomOrder: true,
          random: Random(1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < sortedForSelect.length; i++) {
      expect(
        find.descendant(
          of: find.byKey(Key('word-select-item-$i')),
          matching: find.text(sortedForSelect[i]),
        ),
        findsOneWidget,
      );
    }

    await tester.tap(find.byKey(const Key('word-select-all')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('word-select-display')));
    await tester.pumpAndSettle();

    expect(expected, isNot(sortedForSelect));
    for (var i = 0; i < expected.length; i++) {
      expect(
        find.descendant(
          of: find.byKey(Key('word-text-$i')),
          matching: find.text(expected[i]),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('back returns to previous screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => buildSelectPage()),
                );
              },
              child: const Text('open-select'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open-select'));
    await tester.pumpAndSettle();
    expect(find.text('あか'), findsOneWidget);

    await tester.tap(find.byKey(const Key('word-select-back')));
    await tester.pumpAndSettle();
    expect(find.text('open-select'), findsOneWidget);
    expect(find.text('あか'), findsNothing);
  });
}
