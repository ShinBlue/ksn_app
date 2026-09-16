// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

var _depth = 0;
html.EventListener? _listener;

void engageBrowserBackTrap() {
  _depth++;
  if (_depth != 1) return;

  html.window.history.pushState(null, '', html.window.location.href);
  _listener ??= (html.Event _) {
    if (_depth <= 0) return;
    // ブラウザ戻るで教材サイト等へ出ないよう、同じ URL を積み直す。
    html.window.history.pushState(null, '', html.window.location.href);
  };
  html.window.addEventListener('popstate', _listener);
}

void disengageBrowserBackTrap() {
  if (_depth <= 0) return;
  _depth--;
  if (_depth == 0 && _listener != null) {
    html.window.removeEventListener('popstate', _listener);
  }
}
