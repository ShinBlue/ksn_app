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
      MaterialApp(
        routes: AppRoutes.table,
        initialRoute: AppRoutes.gojuon,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('ことば表示アプリ'), findsWidgets);
    expect(find.text('青い枠'), findsOneWidget);
    expect(find.text('赤い二重丸'), findsOneWidget);
  });

  testWidgets('gojuon settings does not use vertical scroll in landscape', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.table,
        initialRoute: AppRoutes.gojuon,
      ),
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

  testWidgets('sugoroku named route opens the game screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.table,
        initialRoute: AppRoutes.sugoroku,
      ),
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
}
