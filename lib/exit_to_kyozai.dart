import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 各アプリの入口から戻る先。メニューではなく教材ページへ出す。
abstract final class KyozaiExit {
  static const url = 'https://www.kotoba-support-net.org/kyozai';

  static Future<void> leave() {
    return launchUrl(Uri.parse(url), webOnlyWindowName: '_self');
  }
}

/// ブラウザ戻る／端末戻るを教材ページへ向ける。
class ExitToKyozaiScope extends StatelessWidget {
  const ExitToKyozaiScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          KyozaiExit.leave();
        }
      },
      child: child,
    );
  }
}

class ExitToKyozaiButton extends StatelessWidget {
  const ExitToKyozaiButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const BackButtonIcon(),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: KyozaiExit.leave,
    );
  }
}
