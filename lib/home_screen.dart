import 'package:flutter/material.dart';
import 'analytics_service.dart';
import 'board_content_store.dart';
import 'board_defaults.dart';
import 'board_edit_screen.dart';
import 'board_preview.dart';
import 'board_type.dart';
import 'game_screen.dart';
import 'illustration_pattern_select_screen.dart';
import 'text_pattern_select_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  Future<void> _openEdit(BoardType boardType) async {
    AnalyticsService.instance.logBoardEditOpen(boardType.name);
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: '${AnalyticsRoutes.boardEdit}/${boardType.name}',
        ),
        builder: (_) => BoardEditScreen(boardType: boardType),
      ),
    );
    setState(() {});
  }

  void _startGame(BoardType boardType) {
    AnalyticsService.instance.logBoardSelect(boardType.name);
    if (boardType == BoardType.text) {
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: AnalyticsRoutes.textPattern),
          builder: (_) => const TextPatternSelectScreen(),
        ),
      );
      return;
    }
    if (boardType == BoardType.illustration) {
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(
            name: AnalyticsRoutes.illustrationPattern,
          ),
          builder: (_) => const IllustrationPatternSelectScreen(),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: '${AnalyticsRoutes.game}/${boardType.name}',
        ),
        builder: (_) => GameScreen(boardType: boardType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('まるばつゲーム'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  '盤面を選んでください',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '鉛筆アイコンから文字・色を変更できます',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 32),
                _BoardCard(
                  number: '1',
                  label: BoardType.color.label,
                  preview: BoardPreview(
                    boardType: BoardType.color,
                    colors: _store.colors(),
                  ),
                  onEdit: () => _openEdit(BoardType.color),
                  onPlay: () => _startGame(BoardType.color),
                ),
                const SizedBox(height: 16),
                _BoardCard(
                  number: '2',
                  label: BoardType.number.label,
                  preview: BoardPreview(
                    boardType: BoardType.number,
                    labels: _store.labels(BoardType.number),
                  ),
                  onEdit: () => _openEdit(BoardType.number),
                  onPlay: () => _startGame(BoardType.number),
                ),
                const SizedBox(height: 16),
                _BoardCard(
                  number: '3',
                  label: BoardType.text.label,
                  preview: BoardPreview(
                    boardType: BoardType.text,
                    labels: _store.labels(BoardType.text),
                  ),
                  onEdit: () => _openEdit(BoardType.text),
                  onPlay: () => _startGame(BoardType.text),
                ),
                const SizedBox(height: 16),
                _BoardCard(
                  number: '4',
                  label: BoardType.illustration.label,
                  preview: BoardPreview(
                    boardType: BoardType.illustration,
                    images: _store.illustrationImages(),
                    illustrationPattern: _store.illustrationPattern,
                  ),
                  onPlay: () => _startGame(BoardType.illustration),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardCard extends StatelessWidget {
  final String number;
  final String label;
  final Widget preview;
  final VoidCallback onPlay;
  final VoidCallback? onEdit;

  const _BoardCard({
    required this.number,
    required this.label,
    required this.preview,
    required this.onPlay,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: onPlay,
              child: SizedBox(
                width: BoardDefaults.previewSizeHome,
                height: BoardDefaults.previewSizeHome,
                child: preview,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: onPlay,
                child: Text(
                  '$number. $label',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: '盤面を編集',
                onPressed: onEdit,
              ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'ゲームを始める',
              onPressed: onPlay,
            ),
          ],
        ),
      ),
    );
  }
}
