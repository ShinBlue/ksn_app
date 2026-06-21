import 'package:flutter/material.dart';

import 'analytics_service.dart';
import 'board_content_store.dart';
import 'board_defaults.dart';
import 'board_type.dart';
import 'text_board_pattern.dart';

class BoardEditScreen extends StatefulWidget {
  final BoardType boardType;
  final TextBoardPattern? textPattern;

  const BoardEditScreen({
    super.key,
    required this.boardType,
    this.textPattern,
  });

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
    } else if (widget.boardType == BoardType.text) {
      final pattern = widget.textPattern ?? _store.textPattern;
      _draftLabels = List<String>.from(_store.labelsForTextPattern(pattern));
      for (final label in _draftLabels) {
        _controllers.add(TextEditingController(text: label));
      }
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
    } else if (widget.boardType == BoardType.text) {
      final pattern = widget.textPattern ?? _store.textPattern;
      final values = _controllers.map((c) => c.text.trim()).toList();
      for (var i = 0; i < values.length; i++) {
        if (values[i].isEmpty) {
          values[i] = BoardDefaults.textPatternLabels(pattern)[i];
        }
      }
      await _store.saveTextPatternLabels(pattern, values);
    } else {
      final values = _controllers.map((c) => c.text.trim()).toList();
      for (var i = 0; i < values.length; i++) {
        if (values[i].isEmpty) {
          values[i] = BoardDefaults.labelsFor(widget.boardType)[i];
        }
      }
      await _store.saveLabels(widget.boardType, values);
    }
    final saveTarget = widget.boardType == BoardType.text
        ? '${widget.boardType.name}_${(widget.textPattern ?? _store.textPattern).name}'
        : widget.boardType.name;
    AnalyticsService.instance.logBoardEditSave(saveTarget);
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
        title: const Text('初期値にもどしますか？'),
        content: Text(
          widget.boardType == BoardType.color
              ? '編集した色が消えて、最初から用意されている色に戻ります。'
              : '編集したことばが消えて、最初から用意されている内容に戻ります。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.restore, size: 18),
            label: const Text('初期値にもどす'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    if (widget.boardType == BoardType.text) {
      final pattern = widget.textPattern ?? _store.textPattern;
      await _store.resetTextPattern(pattern);
    } else {
      await _store.reset(widget.boardType);
    }
    setState(() {
      if (widget.boardType == BoardType.color) {
        _draftColors = List<Color>.from(_store.colors());
      } else if (widget.boardType == BoardType.text) {
        final pattern = widget.textPattern ?? _store.textPattern;
        _draftLabels = List<String>.from(_store.labelsForTextPattern(pattern));
        for (var i = 0; i < _controllers.length; i++) {
          _controllers[i].text = _draftLabels[i];
        }
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
      BoardType.illustration => '',
      BoardType.color => '',
    };

    final pattern = widget.textPattern ?? _store.textPattern;
    final title = widget.boardType == BoardType.text
        ? '${BoardDefaults.textPatternName(pattern)}を編集'
        : '${widget.boardType.label}を編集';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: BoardDefaults.boardEditMaxWidth),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        BoardDefaults.textPatternName(pattern),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _EditActionButtons(
                          isColor: isColor,
                          onReset: _reset,
                          onSave: _save,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _EditActionButtons(
                      isColor: isColor,
                      onReset: _reset,
                      onSave: _save,
                    ),
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
                        largeText: false,
                        maxLength: widget.boardType == BoardType.text ? 12 : 8,
                      );
                    },
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

class _EditActionButtons extends StatelessWidget {
  final bool isColor;
  final VoidCallback onReset;
  final VoidCallback onSave;

  const _EditActionButtons({
    required this.isColor,
    required this.onReset,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final resetLabel = isColor ? '初期の色にもどす' : '初期の盤面にもどす';

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save, size: 18),
            label: const Text(
              '変更を保存する',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              backgroundColor: const Color(0xFF5BAD5B),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.restore, size: 16),
            label: Text(
              resetLabel,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              foregroundColor: Colors.orange.shade800,
              side: BorderSide(color: Colors.orange.shade400, width: 1.5),
            ),
          ),
        ),
      ],
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
