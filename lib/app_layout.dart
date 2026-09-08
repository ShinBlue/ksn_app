import 'package:flutter/material.dart';

/// アプリ共通のレイアウト判定。
///
/// メニュー等で使っている「短い辺が 600 未満 = スマホ相当」を基準にする。
class AppLayout {
  AppLayout._();

  static const double compactShortestSide = 600;

  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide < compactShortestSide;
  }
}
