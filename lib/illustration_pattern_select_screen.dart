import 'package:flutter/material.dart';

import 'analytics_service.dart';
import 'board_content_store.dart';
import 'board_defaults.dart';
import 'board_type.dart';
import 'board_preview.dart';
import 'game_screen.dart';
import 'illustration_board_pattern.dart';
import 'illustration_defaults.dart';

class IllustrationPatternSelectScreen extends StatelessWidget {
  const IllustrationPatternSelectScreen({super.key});

  Future<void> _startGame(
    BuildContext context,
    IllustrationBoardPattern pattern,
  ) async {
    AnalyticsService.instance.logIllustrationCategorySelect(pattern);
    await BoardContentStore.instance.applyIllustrationPattern(pattern);
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(
          name: '${AnalyticsRoutes.game}/illustration',
        ),
        builder: (_) => const GameScreen(boardType: BoardType.illustration),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFE),
      appBar: AppBar(
        title: const Text('OXゲーム(三目並べ）'),
        backgroundColor: const Color(0xFFE3F2FD),
        foregroundColor: const Color(0xFF1565C0),
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
                  'イラストのカテゴリを選んでください',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'カテゴリをタップするとゲームが始まります',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ...IllustrationBoardPattern.values.map((pattern) {
                  final index = pattern.index;
                  final images = IllustrationDefaults.imagesFor(pattern);
                  final accent = IllustrationDefaults.patternPastelAccents[index];

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
                                  boardType: BoardType.illustration,
                                  images: images,
                                  illustrationPattern: pattern,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  IllustrationDefaults.patternName(pattern),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: accent.withValues(alpha: 0.85),
                                  ),
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
