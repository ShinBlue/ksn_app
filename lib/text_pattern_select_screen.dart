import 'package:flutter/material.dart';

import 'analytics_service.dart';
import 'board_content_store.dart';
import 'board_defaults.dart';
import 'board_preview.dart';
import 'board_type.dart';
import 'game_screen.dart';
import 'text_board_pattern.dart';

class TextPatternSelectScreen extends StatelessWidget {
  const TextPatternSelectScreen({super.key});

  Future<void> _startGame(BuildContext context, TextBoardPattern pattern) async {
    AnalyticsService.instance.logTextPatternSelect(pattern);
    await BoardContentStore.instance.applyTextPattern(pattern);
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(
          name: '${AnalyticsRoutes.game}/text',
        ),
        builder: (_) => const GameScreen(boardType: BoardType.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFE),
      appBar: AppBar(
        title: const Text('まるばつゲーム'),
        backgroundColor: const Color(0xFFE8F5E9),
        foregroundColor: const Color(0xFF2E7D32),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'ことばのパターンを選んでください',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'パターンをタップするとゲームが始まります',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ...TextBoardPattern.values.map((pattern) {
                  final index = pattern.index;
                  final labels = BoardDefaults.textPatternLabels(pattern);
                  final accent = BoardDefaults.textPatternPastelAccents[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _startGame(context, pattern),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              SizedBox(
                                width: BoardDefaults.previewSizePattern,
                                height: BoardDefaults.previewSizePattern,
                                child: BoardPreview(
                                  boardType: BoardType.text,
                                  labels: labels,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      BoardDefaults.textPatternName(pattern),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: accent.withValues(alpha: 0.85),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      labels.join('、'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.play_circle_outline, color: accent),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
