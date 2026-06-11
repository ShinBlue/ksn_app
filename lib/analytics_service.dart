import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'illustration_board_pattern.dart';
import 'text_board_pattern.dart';

/// Firebase Analytics の画面名・イベント名
abstract final class AnalyticsRoutes {
  static const mainMenu = '/main_menu';
  static const boardSelect = '/maru_batsu/board_select';
  static const textPattern = '/maru_batsu/text_pattern';
  static const illustrationPattern = '/maru_batsu/illustration_pattern';
  static const boardEdit = '/maru_batsu/board_edit';
  static const game = '/maru_batsu/game';
}

class AnalyticsService {
  AnalyticsService._();

  static final instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;
  bool _enabled = false;

  FirebaseAnalyticsObserver? get observer => _observer;

  Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
      _enabled = true;
    } catch (e, st) {
      debugPrint('Analytics init failed: $e\n$st');
    }
  }

  Map<String, String> get _baseParams => {
        'environment': _environment,
      };

  String get _environment {
    if (!kIsWeb) return 'local';
    final host = Uri.base.host;
    if (host.contains('github.io')) return 'staging';
    if (host.contains('web.app') || host.contains('firebaseapp.com')) {
      return 'production';
    }
    return 'local';
  }

  Future<void> logScreen(String screenName) async {
    if (!_enabled || _analytics == null) return;
    await _analytics!.logScreenView(
      screenName: screenName,
      screenClass: screenName,
      parameters: _baseParams,
    );
  }

  Future<void> logEvent(
    String name, {
    Map<String, String>? params,
  }) async {
    if (!_enabled || _analytics == null) return;
    await _analytics!.logEvent(
      name: name,
      parameters: {..._baseParams, ...?params},
    );
  }

  Future<void> logMainMenuSelect(String game) async {
    await logEvent('main_menu_select', params: {'game': game});
  }

  Future<void> logBoardSelect(String boardType) async {
    await logEvent('board_select', params: {'board_type': boardType});
  }

  Future<void> logTextPatternSelect(TextBoardPattern pattern) async {
    await logEvent(
      'text_pattern_select',
      params: {'pattern': pattern.name},
    );
  }

  Future<void> logIllustrationCategorySelect(
    IllustrationBoardPattern pattern,
  ) async {
    await logEvent(
      'illustration_category_select',
      params: {'category': pattern.name},
    );
  }

  Future<void> logBoardEditOpen(String boardType) async {
    await logEvent('board_edit_open', params: {'board_type': boardType});
  }

  Future<void> logBoardEditSave(String boardType) async {
    await logEvent('board_edit_save', params: {'board_type': boardType});
  }

  Future<void> logGameComplete({
    required String boardType,
    required String result,
  }) async {
    await logEvent(
      'game_complete',
      params: {'board_type': boardType, 'result': result},
    );
  }

  Future<void> logGameReset(String boardType) async {
    await logEvent('game_reset', params: {'board_type': boardType});
  }

  Future<void> logSugorokuComplete({
    required String boardSize,
    required String playMode,
    required String winnerName,
  }) async {
    await logEvent(
      'sugoroku_complete',
      params: {
        'board_size': boardSize,
        'play_mode': playMode,
        'winner': winnerName,
      },
    );
  }

  Future<void> logSugorokuReset({
    required String boardSize,
    required String playMode,
  }) async {
    await logEvent(
      'sugoroku_reset',
      params: {
        'board_size': boardSize,
        'play_mode': playMode,
      },
    );
  }
}
