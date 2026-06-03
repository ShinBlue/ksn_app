import 'package:flutter/material.dart';
import 'home_screen.dart';
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

  static const List<Color> _colors = [
    Color(0xFF64B5F6),
    Color(0xFF8BC34A),
    Color(0xFFFFEB3B),
    Color(0xFF7B1FA2),
    Color(0xFFFFFFFF),
    Color(0xFFCE93D8),
    Color(0xFFF44336),
    Color(0xFFFF9800),
    Color(0xFF388E3C),
  ];

  static const List<String> _numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];

  static const List<String> _texts = [
    'ガム', 'ゴリラ', 'どんぐり',
    'オムライス', 'りんご', 'さんご',
    'かれーらいす', 'ぐらたん', 'たいこ',
  ];

  static const List<String> _animals = [
    '🐢', '🐇', '🐈',
    '🐒', '🐘', '🐳',
    '🐷', '🐙', '🦐',
  ];

  void _onCellTap(int index) {
    if (_board[index] != 0 || _winner != null) return;

    setState(() {
      _board[index] = _currentPlayer;
      _winner = _checkWinner();
      if (_winner == null) {
        if (_currentPlayer == 1) { _sound.playPlaceO(); } else { _sound.playPlaceX(); }
        _currentPlayer = _currentPlayer == 1 ? 2 : 1;
      } else if (_winner == 'draw') {
        _sound.playDraw();
      } else {
        _sound.playWin();
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
        return a == 1 ? 'O' : 'X';
      }
    }

    if (_board.every((c) => c != 0)) return 'draw';
    return null;
  }

  void _reset() {
    setState(() {
      _board = List.filled(9, 0);
      _currentPlayer = 1;
      _winner = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final boardSize = (constraints.maxWidth * 0.85).clamp(240.0, 400.0);
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatusText(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: boardSize,
                    height: boardSize,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                      itemCount: 9,
                      itemBuilder: (_, index) => _buildCell(index, boardSize / 3),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh),
                        label: const Text('もう一度'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.list),
                        label: const Text('盤面選択'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    final String text;
    final Color color;

    if (_winner == 'draw') {
      text = '引き分け！';
      color = Colors.orange;
    } else if (_winner != null) {
      text = '$_winner の勝ち！';
      color = _winner == 'O' ? Colors.red : Colors.blue;
    } else {
      text = '${_currentPlayer == 1 ? 'O' : 'X'} の番';
      color = _currentPlayer == 1 ? Colors.red : Colors.blue;
    }

    return Text(
      text,
      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
    );
  }

  Widget _buildCell(int index, double cellSize) {
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
            _buildCellBackground(index, cellSize),
            if (player != 0)
              Center(
                child: Text(
                  player == 1 ? '○' : '×',
                  style: TextStyle(
                    fontSize: cellSize * 0.6,
                    fontWeight: FontWeight.bold,
                    color: (player == 1 ? Colors.red : Colors.blue).withValues(alpha: 0.85),
                    shadows: const [
                      Shadow(color: Colors.white, blurRadius: 6),
                      Shadow(color: Colors.white, blurRadius: 12),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCellBackground(int index, double cellSize) {
    switch (widget.boardType) {
      case BoardType.color:
        return Container(color: _colors[index]);
      case BoardType.number:
        return Center(
          child: Text(
            _numbers[index],
            style: TextStyle(fontSize: cellSize * 0.35, fontWeight: FontWeight.w500),
          ),
        );
      case BoardType.text:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: FittedBox(
              child: Text(
                _texts[index],
                style: TextStyle(fontSize: cellSize * 0.18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      case BoardType.animal:
        return Center(
          child: Text(
            _animals[index],
            style: TextStyle(fontSize: cellSize * 0.45),
          ),
        );
    }
  }
}
