import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ksn_app/app_routes.dart';
import 'package:ksn_app/gojuon/models/word_data.dart';
import 'package:ksn_app/gojuon/pages/word_display_page.dart';
import 'package:ksn_app/karuta/karuta_game_screen.dart';
import 'package:ksn_app/main.dart';

void main() {
  test('normalize keeps game paths and falls back to home', () {
    expect(AppRoutes.normalize('/'), AppRoutes.home);
    expect(AppRoutes.normalize('/maru_batsu'), AppRoutes.maruBatsu);
    expect(AppRoutes.normalize('/sugoroku/'), AppRoutes.sugoroku);
    expect(AppRoutes.normalize('/karuta'), AppRoutes.karuta);
    expect(AppRoutes.normalize('/gojuon'), AppRoutes.gojuon);
    expect(AppRoutes.normalize('/unknown'), AppRoutes.home);
  });

  test(
    'yomifuda splits by bunsetsu into two columns and keeps chouon glyph',
    () {
      expect(verticalYomifudaChars('たったらたー'), ['た', 'っ', 'た', 'ら', 'た', 'ー']);
      expect(verticalYomifudaChars('たｰ'), ['た', 'ー']);
      expect(columnCharsFromPhrases(['ありさん', 'あいさつ']), [
        'あ',
        'り',
        'さ',
        'ん',
        '',
        'あ',
        'い',
        'さ',
        'つ',
      ]);

      final columns = splitYomifudaIntoTwoColumns('ありさん あいさつ あさがきた');
      final left = columns[0].where((c) => c.isNotEmpty).join();
      final right = columns[1].where((c) => c.isNotEmpty).join();
      // 文節をまたいで割れないこと
      expect('$right$left', 'ありさんあいさつあさがきた');
      expect(right, anyOf('ありさん', 'ありさんあいさつ'));
      expect(left.isNotEmpty, isTrue);
      // 同一列内の文節間にスペースが入ること
      expect(columns[0].contains('') || columns[1].contains(''), isTrue);
    },
  );

  testWidgets('home route shows the main menu', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('練習アプリ'), findsOneWidget);
    expect(find.text('すごろく'), findsOneWidget);
    expect(find.text('ことば表示アプリ'), findsOneWidget);
  });

  testWidgets('gojuon named route opens the 50-on table', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(routes: AppRoutes.table, initialRoute: AppRoutes.gojuon),
    );
    await tester.pumpAndSettle();
    expect(find.text('ことば表示アプリ'), findsWidgets);
    expect(find.text('強調枠をつける'), findsOneWidget);
    expect(find.text('丸をつける'), findsOneWidget);
    expect(find.text('ランダムに並べる'), findsOneWidget);
    expect(find.text('除外する音'), findsOneWidget);
    expect(find.byKey(const Key('exclude-sounds-field')), findsOneWidget);
    expect(find.text('決定'), findsOneWidget);
    expect(find.text('表示指定'), findsOneWidget);
    expect(find.text('指定なし'), findsOneWidget);
    expect(find.text('No.1〜5'), findsOneWidget);
    expect(find.text('No.1〜10'), findsOneWidget);
    expect(find.text('5語'), findsNothing);
    expect(find.text('10語'), findsNothing);
  });

  testWidgets('display spec limits to five items per kana after exclusions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WordDisplayPage(
          wordDataList: [
            for (var i = 1; i <= 8; i++)
              WordData(type: '単語', kana: 'あ', number: i, level1: '語$i'),
          ],
          selectedKanas: const ['あ'],
          selectedLevels: const ['レベル1'],
          includeShortText: false,
          displayFormat: 'リスト',
          displaySpec: 'No.1〜5',
          enableKanaColor: false,
          // 語2・語4 を除外しても、その音の後ろから補って5件にする
          excludedSounds: const ['2', '4'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('語1'), findsOneWidget);
    expect(find.text('語2'), findsNothing);
    expect(find.text('語3'), findsOneWidget);
    expect(find.text('語4'), findsNothing);
    expect(find.text('語5'), findsOneWidget);
    expect(find.text('語6'), findsOneWidget);
    expect(find.text('語7'), findsOneWidget);
    expect(find.text('語8'), findsNothing);
  });

  testWidgets(
    'display spec takes five items for each remaining kana after exclusion',
    (tester) async {
      tester.view.physicalSize = const Size(800, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: WordDisplayPage(
            wordDataList: [
              for (final kana in ['あ', 'い', 'う', 'え', 'お'])
                for (var i = 1; i <= 8; i++)
                  WordData(
                    type: '単語',
                    kana: kana,
                    number: i,
                    level1: '$kana$i',
                  ),
            ],
            selectedKanas: const ['あ', 'い', 'う', 'え', 'お'],
            selectedLevels: const ['レベル1'],
            includeShortText: false,
            displayFormat: 'リスト',
            displaySpec: 'No.1〜5',
            enableKanaColor: false,
            excludedSounds: const ['あ'],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // あ行は除外音で全滅し、い・う・え・おが各5語
      for (final kana in ['あ']) {
        for (var i = 1; i <= 8; i++) {
          expect(find.text('$kana$i'), findsNothing);
        }
      }
      for (final kana in ['い', 'う', 'え', 'お']) {
        for (var i = 1; i <= 5; i++) {
          expect(find.text('$kana$i'), findsOneWidget);
        }
        expect(find.text('${kana}6'), findsNothing);
      }
    },
  );

  testWidgets('gojuon settings does not use vertical scroll in landscape', (
    tester,
  ) async {
    // shortestSide >= 600 で wide レイアウト（FittedBox）になるサイズ
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(routes: AppRoutes.table, initialRoute: AppRoutes.gojuon),
    );
    await tester.pumpAndSettle();

    expect(find.text('強調枠をつける'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.vertical,
      ),
      findsNothing,
    );
  });

  testWidgets('gojuon compact layout keeps display CTA on narrow phones', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(routes: AppRoutes.table, initialRoute: AppRoutes.gojuon),
    );
    await tester.pumpAndSettle();

    expect(find.text('表示'), findsOneWidget);
    expect(find.text('強調枠をつける'), findsOneWidget);
    expect(find.byKey(const Key('exclude-sounds-field')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('game entry screens show a back button', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(routes: AppRoutes.table, initialRoute: AppRoutes.gojuon),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BackButtonIcon), findsOneWidget);
    expect(find.text('練習アプリ'), findsNothing);
  });

  testWidgets('sugoroku named route opens the game screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(routes: AppRoutes.table, initialRoute: AppRoutes.sugoroku),
    );
    await tester.pumpAndSettle();
    expect(find.text('すごろく'), findsWidgets);
    expect(find.text('ばんめんのながさをえらんでください'), findsOneWidget);
  });

  testWidgets('left tap frames a word and text tap adds a double circle', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WordDisplayPage(
          wordDataList: [
            WordData(type: '単語', kana: 'あ', number: 1, level1: 'あか'),
          ],
          selectedKanas: const ['あ'],
          selectedLevels: const ['レベル1'],
          includeShortText: false,
          displayFormat: 'リスト',
          enableKanaColor: false,
          enableBlueFrame: true,
          enableRedDoubleCircle: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('あか'), findsOneWidget);
    expect(find.byKey(const Key('word-blue-frame-0')), findsNothing);
    expect(find.byKey(const Key('word-double-circle-0')), findsNothing);
    expect(find.byKey(const Key('print-words-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('word-frame-toggle-0')));
    await tester.pump();
    expect(find.byKey(const Key('word-blue-frame-0')), findsOneWidget);

    await tester.tap(find.byKey(const Key('word-text-0')));
    await tester.pump();
    expect(find.byKey(const Key('word-double-circle-0')), findsOneWidget);
  });

  testWidgets('random order switch shuffles selected words', (tester) async {
    const originals = ['あか', 'あお', 'あき', 'あめ'];
    final expected = List<String>.from(originals)..shuffle(Random(1));

    await tester.pumpWidget(
      MaterialApp(
        home: WordDisplayPage(
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
          displayFormat: 'リスト',
          enableKanaColor: false,
          enableRandomOrder: true,
          random: Random(1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(expected, isNot(originals));
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

  testWidgets('excluded sounds drop matching words and short sentences', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WordDisplayPage(
          wordDataList: [
            WordData(type: '単語', kana: 'あ', number: 1, level1: 'あか'),
            WordData(type: '単語', kana: 'あ', number: 2, level1: 'あめ'),
            WordData(type: '短文', kana: 'あ', number: 1, level1: 'ドアを あける'),
          ],
          selectedKanas: const ['あ'],
          selectedLevels: const ['レベル1'],
          includeShortText: true,
          displayFormat: 'リスト',
          enableKanaColor: false,
          excludedSounds: const ['か', 'け'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('あめ'), findsOneWidget);
    expect(find.text('あか'), findsNothing);
    expect(find.text('ドアを あける'), findsNothing);
  });

  testWidgets('confirm locks field and clear restores input', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(routes: AppRoutes.table, initialRoute: AppRoutes.gojuon),
    );
    await tester.pumpAndSettle();

    final field = find.byKey(const Key('exclude-sounds-field'));
    await tester.enterText(find.byType(TextField).first, 'きabcく、！きゃ');
    await tester.tap(find.byKey(const Key('exclude-sounds-confirm')));
    await tester.pump();

    expect(find.text('き く きゃ'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('クリア'), findsOneWidget);
    expect(find.byKey(const Key('exclude-sounds-clear')), findsOneWidget);

    await tester.tap(find.byKey(const Key('exclude-sounds-clear')));
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );
    expect(find.text('決定'), findsOneWidget);
    expect(find.byKey(const Key('exclude-sounds-confirm')), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'さしす');
    await tester.tap(find.byKey(const Key('exclude-sounds-confirm')));
    await tester.pump();
    expect(find.text('さ し す'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('karuta game screen shows back control', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(routes: AppRoutes.table, initialRoute: AppRoutes.karuta),
    );
    await tester.pumpAndSettle();

    expect(find.text('4まい'), findsOneWidget);
    await tester.tap(find.text('4まい'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('あいうえお'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ゲーム開始'));
    await tester.pumpAndSettle();

    expect(find.textContaining('カルタ（'), findsOneWidget);
    expect(find.byKey(const Key('karuta-game-back')), findsOneWidget);
  });

  testWidgets('karuta selection shows back control for kyozai exit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(routes: AppRoutes.table, initialRoute: AppRoutes.karuta),
    );
    await tester.pumpAndSettle();

    if (find.text('なんまい あそぶ？').evaluate().isNotEmpty) {
      await tester.tap(find.text('4まい'));
      await tester.pumpAndSettle();
    }

    expect(find.byKey(const Key('karuta-selection-back')), findsOneWidget);
  });

  testWidgets('list view shows all selected words in one column', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: WordDisplayPage(
          wordDataList: [
            for (var i = 0; i < 6; i++)
              WordData(type: '単語', kana: 'あ', number: i + 1, level1: '語$i'),
          ],
          selectedKanas: const ['あ'],
          selectedLevels: const ['レベル1'],
          includeShortText: false,
          displayFormat: 'リスト',
          enableKanaColor: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('語0'), findsOneWidget);
    expect(find.text('語5'), findsOneWidget);
    expect(find.text('1 / 2'), findsNothing);
    expect(find.byKey(const Key('display-page-forward')), findsNothing);
  });
}
