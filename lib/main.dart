import 'package:flutter/material.dart';
import 'analytics_service.dart';
import 'board_content_store.dart';
import 'main_menu_screen.dart';
import 'sugoroku/sugoroku_board_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BoardContentStore.instance.load();
  await SugorokuBoardStore.instance.load();
  await AnalyticsService.instance.init();
  await AnalyticsService.instance.logScreen(AnalyticsRoutes.mainMenu);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final observer = AnalyticsService.instance.observer;
    return MaterialApp(
      title: 'ことばサポートネット練習アプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5BAD5B)),
      ),
      navigatorObservers: observer != null ? [observer] : const [],
      home: const MainMenuScreen(),
    );
  }
}
