import 'package:flutter/material.dart';

import 'board_content_store.dart';
import 'board_defaults.dart';
import 'board_type.dart';

class BoardEditScreen extends StatefulWidget {
  final BoardType boardType;

  const BoardEditScreen({super.key, required this.boardType});

  @override
  State<BoardEditScreen> createState() => _BoardEditScreenState();
}

class _BoardEditScreenState extends State<BoardEditScreen> {
  final _store = BoardContentStore.instance;
  late List<String> _draftLabels;
  late List<Color> _draftColors;
  final _controllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    if (widget.boardType == BoardType.color) {
      _draftColors = List<Color>.from(_store.colors());
    } else {
      _draftLabels = List<String>.from(_store.labels(widget.boardType));
      for (final label in _draftLabels) {
        _controllers.add(TextEditingController(text: label));
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.boardType == BoardType.color) {
      await _store.saveColors(_draftColors);
    } else {
      final values = _controllers.map((c) => c.text.trim()).toList();
      for (var i = 0; i < values.length; i++) {
        if (values[i].isEmpty) {
          values[i] = widget.boardType == BoardType.text
              ? BoardDefaults.textPatternLabels(_store.textPattern)[i]
              : BoardDefaults.labelsFor(widget.boardType)[i];
        }
      }
      await _store.saveLabels(widget.boardType, values);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('保存しました')),
    );
    Navigator.pop(context, true);
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('初期値に戻す'),
        content: const Text('盤面の内容を初期状態に戻しますか？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('戻す')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _store.reset(widget.boardType);
    setState(() {
      if (widget.boardType == BoardType.color) {
        _draftColors = List<Color>.from(_store.colors());
      } else {
        _draftLabels = List<String>.from(_store.labels(widget.boardType));
        for (var i = 0; i < _controllers.length; i++) {
          _controllers[i].text = _draftLabels[i];
        }
      }
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('初期値に戻しました')),
    );
  }

  void _pickColor(int index) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'マス ${index + 1} の色',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: BoardDefaults.colorPickerPalette.map((color) {
                  final selected = _draftColors[index] == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _draftColors[index] = color);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.black : Colors.grey.shade400,
                          width: selected ? 3 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isColor = widget.boardType == BoardType.color;
    final hint = switch (widget.boardType) {
      BoardType.number => '数字（例: 1）',
      BoardType.text => 'ことば（例: りんご）',
      BoardType.animal => '絵文字（例: 🐱）',
      BoardType.color => '',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.boardType.label}を編集'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: '初期値に戻す',
            onPressed: _reset,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: '保存',
            onPressed: _save,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isColor ? 'マスをタップして色を選んでください' : '各マスの文字や絵を入力してください',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                if (widget.boardType == BoardType.text) ...[
                  const SizedBox(height: 16),
                  Text(
                    'パターン: ${BoardDefaults.textPatternName(_store.textPattern)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
                const SizedBox(height: 24),
                AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: 9,
                    itemBuilder: (_, index) {
                      if (isColor) {
                        return _ColorEditCell(
                          color: _draftColors[index],
                          index: index,
                          onTap: () => _pickColor(index),
                        );
                      }
                      return _LabelEditCell(
                        controller: _controllers[index],
                        index: index,
                        hint: hint,
                        largeText: widget.boardType == BoardType.animal,
                        maxLength: widget.boardType == BoardType.text ? 12 : 8,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('保存する'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorEditCell extends StatelessWidget {
  final Color color;
  final int index;
  final VoidCallback onTap;

  const _ColorEditCell({
    required this.color,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade600),
          ),
          child: Text(
            '${index + 1}',
            style: TextStyle(
              fontSize: 12,
              color: color.computeLuminance() > 0.5 ? Colors.black54 : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}

class _LabelEditCell extends StatelessWidget {
  final TextEditingController controller;
  final int index;
  final String hint;
  final bool largeText;
  final int maxLength;

  const _LabelEditCell({
    required this.controller,
    required this.index,
    required this.hint,
    required this.largeText,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade600),
        color: Colors.grey.shade50,
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Text(
            '${index + 1}',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              maxLength: maxLength,
              style: TextStyle(fontSize: largeText ? 22 : 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 10),
                border: InputBorder.none,
                counterText: '',
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
