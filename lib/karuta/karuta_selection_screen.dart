import 'dart:math';

import 'package:flutter/material.dart';

import '../analytics_service.dart';
import '../exit_to_kyozai.dart';
import 'karuta_catalog.dart';
import 'karuta_game_screen.dart';
import 'karuta_models.dart';
import 'karuta_repository.dart';

class KarutaSelectionMetrics {
  static const uiFontSize = 13.0;
  static const tableBottomPadding = 14.0;

  final double scale;
  final double tileWidth;
  final double tileHeight;
  final double rowButtonWidth;
  final double pairGap;
  final double singleRowWidth;
  final double pairedRowWidth;
  final double secondaryColumnOffset;
  final double tileGap;
  final double rowInnerGap;
  final double charFontSize;
  final double rowLabelFontSize;
  final double presetFontSize;
  final double presetPaddingH;
  final double presetPaddingV;

  const KarutaSelectionMetrics({
    required this.scale,
    required this.tileWidth,
    required this.tileHeight,
    required this.rowButtonWidth,
    required this.pairGap,
    required this.singleRowWidth,
    required this.pairedRowWidth,
    required this.secondaryColumnOffset,
    required this.tileGap,
    required this.rowInnerGap,
    required this.charFontSize,
    required this.rowLabelFontSize,
    required this.presetFontSize,
    required this.presetPaddingH,
    required this.presetPaddingV,
  });

  static KarutaSelectionMetrics fit({
    required double tableWidth,
    required double tableHeight,
  }) {
    const lineCount = 11;
    const countBarHeight = 44.0;
    const countBarGap = 10.0;
    const presetBlockHeight = 40.0;
    const topGap = 18.0;
    const baseTileW = 40.0;
    const baseTileH = 46.0;
    const baseLineGap = 3.0;
    const baseBtnW = 56.0;
    const baseGap = 5.0;
    const baseTileGap = 5.0;
    const basePairGap = 24.0;

    final singleRowW = baseBtnW + baseGap + 5 * baseTileW + 4 * baseTileGap;
    final pairedRowW = singleRowW * 2 + basePairGap;

    final rowsAreaH = max(
      0,
      tableHeight -
          countBarHeight -
          countBarGap -
          presetBlockHeight -
          topGap -
          tableBottomPadding,
    );
    final scaleH =
        rowsAreaH / (lineCount * baseTileH + (lineCount - 1) * baseLineGap);
    final scaleW = tableWidth / pairedRowW;
    // 上限は「収まる範囲でできるだけ大きく」表示するための保険的な値。
    // 実際の大きさは scaleH/scaleW（画面に収まる最大値）で決まる。
    final scale = min(scaleH, scaleW).clamp(0.5, 2.0);

    final scaledSingleRowW = singleRowW * scale;
    final scaledPairGap = basePairGap * scale;
    final tileHeight = baseTileH * scale;
    final tileWidth = baseTileW * scale;

    return KarutaSelectionMetrics(
      scale: scale,
      tileWidth: tileWidth,
      tileHeight: tileHeight,
      rowButtonWidth: baseBtnW * scale,
      pairGap: scaledPairGap,
      singleRowWidth: scaledSingleRowW,
      pairedRowWidth: pairedRowW * scale,
      secondaryColumnOffset: scaledSingleRowW + scaledPairGap,
      tileGap: baseTileGap * scale,
      rowInnerGap: baseGap * scale,
      charFontSize: (tileHeight * 0.44).clamp(14.0, 32.0),
      rowLabelFontSize: (uiFontSize * scale).clamp(uiFontSize, 24.0),
      presetFontSize: 12,
      presetPaddingH: 12,
      presetPaddingV: 8,
    );
  }
}

class KarutaSelectionScreen extends StatefulWidget {
  const KarutaSelectionScreen({super.key});

  @override
  State<KarutaSelectionScreen> createState() => _KarutaSelectionScreenState();
}

