import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_layout.dart';
import '../models/display_item.dart';
import '../models/word_data.dart';
import '../utils/display_items_builder.dart';
import 'word_display_page.dart';

class _SelectColumn {
  final String title;
  final List<int> indices;

  const _SelectColumn({required this.title, required this.indices});
}

/// 表示前に候補を選び、選んだものだけを [WordDisplayPage] へ渡す。
class WordSelectPage extends StatefulWidget {
  final List<WordData> wordDataList;
  final List<String> selectedKanas;
  final List<String> selectedLevels;
  final bool includeShortText;
  final String displayFormat;
  final String displaySpec;
  final bool enableKanaColor;
  final bool enableBlueFrame;
  final bool enableRedDoubleCircle;
  final bool enableRandomOrder;
  final List<String> excludedSounds;
  final Random? random;

  const WordSelectPage({
    super.key,
    required this.wordDataList,
    required this.selectedKanas,
    required this.selectedLevels,
    required this.includeShortText,
    required this.displayFormat,
    required this.enableKanaColor,
    this.displaySpec = '指定なし',
    this.enableBlueFrame = true,
    this.enableRedDoubleCircle = true,
    this.enableRandomOrder = false,
    this.excludedSounds = const [],
    this.random,
  });

  @override
  State<WordSelectPage> createState() => _WordSelectPageState();
}

class _WordSelectPageState extends State<WordSelectPage> {
  late final List<DisplayItem> _candidates;
  late final List<bool> _selected;
  late final List<_SelectColumn> _columns;

  @override
  void initState() {
    super.initState();
    _candidates = sortDisplayItemsForSelection(
      buildDisplayItems(
        wordDataList: widget.wordDataList,
        selectedKanas: widget.selectedKanas,
        selectedLevels: widget.selectedLevels,
        includeShortText: widget.includeShortText,
        displaySpec: widget.displaySpec,
        excludedSounds: widget.excludedSounds,
      ),
    );
    _selected = List<bool>.filled(_candidates.length, false);
    _columns = _buildColumns(_candidates);
  }

  static List<_SelectColumn> _buildColumns(List<DisplayItem> items) {
    final buckets = <String, List<int>>{
      'レベル1': [],
      'レベル2': [],
      'レベル3': [],
      '文': [],
    };

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.isShortSentence) {
        buckets['文']!.add(i);
      } else {
        switch (item.level) {
          case 1:
            buckets['レベル1']!.add(i);
          case 2:
            buckets['レベル2']!.add(i);
          case 3:
            buckets['レベル3']!.add(i);
          default:
            buckets['文']!.add(i);
        }
      }
    }

    return [
      for (final title in ['レベル1', 'レベル2', 'レベル3', '文'])
        if (buckets[title]!.isNotEmpty)
          _SelectColumn(title: title, indices: buckets[title]!),
    ];
  }

  int get _selectedCount => _selected.where((v) => v).length;

  void _selectAll() {
    setState(() {
      for (var i = 0; i < _selected.length; i++) {
        _selected[i] = true;
      }
    });
  }

  void _toggle(int index, bool? value) {
    setState(() {
      _selected[index] = value ?? false;
    });
  }

  void _openDisplay() {
    final chosen = <DisplayItem>[
      for (var i = 0; i < _candidates.length; i++)
        if (_selected[i]) _candidates[i],
    ];
    if (chosen.isEmpty) return;

    if (widget.enableRandomOrder && chosen.length > 1) {
      chosen.shuffle(widget.random);
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WordDisplayPage(
          displayItems: chosen,
          selectedKanas: widget.selectedKanas,
          displayFormat: widget.displayFormat,
          enableKanaColor: widget.enableKanaColor,
          enableBlueFrame: widget.enableBlueFrame,
          enableRedDoubleCircle: widget.enableRedDoubleCircle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = AppLayout.isCompact(context);
    final canDisplay = _selectedCount > 0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          key: const Key('word-select-back'),
          icon: const BackButtonIcon(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _candidates.isEmpty
              ? '候補なし'
              : '候補 $_selectedCount / ${_candidates.length}',
        ),
      ),
      body: _candidates.isEmpty
          ? const Center(child: Text('表示するデータがありません'))
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 12 : 16,
                    12,
                    compact ? 12 : 16,
                    8,
                  ),
                  child: Row(
                    children: [
                      OutlinedButton(
                        key: const Key('word-select-all'),
                        onPressed: _selectAll,
                        child: const Text('全部選択'),
                      ),
                      const Spacer(),
                      FilledButton(
                        key: const Key('word-select-display'),
                        onPressed: canDisplay ? _openDisplay : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.blue.shade100,
                        ),
                        child: const Text('表示'),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildColumnLayout(compact: compact)),
              ],
            ),
    );
  }

  Widget _buildColumnLayout({required bool compact}) {
    final minColumnWidth = compact ? 148.0 : 200.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final needScroll =
            constraints.maxWidth < minColumnWidth * _columns.length;

        List<Widget> children({required bool expand}) => [
          for (var c = 0; c < _columns.length; c++) ...[
            if (c > 0)
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Colors.grey.shade300,
              ),
            if (expand)
              Expanded(child: _buildColumn(_columns[c], compact: compact))
            else
              SizedBox(
                width: minColumnWidth,
                child: _buildColumn(_columns[c], compact: compact),
              ),
          ],
        ];

        if (!needScroll) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children(expand: true),
          );
        }

        final dividerCount = _columns.length > 1 ? _columns.length - 1 : 0;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            height: constraints.maxHeight,
            width: minColumnWidth * _columns.length + dividerCount,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children(expand: false),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColumn(_SelectColumn column, {required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: Text(
            column.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: column.indices.length,
            itemBuilder: (context, rowIndex) {
              final index = column.indices[rowIndex];
              final item = _candidates[index];
              return CheckboxListTile(
                key: Key('word-select-item-$index'),
                dense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: compact ? 4 : 8,
                ),
                value: _selected[index],
                onChanged: (value) => _toggle(index, value),
                title: Text(
                  item.text,
                  style: TextStyle(fontSize: compact ? 16 : 20),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        ),
      ],
    );
  }
}
