import 'package:flutter/material.dart';

import 'analytics_service.dart';
import 'board_content_store.dart';
import 'board_defaults.dart';
import 'board_edit_screen.dart';
import 'board_preview.dart';
import 'board_type.dart';
import 'game_screen.dart';
import 'text_board_pattern.dart';

class TextPatternSelectScreen extends StatefulWidget {
  const TextPatternSelectScreen({super.key});

  @override
  State<TextPatternSelectScreen> createState() => _TextPatternSelectScreenState();
}

class _TextPatternSelectScreenState extends State<TextPatternSelectScreen> {
  final _store = BoardContentStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() => setState(() {});

  Future<void> _startGame(TextBoardPattern pattern) async {
    AnalyticsService.instance.logTextPatternSelect(pattern);
    await _store.applyTextPattern(pattern);
    if (!mounted) return;
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

  Future<void> _openEdit(TextBoardPattern pattern) async {
    AnalyticsService.instance.logBoardEditOpen('text_${pattern.name}');
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: '${AnalyticsRoutes.boardEdit}/text_${pattern.name}',
        ),
        builder: (_) => BoardEditScreen(
          boardType: BoardType.text,
          textPattern: pattern,
        ),
      ),
    );
    setState(() {});
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
                  '鉛筆アイコンで各パターンのことばを編集できます',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ...TextBoardPattern.values.map((pattern) {
                  final index = pattern.index;
                  final labels = _store.labelsForTextPattern(pattern);
                  final accent = BoardDefaults.textPatternPastelAccents[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _startGame(pattern),
                              child: SizedBox(
                                width: BoardDefaults.previewSizePattern,
                                height: BoardDefaults.previewSizePattern,
                                child: BoardPreview(
                                  boardType: BoardType.text,
                                  labels: labels,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _startGame(pattern),
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
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'パターンを編集',
                              color: accent,
                              onPressed: () => _openEdit(pattern),
                            ),
                            IconButton(
                              icon: Icon(Icons.play_circle_outline, color: accent),
                              tooltip: 'ゲームを始める',
                              onPressed: () => _startGame(pattern),
                            ),
                          ],
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
