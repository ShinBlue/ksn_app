import 'package:flutter/material.dart';

import 'sugoroku_board_store.dart';
import 'sugoroku_models.dart';
import 'sugoroku_screens.dart';

class SugorokuBoardListScreen extends StatefulWidget {
  const SugorokuBoardListScreen({super.key});

  @override
  State<SugorokuBoardListScreen> createState() =>
      _SugorokuBoardListScreenState();
}

class _SugorokuBoardListScreenState extends State<SugorokuBoardListScreen> {
  final _store = SugorokuBoardStore.instance;

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

  void _openBoard(SugorokuSavedBoard board) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SugorokuGameSetupScreen(
          size: board.size,
          initialBoard: board,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(SugorokuSavedBoard board) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('さくじょしますか？'),
        content: Text('「${board.title}」をさくじょします'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('やめる'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('さくじょ'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _store.delete(board.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final boards = _store.boards;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFE),
      appBar: AppBar(
        title: Text('保存した盤面（${boards.length}/$sugorokuSavedBoardsMax）'),
        backgroundColor: const Color(0xFFE8F5E9),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: boards.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'まだほぞんされた盤面はありません\n「盤面を作る」からつくってみましょう',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: boards.length,
                  itemBuilder: (context, index) {
                    final board = boards[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SavedBoardCard(
                        board: board,
                        onTap: () => _openBoard(board),
                        onDelete: () => _confirmDelete(board),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _SavedBoardCard extends StatelessWidget {
  final SugorokuSavedBoard board;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SavedBoardCard({
    required this.board,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      board.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      board.size == SugorokuBoardSize.short10
                          ? '10ます'
                          : '20ます',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'さくじょ',
                color: Colors.grey.shade600,
                onPressed: onDelete,
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF66BB6A)),
            ],
          ),
        ),
      ),
    );
  }
}
