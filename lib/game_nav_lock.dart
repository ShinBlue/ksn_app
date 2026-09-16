import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'game_nav_lock_stub.dart'
    if (dart.library.html) 'game_nav_lock_web.dart'
    as browser_trap;

/// ゲーム中の離脱を防ぐ。
///
/// - ブラウザ／端末の戻るを受けても pop しない
/// - Web では history を積み直し、教材サイト等へのブラウザ戻るも抑止する
/// - AppBar の戻るボタンは出さない（[automaticallyImplyLeading]: false）
class GameNavLock extends StatefulWidget {
  const GameNavLock({super.key, required this.child});

  final Widget child;

  @override
  State<GameNavLock> createState() => _GameNavLockState();
}

class _GameNavLockState extends State<GameNavLock> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      browser_trap.engageBrowserBackTrap();
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      browser_trap.disengageBrowserBackTrap();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: widget.child,
    );
  }
}
