import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ksn_app/app_routes.dart';
import 'package:ksn_app/main.dart';

void main() {
  test('normalize keeps game paths and falls back to home', () {
    expect(AppRoutes.normalize('/'), AppRoutes.home);
    expect(AppRoutes.normalize('/maru_batsu'), AppRoutes.maruBatsu);
    expect(AppRoutes.normalize('/sugoroku/'), AppRoutes.sugoroku);
    expect(AppRoutes.normalize('/karuta'), AppRoutes.karuta);
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
}
