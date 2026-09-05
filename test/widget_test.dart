import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ksn_app/app_routes.dart';
import 'package:ksn_app/gojuon/models/word_data.dart';
import 'package:ksn_app/gojuon/pages/word_display_page.dart';
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
    expect(find.text('青い枠'), findsOneWidget);
    expect(find.text('赤い二重丸'), findsOneWidget);
    expect(find.text('ランダムに並べる'), findsOneWidget);
    expect(find.text('除外する音'), findsOneWidget);
    expect(find.byKey(const Key('exclude-sounds-field')), findsOneWidget);
    expect(find.text('決定'), findsOneWidget);
  });

  testWidgets('gojuon settings does not use vertical scroll in landscape', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(routes: AppRoutes.table, initialRoute: AppRoutes.gojuon),
    );
    await tester.pumpAndSettle();

    expect(find.text('青い枠'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.vertical,
      ),
      findsNothing,
    );
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

    await tester.tap(find.byKey(const Key('word-left-0')));
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

  testWidgets('confirm keeps only meaningful excluded sounds', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(routes: AppRoutes.table, initialRoute: AppRoutes.gojuon),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('exclude-sounds-field')),
      'きabcく、！きゃ',
    );
    await tester.tap(find.byKey(const Key('exclude-sounds-confirm')));
    await tester.pump();

    final field = find.byKey(const Key('exclude-sounds-field'));
    var textField = tester.widget<TextField>(field);
    expect(textField.controller?.text, 'き く きゃ');
    expect(textField.style?.fontWeight, FontWeight.bold);

    await tester.tap(field);
    await tester.pump();

    textField = tester.widget<TextField>(field);
    expect(textField.controller?.text, isEmpty);
    expect(textField.style?.fontWeight, FontWeight.normal);
  });
}