const kKarutaValidCardCounts = [4, 8, 12, 16, 20];

class _KarutaSelectionScreenState extends State<KarutaSelectionScreen> {
  final _selected = <String>{};
  int? _targetCount;
  KarutaLayoutMode _layoutMode = KarutaLayoutMode.aligned;
  bool _loading = true;
  String? _error;

  bool get _isComplete =>
      _targetCount != null && _selected.length == _targetCount;

  @override
  void initState() {
    super.initState();
    _loadData();
    AnalyticsService.instance.logScreen('/karuta/select');
  }

  Future<void> _loadData() async {
    try {
      await KarutaRepository.instance.load();
      if (mounted) {
        setState(() => _loading = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _targetCount == null) _showCountPicker();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'カルタデータの読み込みに失敗しました';
        });
      }
    }
  }

  Future<void> _showCountPicker() async {
    final result = await showDialog<int>(
      context: context,
      barrierDismissible: _targetCount != null,
      builder: (context) => _CountPickerDialog(selectedCount: _targetCount),
    );
    if (result != null) _selectTargetCount(result);
  }

  void _selectTargetCount(int count) {
    setState(() {
      _targetCount = count;
      if (_selected.length > count) {
        final trimmed = _selected.take(count).toList();
        _selected
          ..clear()
          ..addAll(trimmed);
      }
    });
  }

  void _toggle(String character) {
    if (_targetCount == null) return;
    setState(() {
      if (_selected.contains(character)) {
        _selected.remove(character);
      } else if (_selected.length < _targetCount!) {
        _selected.add(character);
      }
    });
  }

  void _togglePreset(Iterable<String> characters) {
    if (_targetCount == null) return;
    setState(() {
      if (characters.every(_selected.contains)) {
        _selected.removeAll(characters);
      } else {
        for (final character in characters) {
          if (_selected.length >= _targetCount!) break;
          _selected.add(character);
        }
      }
    });
  }

  bool _isPresetSelected(Iterable<String> characters) =>
      characters.every(_selected.contains);

  void _clearAll() {
    setState(() => _selected.clear());
  }

  void _toggleRow(KarutaRow row) {
    if (_targetCount == null) return;
    final allSelected = row.characters.every(_selected.contains);
    setState(() {
      if (allSelected) {
        _selected.removeAll(row.characters);
      } else {
        for (final character in row.characters) {
          if (_selected.length >= _targetCount!) break;
          _selected.add(character);
        }
      }
    });
  }

  bool _isRowFullySelected(KarutaRow row) =>
      row.characters.every(_selected.contains);

  bool _isRowPartiallySelected(KarutaRow row) =>
      row.characters.any(_selected.contains) && !_isRowFullySelected(row);

  void _startGame() {
    if (!_isComplete) return;
    AnalyticsService.instance.logEvent(
      'karuta_start',
      params: {
        'card_count': '${_selected.length}',
        'layout_mode': _layoutMode.name,
      },
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/karuta/game'),
        builder: (_) => KarutaGameScreen(
          selectedCharacters: _selected.toList(),
          layoutMode: _layoutMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExitToKyozaiScope(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFBFE),
        appBar: AppBar(
          leading: const ExitToKyozaiButton(),
          title: const Text('カルタ'),
          backgroundColor: const Color(0xFFFFF3E0),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : LayoutBuilder(
                builder: (context, constraints) {
                  const horizontalPadding = 8.0;
                  const columnGap = 6.0;
                  final sidePanelWidth = (constraints.maxWidth * 0.24).clamp(
                    120.0,
                    160.0,
                  );
                  final tableWidth =
                      constraints.maxWidth -
                      sidePanelWidth -
                      horizontalPadding * 2 -
                      columnGap;
                  final metrics = KarutaSelectionMetrics.fit(
                    tableWidth: tableWidth,
                    tableHeight: constraints.maxHeight,
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 4,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Center(
                                child: _CountStatusChip(
                                  metrics: metrics,
                                  selectedCount: _targetCount,
                                  onTap: _showCountPicker,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Opacity(
                                opacity: _targetCount == null ? 0.35 : 1,
                                child: IgnorePointer(
                                  ignoring: _targetCount == null,
                                  child: Center(
                                    child: _PresetBar(
                                      metrics: metrics,
                                      isAiueoSelected: _isPresetSelected(
                                        karutaAiueoCharacters,
                                      ),
                                      isSeionSelected: _isPresetSelected(
                                        karutaSeionCharacters,
                                      ),
                                      isDakutenSelected: _isPresetSelected(
                                        karutaDakutenCharacters,
                                      ),
                                      isVoicedSelected: _isPresetSelected(
                                        karutaVoicedCharacters,
                                      ),
                                      isAllSelected: _isPresetSelected(
                                        karutaAllCharacters,
                                      ),
                                      onToggleAiueo: () =>
                                          _togglePreset(karutaAiueoCharacters),
                                      onToggleSeion: () =>
                                          _togglePreset(karutaSeionCharacters),
                                      onToggleDakuten: () => _togglePreset(
                                        karutaDakutenCharacters,
                                      ),
                                      onToggleVoiced: () =>
                                          _togglePreset(karutaVoicedCharacters),
                                      onToggleAll: () =>
                                          _togglePreset(karutaAllCharacters),
                                      onClear: _clearAll,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Opacity(
                                      opacity: _targetCount == null ? 0.35 : 1,
                                      child: IgnorePointer(
                                        ignoring: _targetCount == null,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: KarutaSelectionMetrics
                                                  .tableBottomPadding,
                                            ),
                                            child: SizedBox(
                                              width: metrics.pairedRowWidth,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  for (final line
                                                      in karutaDisplayLines)
                                                    _KarutaDisplayLineSection(
                                                      line: line,
                                                      metrics: metrics,
                                                      selected: _selected,
                                                      isRowFullySelected:
                                                          _isRowFullySelected,
                                                      isRowPartiallySelected:
                                                          _isRowPartiallySelected,
                                                      onToggleRow: _toggleRow,
                                                      onToggleChar: _toggle,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_targetCount == null)
                                      Text(
                                        'まず あそぶ まいすうを\nえらんでね',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: columnGap),
                        SizedBox(
                          width: sidePanelWidth,
                          child: _SelectionSidePanel(
                            selectedCount: _selected.length,
                            targetCount: _targetCount,
                            layoutMode: _layoutMode,
                            onLayoutModeChanged: (mode) =>
                                setState(() => _layoutMode = mode),
                            onStart: _startGame,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _CountStatusChip extends StatelessWidget {
  final KarutaSelectionMetrics metrics;
  final int? selectedCount;
  final VoidCallback onTap;

  const _CountStatusChip({
    required this.metrics,
    required this.selectedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFE0B2),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: metrics.presetPaddingH,
            vertical: metrics.presetPaddingV,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFB74D)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedCount == null ? 'まいすうを えらぶ' : '$selectedCountまい あそぶ',
                style: TextStyle(
                  fontSize: metrics.presetFontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE65100),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 14, color: Color(0xFFE65100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountPickerDialog extends StatelessWidget {
  final int? selectedCount;

  const _CountPickerDialog({required this.selectedCount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'なんまい あそぶ？',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                for (final count in kKarutaValidCardCounts)
                  _CountPickerOption(
                    count: count,
                    selected: selectedCount == count,
                    onTap: () => Navigator.pop(context, count),
                  ),
              ],
            ),
            if (selectedCount != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('とじる'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CountPickerOption extends StatelessWidget {
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _CountPickerOption({
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE8F5E9) : const Color(0xFFFFE0B2),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 76,
          height: 76,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF43A047)
                  : const Color(0xFFFFB74D),
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            '$countまい',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: selected
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFE65100),
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetBar extends StatelessWidget {
  final KarutaSelectionMetrics metrics;
  final bool isAiueoSelected;
  final bool isSeionSelected;
  final bool isDakutenSelected;
  final bool isVoicedSelected;
  final bool isAllSelected;
  final VoidCallback onToggleAiueo;
  final VoidCallback onToggleSeion;
  final VoidCallback onToggleDakuten;
  final VoidCallback onToggleVoiced;
  final VoidCallback onToggleAll;
  final VoidCallback onClear;

  const _PresetBar({
    required this.metrics,
    required this.isAiueoSelected,
    required this.isSeionSelected,
    required this.isDakutenSelected,
    required this.isVoicedSelected,
    required this.isAllSelected,
    required this.onToggleAiueo,
    required this.onToggleSeion,
    required this.onToggleDakuten,
    required this.onToggleVoiced,
    required this.onToggleAll,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _PresetChip(
        label: 'あいうえお',
        metrics: metrics,
        selected: isAiueoSelected,
        onTap: onToggleAiueo,
      ),
      _PresetChip(
        label: '清音だけ',
        metrics: metrics,
        selected: isSeionSelected,
        onTap: onToggleSeion,
      ),
      _PresetChip(
        label: '濁音だけ',
        metrics: metrics,
        selected: isDakutenSelected,
        onTap: onToggleDakuten,
      ),
      _PresetChip(
        label: '濁音・半濁音',
        metrics: metrics,
        selected: isVoicedSelected,
        onTap: onToggleVoiced,
      ),
      _PresetChip(
        label: '全部',
        metrics: metrics,
        selected: isAllSelected,
        onTap: onToggleAll,
      ),
      _PresetChip(
        label: '全部解除',
        metrics: metrics,
        onTap: onClear,
        outlined: true,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            chips[i],
          ],
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final KarutaSelectionMetrics metrics;
  final VoidCallback onTap;
  final bool selected;
  final bool outlined;

  const _PresetChip({
    required this.label,
    required this.metrics,
    required this.onTap,
    this.selected = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = selected && !outlined;

    return Material(
      color: outlined
          ? Colors.white
          : active
          ? const Color(0xFFE8F5E9)
          : const Color(0xFFFFE0B2),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: metrics.presetPaddingH,
            vertical: metrics.presetPaddingV,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: outlined
                  ? Colors.grey.shade400
                  : active
                  ? const Color(0xFF43A047)
                  : const Color(0xFFFFB74D),
              width: active ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: metrics.presetFontSize,
              fontWeight: active ? FontWeight.bold : FontWeight.w600,
              color: outlined
                  ? Colors.grey.shade700
                  : active
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFE65100),
            ),
          ),
        ),
      ),
    );
  }
}

class _KarutaDisplayLineSection extends StatelessWidget {
  final KarutaDisplayLine line;
  final KarutaSelectionMetrics metrics;
  final Set<String> selected;
  final bool Function(KarutaRow) isRowFullySelected;
  final bool Function(KarutaRow) isRowPartiallySelected;
  final void Function(KarutaRow) onToggleRow;
  final void Function(String) onToggleChar;

  const _KarutaDisplayLineSection({
    required this.line,
    required this.metrics,
    required this.selected,
    required this.isRowFullySelected,
    required this.isRowPartiallySelected,
    required this.onToggleRow,
    required this.onToggleChar,
  });

  @override
  Widget build(BuildContext context) {
    if (line.rows.length == 1) {
      final rowSection = _KarutaRowSection(
        row: line.rows.first,
        metrics: metrics,
        selected: selected,
        rowFullySelected: isRowFullySelected(line.rows.first),
        rowPartiallySelected: isRowPartiallySelected(line.rows.first),
        onToggleRow: () => onToggleRow(line.rows.first),
        onToggleChar: onToggleChar,
      );

      if (line.alignToSecondaryColumn) {
        return Padding(
          padding: EdgeInsets.only(left: metrics.secondaryColumnOffset),
          child: rowSection,
        );
      }

      return rowSection;
    }

    return SizedBox(
      width: metrics.pairedRowWidth,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: metrics.pairedRowWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: metrics.singleRowWidth,
                child: _KarutaRowSection(
                  row: line.rows[0],
                  metrics: metrics,
                  selected: selected,
                  rowFullySelected: isRowFullySelected(line.rows[0]),
                  rowPartiallySelected: isRowPartiallySelected(line.rows[0]),
                  onToggleRow: () => onToggleRow(line.rows[0]),
                  onToggleChar: onToggleChar,
                ),
              ),
              SizedBox(width: metrics.pairGap),
              SizedBox(
                width: metrics.singleRowWidth,
                child: _KarutaRowSection(
                  row: line.rows[1],
                  metrics: metrics,
                  selected: selected,
                  rowFullySelected: isRowFullySelected(line.rows[1]),
                  rowPartiallySelected: isRowPartiallySelected(line.rows[1]),
                  onToggleRow: () => onToggleRow(line.rows[1]),
                  onToggleChar: onToggleChar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KarutaRowSection extends StatelessWidget {
  final KarutaRow row;
  final KarutaSelectionMetrics metrics;
  final Set<String> selected;
  final bool rowFullySelected;
  final bool rowPartiallySelected;
  final VoidCallback onToggleRow;
  final void Function(String) onToggleChar;

  const _KarutaRowSection({
    required this.row,
    required this.metrics,
    required this.selected,
    required this.rowFullySelected,
    required this.rowPartiallySelected,
    required this.onToggleRow,
    required this.onToggleChar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: metrics.rowButtonWidth,
          height: metrics.tileHeight,
          child: _RowToggleButton(
            label: row.label,
            metrics: metrics,
            fullySelected: rowFullySelected,
            partiallySelected: rowPartiallySelected,
            onTap: onToggleRow,
          ),
        ),
        SizedBox(width: metrics.rowInnerGap),
        if (row.characterSlots != null)
          ..._slottedCharacterTiles(metrics.tileGap)
        else
          ..._sequentialCharacterTiles(metrics.tileGap),
      ],
    );
  }

  List<Widget> _sequentialCharacterTiles(double tileGap) {
    return [
      for (var i = 0; i < row.characters.length; i++) ...[
        if (i > 0) SizedBox(width: tileGap),
        _CharTile(
          character: row.characters[i],
          metrics: metrics,
          selected: selected.contains(row.characters[i]),
          onTap: () => onToggleChar(row.characters[i]),
        ),
      ],
    ];
  }

  List<Widget> _slottedCharacterTiles(double tileGap) {
    final slots = row.characterSlots!;
    final slotMap = {
      for (var i = 0; i < row.characters.length; i++)
        slots[i]: row.characters[i],
    };

    return [
      for (var slot = 0; slot < 5; slot++) ...[
        if (slot > 0) SizedBox(width: tileGap),
        if (slotMap.containsKey(slot))
          _CharTile(
            character: slotMap[slot]!,
            metrics: metrics,
            selected: selected.contains(slotMap[slot]!),
            onTap: () => onToggleChar(slotMap[slot]!),
          )
        else
          SizedBox(width: metrics.tileWidth, height: metrics.tileHeight),
      ],
    ];
  }
}

class _RowToggleButton extends StatelessWidget {
  final String label;
  final KarutaSelectionMetrics metrics;
  final bool fullySelected;
  final bool partiallySelected;
  final VoidCallback onTap;

  const _RowToggleButton({
    required this.label,
    required this.metrics,
    required this.fullySelected,
    required this.partiallySelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fullySelected
          ? const Color(0xFF43A047)
          : partiallySelected
          ? const Color(0xFFC8E6C9)
          : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: 4 * metrics.scale,
            vertical: 4 * metrics.scale,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: fullySelected
                  ? const Color(0xFF2E7D32)
                  : partiallySelected
                  ? const Color(0xFF81C784)
                  : Colors.grey.shade300,
              width: fullySelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: metrics.rowLabelFontSize,
              fontWeight: FontWeight.bold,
              color: fullySelected
                  ? Colors.white
                  : partiallySelected
                  ? const Color(0xFF2E7D32)
                  : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}

class _CharTile extends StatelessWidget {
  final String character;
  final KarutaSelectionMetrics metrics;
  final bool selected;
  final VoidCallback onTap;

  const _CharTile({
    required this.character,
    required this.metrics,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final checkSize = 13.0;

    return Material(
      color: selected ? const Color(0xFFE8F5E9) : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: metrics.tileWidth,
          height: metrics.tileHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? const Color(0xFF43A047) : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  character,
                  style: TextStyle(
                    fontSize: metrics.charFontSize,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                Positioned(
                  right: 1,
                  top: 1,
                  child: Icon(
                    Icons.check_circle,
                    size: checkSize,
                    color: const Color(0xFF43A047),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionSidePanel extends StatelessWidget {
  final int selectedCount;
  final int? targetCount;
  final KarutaLayoutMode layoutMode;
  final ValueChanged<KarutaLayoutMode> onLayoutModeChanged;
  final VoidCallback onStart;

  const _SelectionSidePanel({
    required this.selectedCount,
    required this.targetCount,
    required this.layoutMode,
    required this.onLayoutModeChanged,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final target = targetCount;
    final isComplete = target != null && selectedCount == target;
    final headerText = target == null
        ? 'まいすうを\nえらんでね'
        : '$selectedCount / $targetこ';
    final hintText = target == null
        ? ''
        : isComplete
        ? 'あそべます！'
        : 'あと${target - selectedCount}まい えらんでね';

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        headerText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: KarutaSelectionMetrics.uiFontSize,
                          fontWeight: FontWeight.bold,
                          color: isComplete
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade800,
                        ),
                      ),
                      if (hintText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          hintText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            color: isComplete
                                ? const Color(0xFF43A047)
                                : const Color(0xFFE65100),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        'ならべかた',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: KarutaSelectionMetrics.uiFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _LayoutModeToggle(
                        layoutMode: layoutMode,
                        onChanged: onLayoutModeChanged,
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: isComplete ? onStart : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB74D),
                          disabledBackgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: const Size.fromHeight(40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'ゲーム開始',
                          style: TextStyle(
                            fontSize: KarutaSelectionMetrics.uiFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }
}

class _LayoutModeToggle extends StatelessWidget {
  final KarutaLayoutMode layoutMode;
  final ValueChanged<KarutaLayoutMode> onChanged;

  const _LayoutModeToggle({required this.layoutMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isScatter = layoutMode == KarutaLayoutMode.scatter;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            KarutaLayoutMode.aligned.label,
            style: TextStyle(
              fontSize: KarutaSelectionMetrics.uiFontSize,
              fontWeight: isScatter ? FontWeight.w500 : FontWeight.bold,
              color: isScatter ? Colors.grey.shade600 : const Color(0xFF2E7D32),
            ),
          ),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: isScatter,
              onChanged: (value) => onChanged(
                value ? KarutaLayoutMode.scatter : KarutaLayoutMode.aligned,
              ),
              activeThumbColor: const Color(0xFF43A047),
            ),
          ),
          Text(
            KarutaLayoutMode.scatter.label,
            style: TextStyle(
              fontSize: KarutaSelectionMetrics.uiFontSize,
              fontWeight: isScatter ? FontWeight.bold : FontWeight.w500,
              color: isScatter ? const Color(0xFF2E7D32) : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
