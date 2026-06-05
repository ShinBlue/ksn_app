import 'package:flutter/material.dart';

import 'board_content_store.dart';
import 'board_defaults.dart';
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
  late TextBoardPattern _selected;

  @override
  void initState() {
    super.initState();
    _selected = _store.textPattern;
  }

  Future<void> _confirm() async {
    await _store.applyTextPattern(_selected);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
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
                  'テキスト盤面で使うことばセットです',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ...TextBoardPattern.values.map((pattern) {
                  final index = pattern.index;
                  final labels = BoardDefaults.textPatternLabels(pattern);
                  final selected = _selected == pattern;
                  final fill = BoardDefaults.textPatternPastelFills[index];
                  final border = BoardDefaults.textPatternPastelBorders[index];
                  final accent = BoardDefaults.textPatternPastelAccents[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: selected ? fill : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      elevation: selected ? 2 : 0,
                      shadowColor: border.withValues(alpha: 0.4),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() => _selected = pattern),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected ? border : Colors.grey.shade300,
                              width: selected ? 2.5 : 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 72,
                                height: 72,
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
                              if (selected)
                                Icon(Icons.check_circle, color: accent),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _confirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFA5D6A7),
                    foregroundColor: const Color(0xFF1B5E20),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'ゲームを始める',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
