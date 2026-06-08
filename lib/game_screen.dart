import 'package:flutter/material.dart';
import 'analytics_service.dart';
import 'board_content_store.dart';
import 'board_defaults.dart';
import 'board_type.dart';
import 'illustration_board_pattern.dart';
import 'illustration_cell_image.dart';
import 'maru_batsu_mark.dart';
import 'sound_service.dart';

class GameScreen extends StatefulWidget {
  final BoardType boardType;

  const GameScreen({super.key, required this.boardType});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<int> _board = List.filled(9, 0); // 0=空, 1=O, 2=X
  int _currentPlayer = 1;
  String? _winner; // null=進行中, 'O', 'X', 'draw'

  final _sound = SoundService();
  final _store = BoardContentStore.instance;

  void _onCellTap(int index) {
    if (_board[index] != 0 || _winner != null) return;

    setState(() {
      _board[index] = _currentPlayer;
      final wasPlaying = _winner == null;
      _winner = _checkWinner();
      if (_winner == null) {
        if (_currentPlayer == 1) { _sound.playPlaceO(); } else { _sound.playPlaceX(); }
        _currentPlayer = _currentPlayer == 1 ? 2 : 1;
      } else if (_winner == 'draw') {
        _sound.playDraw();
      } else {
        _sound.playWin();
      }
      if (wasPlaying && _winner != null) {
        AnalyticsService.instance.logGameComplete(
          boardType: widget.boardType.name,
          result: _winner!,
        );
      }
    });
  }

  String? _checkWinner() {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (final line in lines) {
      final a = _board[line[0]], b = _board[line[1]], c = _board[line[2]];
      if (a != 0 && a == b && b == c) {
        return a == 1 ? 'maru' : 'batsu';
      }
    }

    if (_board.every((c) => c != 0)) return 'draw';
    return null;
  }

  void _reset() {
    AnalyticsService.instance.logGameReset(widget.boardType.name);
    setState(() {
      _board = List.filled(9, 0);
      _currentPlayer = 1;
      _winner = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = _store.colors();
    final labels = _store.labels(widget.boardType);
    final images = widget.boardType == BoardType.illustration
        ? _store.illustrationImages()
        : null;
    final illustrationPattern = widget.boardType == BoardType.illustration
        ? _store.illustrationPattern
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('まるばつゲーム'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          StatefulBuilder(
            builder: (context, setIconState) => IconButton(
              icon: Icon(
                _sound.soundEnabled ? Icons.volume_up : Icons.volume_off,
              ),
              tooltip: _sound.soundEnabled ? '音ON' : '音OFF',
              onPressed: () {
                setIconState(() {
                  _sound.soundEnabled = !_sound.soundEnabled;
                });
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxHeight < 520;
          final contentWidth = constraints.maxWidth.clamp(0.0, 480.0);
          final boardSize = ([
            contentWidth * 0.85,
            constraints.maxHeight * (isCompact ? 0.55 : 0.45),
          ].reduce((a, b) => a < b ? a : b) * BoardDefaults.boardScale)
              .clamp(BoardDefaults.boardMinSize, BoardDefaults.boardMaxSize);

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isCompact ? 8 : 16,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatusText(compact: isCompact),
                      SizedBox(height: isCompact ? 12 : 24),
                      SizedBox(
                        width: boardSize,
                        height: boardSize,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          ),
                          itemCount: 9,
                          itemBuilder: (_, index) => _buildCell(
                            index,
                            boardSize / 3,
                            colors: colors,
                            labels: labels,
                            images: images,
                            illustrationPattern: illustrationPattern,
                          ),
                        ),
                      ),
                      SizedBox(height: isCompact ? 16 : 32),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _reset,
                            icon: const Icon(Icons.refresh),
                            label: const Text('もう一度'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              widget.boardType == BoardType.text ||
                                      widget.boardType == BoardType.illustration
                                  ? Icons.arrow_back
                                  : Icons.list,
                            ),
                            label: Text(
                              widget.boardType == BoardType.text ||
                                      widget.boardType == BoardType.illustration
                                  ? 'パターン選択'
                                  : '盤面選択',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusText({bool compact = false}) {
    final fontSize = compact ? 20.0 : 26.0;

    if (_winner == 'draw') {
      return Text(
        'ひきわけ！',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      );
    }

    if (_winner != null) {
      final isMaru = _winner == 'maru';
      return Text(
        isMaru ? 'まるの勝ち！' : 'ばつの勝ち！',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: isMaru ? Colors.red : Colors.blue,
        ),
      );
    }

    return Text(
      _currentPlayer == 1 ? 'まるの番' : 'ばつの番',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: _currentPlayer == 1 ? Colors.red : Colors.blue,
      ),
    );
  }

  Widget _buildCell(
    int index,
    double cellSize, {
    required List<Color> colors,
    required List<String> labels,
    List<String>? images,
    IllustrationBoardPattern? illustrationPattern,
  }) {
    final player = _board[index];

    return GestureDetector(
      onTap: () => _onCellTap(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade700, width: 1.5),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCellBackground(
              index,
              cellSize,
              colors: colors,
              labels: labels,
              images: images,
              illustrationPattern: illustrationPattern,
            ),
            if (player != 0)
              Center(
                child: MaruBatsuMark(
                  player: player,
                  size: cellSize * 0.55,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCellBackground(
    int index,
    double cellSize, {
    required List<Color> colors,
    required List<String> labels,
    List<String>? images,
    IllustrationBoardPattern? illustrationPattern,
  }) {
    switch (widget.boardType) {
      case BoardType.color:
        return Container(color: colors[index]);
      case BoardType.number:
      case BoardType.text:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: FittedBox(
              child: Text(
                labels[index],
                style: TextStyle(
                  fontSize: widget.boardType == BoardType.number
                      ? cellSize * 0.35
                      : cellSize * 0.18,
                  fontWeight: widget.boardType == BoardType.number
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      case BoardType.illustration:
        return IllustrationCellImage(
          assetPath: images![index],
          pattern: illustrationPattern,
        );
    }
  }
}
