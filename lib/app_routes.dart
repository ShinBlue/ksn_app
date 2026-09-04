import 'package:flutter/material.dart';

import 'gojuon/pages/gojuon_table_page.dart';
import 'home_screen.dart';
import 'karuta/karuta_selection_screen.dart';
import 'main_menu_screen.dart';
import 'sugoroku/sugoroku_screens.dart';

/// ブラウザのアドレスバーに出すパス。本番では https://ksn-apps.web.app 配下。
abstract final class AppRoutes {
  static const home = '/';
  static const maruBatsu = '/maru_batsu';
  static const sugoroku = '/sugoroku';
  static const karuta = '/karuta';
  static const gojuon = '/gojuon';

  static Map<String, WidgetBuilder> get table => {
        home: (_) => const MainMenuScreen(),
        maruBatsu: (_) => const HomeScreen(),
        sugoroku: (_) => const SugorokuBoardSelectScreen(),
        karuta: (_) => const KarutaSelectionScreen(),
        gojuon: (_) => const GojuonTablePage(),
      };

  static String normalize(String? name) {
    if (name == null || name.isEmpty) return home;
    var path = name.split('?').first;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    return table.containsKey(path) ? path : home;
  }
}
