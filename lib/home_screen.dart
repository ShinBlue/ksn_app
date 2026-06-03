import 'package:flutter/material.dart';
import 'game_screen.dart';

enum BoardType { color, number, text, animal }

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                const SizedBox(height: 32),
                _BoardCard(
                  number: '1',
                  label: 'カラー盤面',
                  preview: _ColorPreview(),
                  boardType: BoardType.color,
                ),
                const SizedBox(height: 16),
                _BoardCard(
                  number: '2',
                  label: '数字盤面',
                  preview: _TextPreview(['1', '2', '3', '4', '5', '6', '7', '8', '9']),
                  boardType: BoardType.number,
                ),
                const SizedBox(height: 16),
                _BoardCard(
                  number: '3',
                  label: 'テキスト盤面',
                  preview: _TextPreview(
                      ['ガム', 'ゴリラ', 'どんぐり', 'オムライス', 'りんご', 'さんご', 'かれーらいす', 'ぐらたん', 'たいこ']),
                  boardType: BoardType.text,
                ),
                const SizedBox(height: 16),
                _BoardCard(
                  number: '4',
                  label: '動物盤面',
                  preview: _TextPreview(['🐢', '🐇', '🐈', '🐒', '🐘', '🐳', '🐷', '🐙', '🦐']),
                  boardType: BoardType.animal,
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
  final BoardType boardType;

  const _BoardCard({
    required this.number,
    required this.label,
    required this.preview,
    required this.boardType,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameScreen(boardType: boardType)),
      ),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              SizedBox(width: 80, height: 80, child: preview),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '$number. $label',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorPreview extends StatelessWidget {
  static const List<Color> _colors = [
    Color(0xFF64B5F6),
    Color(0xFF8BC34A),
    Color(0xFFFFEB3B),
    Color(0xFF7B1FA2),
    Color(0xFFFFFFFF),
    Color(0xFFCE93D8),
    Color(0xFFF44336),
    Color(0xFFB0C4DE),
    Color(0xFF388E3C),
  ];

  const _ColorPreview();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: 9,
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(
          color: _colors[i],
          border: Border.all(color: Colors.grey.shade400, width: 0.5),
        ),
      ),
    );
  }
}

class _TextPreview extends StatelessWidget {
  final List<String> items;

  const _TextPreview(this.items);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: 9,
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 0.5),
        ),
        child: Center(
          child: FittedBox(
            child: Text(items[i], style: const TextStyle(fontSize: 10)),
          ),
        ),
      ),
    );
  }
}
