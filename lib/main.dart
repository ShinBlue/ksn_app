import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'analytics_service.dart';
import 'app_routes.dart';
import 'board_content_store.dart';
import 'main_menu_screen.dart';
import 'sugoroku/sugoroku_board_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await BoardContentStore.instance.load();
  await SugorokuBoardStore.instance.load();
  await AnalyticsService.instance.init();
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
      routes: AppRoutes.table,
      onGenerateRoute: (settings) {
        final name = AppRoutes.normalize(settings.name);
        final builder = AppRoutes.table[name]!;
        return MaterialPageRoute<void>(
          settings: RouteSettings(name: name, arguments: settings.arguments),
          builder: builder,
        );
      },
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.home),
        builder: (_) => const MainMenuScreen(),
      ),
    );
  }
}
