import 'package:flutter/material.dart';
import '../../analytics_service.dart';
import '../../exit_to_kyozai.dart';
import '../excluded_sounds.dart';
import '../models/kana_cell.dart';
import '../models/word_data.dart';
import '../utils/layout_calculator.dart';
import '../widgets/kana_text.dart';
import '../word_list_loader.dart';
import 'word_display_page.dart';

class GojuonTablePage extends StatefulWidget {
  const GojuonTablePage({super.key});

  @override
  State<GojuonTablePage> createState() => _GojuonTablePageState();
}

class _GojuonTablePageState extends State<GojuonTablePage> {
  // 五十音表のトグル状態
  final Map<String, bool> kanaToggles = {};

  // 表示対象の選択状態
  final Map<String, bool> displayTargets = {
    'レベル１': true,
    'レベル２': false,
    'レベル３': false,
    '短文': false,
  };

  // 表示形式の選択状態（ラジオボタン）
  String displayFormat = 'リスト';

  // 選択音カラーのON/OFF状態
  bool enableKanaColor = true;

  // 表示した語の左をクリックして青い枠を付ける
  bool enableBlueFrame = true;

  // 表示した語をクリックして赤い二重丸を付ける
  bool enableRedDoubleCircle = true;

  // 選択された単語・短文をランダムに並べる
  bool enableRandomOrder = false;

  // 入っていたら困る音（設定画面の入力枠）
  final _excludeController = TextEditingController();
  final _excludeFocus = FocusNode();
  var _excludeConfirmed = false;

  // CSVデータを格納するリスト
  List<WordData> wordDataList = [];

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreen('/gojuon');
    _loadCsvData();
  }

  @override
  void dispose() {
    _excludeController.dispose();
    _excludeFocus.dispose();
    super.dispose();
  }

  Future<void> _loadCsvData() async {
    final loader = WordListLoader();
    try {
      final loadedData = await loader.load();
      if (!mounted) return;
      setState(() {
        wordDataList = loadedData;
      });
    } catch (_) {
      // 取得も同梱CSVも失敗したときは空のまま。
    } finally {
      loader.dispose();
    }
  }

  // 五十音表データ
  final List<List<KanaCell>> kanaGrid = [
    // 行1: 清音・濁音・半濁音（あ段）
    [
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'わ', type: 'blue'),
      KanaCell(kana: 'ら', type: 'blue'),
      KanaCell(kana: 'や', type: 'blue'),
      KanaCell(kana: 'ま', type: 'blue'),
      KanaCell(kana: 'ぱ', type: 'handakuten'),
      KanaCell(kana: 'ば', type: 'dakuten'),
      KanaCell(kana: 'は', type: 'blue'),
      KanaCell(kana: 'な', type: 'blue'),
      KanaCell(kana: 'だ', type: 'dakuten'),
      KanaCell(kana: 'た', type: 'blue'),
      KanaCell(kana: 'ざ', type: 'dakuten'),
      KanaCell(kana: 'さ', type: 'blue'),
      KanaCell(kana: 'が', type: 'dakuten'),
      KanaCell(kana: 'か', type: 'blue'),
      KanaCell(kana: 'あ', type: 'blue'),
    ],
    // 行2: い段
    [
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'ん', type: 'blue'),
      KanaCell(kana: 'り', type: 'blue'),
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'み', type: 'blue'),
      KanaCell(kana: 'ぴ', type: 'handakuten'),
      KanaCell(kana: 'び', type: 'dakuten'),
      KanaCell(kana: 'ひ', type: 'blue'),
      KanaCell(kana: 'に', type: 'blue'),
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'ち', type: 'blue'),
      KanaCell(kana: 'じ', type: 'dakuten'),
      KanaCell(kana: 'し', type: 'blue'),
      KanaCell(kana: 'ぎ', type: 'dakuten'),
      KanaCell(kana: 'き', type: 'blue'),
      KanaCell(kana: 'い', type: 'blue'),
    ],
    // 行3: う段
    [
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'っ', type: 'blue'),
      KanaCell(kana: 'る', type: 'blue'),
      KanaCell(kana: 'ゆ', type: 'blue'),
      KanaCell(kana: 'む', type: 'blue'),
      KanaCell(kana: 'ぷ', type: 'handakuten'),
      KanaCell(kana: 'ぶ', type: 'dakuten'),
      KanaCell(kana: 'ふ', type: 'blue'),
      KanaCell(kana: 'ぬ', type: 'blue'),
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'つ', type: 'blue'),
      KanaCell(kana: 'ず', type: 'dakuten'),
      KanaCell(kana: 'す', type: 'blue'),
      KanaCell(kana: 'ぐ', type: 'dakuten'),
      KanaCell(kana: 'く', type: 'blue'),
      KanaCell(kana: 'う', type: 'blue'),
    ],
    // 行4: え段
    [
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: '−', type: 'blue'),
      KanaCell(kana: 'れ', type: 'blue'),
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'め', type: 'blue'),
      KanaCell(kana: 'ぺ', type: 'handakuten'),
      KanaCell(kana: 'べ', type: 'dakuten'),
      KanaCell(kana: 'へ', type: 'blue'),
      KanaCell(kana: 'ね', type: 'blue'),
      KanaCell(kana: 'で', type: 'dakuten'),
      KanaCell(kana: 'て', type: 'blue'),
      KanaCell(kana: 'ぜ', type: 'dakuten'),
      KanaCell(kana: 'せ', type: 'blue'),
      KanaCell(kana: 'げ', type: 'dakuten'),
      KanaCell(kana: 'け', type: 'blue'),
      KanaCell(kana: 'え', type: 'blue'),
    ],
    // 行5: お段
    [
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'ろ', type: 'blue'),
      KanaCell(kana: 'よ', type: 'blue'),
      KanaCell(kana: 'も', type: 'blue'),
      KanaCell(kana: 'ぽ', type: 'handakuten'),
      KanaCell(kana: 'ぼ', type: 'dakuten'),
      KanaCell(kana: 'ほ', type: 'blue'),
      KanaCell(kana: 'の', type: 'blue'),
      KanaCell(kana: 'ど', type: 'dakuten'),
      KanaCell(kana: 'と', type: 'blue'),
      KanaCell(kana: 'ぞ', type: 'dakuten'),
      KanaCell(kana: 'そ', type: 'blue'),
      KanaCell(kana: 'ご', type: 'dakuten'),
      KanaCell(kana: 'こ', type: 'blue'),
      KanaCell(kana: 'お', type: 'blue'),
    ],
    // 拗音 りゃ行
    [
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'りゃ', type: 'blue'),
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'みゃ', type: 'blue'),
      KanaCell(kana: 'ぴゃ', type: 'handakuten'),
      KanaCell(kana: 'びゃ', type: 'dakuten'),
      KanaCell(kana: 'ひゃ', type: 'blue'),
      KanaCell(kana: 'にゃ', type: 'blue'),
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'ちゃ', type: 'blue'),
      KanaCell(kana: 'じゃ', type: 'dakuten'),
      KanaCell(kana: 'しゃ', type: 'blue'),
      KanaCell(kana: 'ぎゃ', type: 'dakuten'),
      KanaCell(kana: 'きゃ', type: 'blue'),
    ],
    // 拗音 りゅ行
    [
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'りゅ', type: 'blue'),
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'みゅ', type: 'blue'),
      KanaCell(kana: 'ぴゅ', type: 'handakuten'),
      KanaCell(kana: 'びゅ', type: 'dakuten'),
      KanaCell(kana: 'ひゅ', type: 'blue'),
      KanaCell(kana: 'にゅ', type: 'blue'),
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'ちゅ', type: 'blue'),
      KanaCell(kana: 'じゅ', type: 'dakuten'),
      KanaCell(kana: 'しゅ', type: 'blue'),
      KanaCell(kana: 'ぎゅ', type: 'dakuten'),
      KanaCell(kana: 'きゅ', type: 'blue'),
    ],
    // 拗音 りょ行
    [
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'りょ', type: 'blue'),
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'みょ', type: 'blue'),
      KanaCell(kana: 'ぴょ', type: 'handakuten'),
      KanaCell(kana: 'びょ', type: 'dakuten'),
      KanaCell(kana: 'ひょ', type: 'blue'),
      KanaCell(kana: 'にょ', type: 'blue'),
      KanaCell(kana: '', type: 'empty'),
      KanaCell(kana: 'ちょ', type: 'blue'),
      KanaCell(kana: 'じょ', type: 'dakuten'),
      KanaCell(kana: 'しょ', type: 'blue'),
      KanaCell(kana: 'ぎょ', type: 'dakuten'),
      KanaCell(kana: 'きょ', type: 'blue'),
    ],
  ];

  void toggleKana(String kana) {
    setState(() {
      kanaToggles[kana] = !(kanaToggles[kana] ?? false);
    });
  }

  // 各段の文字を取得する
  List<String> _getRowKanas(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= kanaGrid.length) {
      return [];
    }
    return kanaGrid[rowIndex]
        .where((cell) => cell.kana.isNotEmpty && cell.type != 'empty')
        .map((cell) => cell.kana)
        .toList();
  }

  // 段全体を選択/解除する
  void toggleRow(int rowIndex) {
    setState(() {
      final kanas = _getRowKanas(rowIndex);
      // その段のすべての文字が選択されているかチェック
      final allSelected =
          kanas.isNotEmpty && kanas.every((kana) => kanaToggles[kana] == true);

      // すべて選択されていれば解除、そうでなければ選択
      for (final kana in kanas) {
        kanaToggles[kana] = !allSelected;
      }
    });
  }

  // 段がすべて選択されているかチェック
  bool _isRowSelected(int rowIndex) {
    final kanas = _getRowKanas(rowIndex);
    if (kanas.isEmpty) return false;
    return kanas.every((kana) => kanaToggles[kana] == true);
  }

  // 各列の文字を取得する（あ段からお段のみ、「ん、っ、ー」を除く）
  List<String> _getColumnKanasForMainSection(int columnIndex) {
    final kanas = <String>[];
    const disabledKanas = ['ん', 'っ', '−'];
    // あ段からお段（行0-4）のみ
    for (int i = 0; i < 5 && i < kanaGrid.length; i++) {
      final row = kanaGrid[i];
      if (columnIndex < row.length) {
        final cell = row[columnIndex];
        if (cell.kana.isNotEmpty &&
            cell.type != 'empty' &&
            !disabledKanas.contains(cell.kana)) {
          kanas.add(cell.kana);
        }
      }
    }
    return kanas;
  }

  // 各列の文字を取得する（拗音のみ、「ん、っ、ー」を除く）
  List<String> _getColumnKanasForYoonSection(int columnIndex) {
    final kanas = <String>[];
    const disabledKanas = ['ん', 'っ', '−'];
    // 拗音（行5以降）のみ
    for (int i = 5; i < kanaGrid.length; i++) {
      final row = kanaGrid[i];
      if (columnIndex < row.length) {
        final cell = row[columnIndex];
        if (cell.kana.isNotEmpty &&
            cell.type != 'empty' &&
            !disabledKanas.contains(cell.kana)) {
          kanas.add(cell.kana);
        }
      }
    }
    return kanas;
  }

  // 列全体を選択/解除する（あ段からお段のみ）
  void toggleColumnForMainSection(int columnIndex) {
    setState(() {
      final kanas = _getColumnKanasForMainSection(columnIndex);
      // その列のすべての文字が選択されているかチェック
      final allSelected =
          kanas.isNotEmpty && kanas.every((kana) => kanaToggles[kana] == true);

      // すべて選択されていれば解除、そうでなければ選択
      for (final kana in kanas) {
        kanaToggles[kana] = !allSelected;
      }
    });
  }

  // 列全体を選択/解除する（拗音のみ）
  void toggleColumnForYoonSection(int columnIndex) {
    setState(() {
      final kanas = _getColumnKanasForYoonSection(columnIndex);
      // その列のすべての文字が選択されているかチェック
      final allSelected =
          kanas.isNotEmpty && kanas.every((kana) => kanaToggles[kana] == true);

      // すべて選択されていれば解除、そうでなければ選択
      for (final kana in kanas) {
        kanaToggles[kana] = !allSelected;
      }
    });
  }

  // 列がすべて選択されているかチェック（あ段からお段のみ）
  bool _isColumnSelectedForMainSection(int columnIndex) {
    final kanas = _getColumnKanasForMainSection(columnIndex);
    if (kanas.isEmpty) return false;
    return kanas.every((kana) => kanaToggles[kana] == true);
  }

  // 列がすべて選択されているかチェック（拗音のみ）
  bool _isColumnSelectedForYoonSection(int columnIndex) {
    final kanas = _getColumnKanasForYoonSection(columnIndex);
    if (kanas.isEmpty) return false;
    return kanas.every((kana) => kanaToggles[kana] == true);
  }

  // 列インデックスから行を判定（あ段のその列の文字から判定）
  String _getRowFromColumnIndex(int columnIndex) {
    if (kanaGrid.isEmpty || columnIndex < 0) return '';
    final firstRow = kanaGrid[0]; // あ段
    if (columnIndex >= firstRow.length) return '';
    final cell = firstRow[columnIndex];
    if (cell.kana.isEmpty) return '';
    // 拗音の場合は最初の文字を取得（例: 'きゃ' -> 'き'）
    return cell.kana[0];
  }

  // 列が黄緑かどうかを判定
  bool _isYellowGreenColumn(int columnIndex) {
    final rowChar = _getRowFromColumnIndex(columnIndex);
    // 黄緑: あ行・さ行・ざ行・な行・ま行・ら行
    const yellowGreenRows = ['あ', 'さ', 'ざ', 'な', 'ま', 'ら'];
    return yellowGreenRows.contains(rowChar);
  }

  Color _getKanaButtonColor(
    int columnIndex,
    bool isActive,
    BuildContext context,
  ) {
    final isYellowGreen = _isYellowGreenColumn(columnIndex);

    if (isYellowGreen) {
      // ビビッドな緑
      return isActive
          ? const Color(0xFF1B5E20) // 濃い緑（アクティブ）
          : const Color(0xFFA5D6A7); // 薄い緑（非アクティブ）
    } else {
      // 黄色
      return isActive
          ? const Color(0xFFFF6F00) // 濃い黄色（アクティブ）
          : const Color(0xFFFFF9C4); // 薄い黄色（非アクティブ）
    }
  }

  Color _getKanaTextColor(
    int columnIndex,
    bool isActive,
    BuildContext context,
  ) {
    final isYellowGreen = _isYellowGreenColumn(columnIndex);

    if (isYellowGreen) {
      // 緑のテキスト色
      return isActive
          ? Colors
                .white // 白（アクティブ）
          : const Color(0xFF558B2F); // 中程度の緑（非アクティブ）
    } else {
      // 黄色のテキスト色
      return isActive
          ? Colors
                .white // 白（アクティブ）
          : const Color(0xFFE65100); // 濃い黄色（非アクティブ）
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ExitToKyozaiScope(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          leading: const ExitToKyozaiButton(),
          title: const Text('ことば表示アプリ'),
          backgroundColor: const Color(0xFFEDE7F6),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewport) {
              final isLandscape = viewport.maxWidth > viewport.maxHeight;
              final firstRow = kanaGrid[0];
              final totalCellCount = firstRow.length;
              final layoutInfo = LayoutCalculator.calculateLayout(
                context,
                totalCellCount,
                availableWidth: viewport.maxWidth - 32,
                availableHeight: viewport.maxHeight - 24,
                scaleFloor: isLandscape ? 0.2 : LayoutCalculator.minScale,
              );

              final table = Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ベースのContainer
                    Container(
                      width: layoutInfo.containerWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: layoutInfo.leftPadding,
                          right: layoutInfo.rightPadding,
                          top: 16,
                          bottom: 16,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // メインコンテンツ
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 列選択チェックボックス（あ段の上）
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Wrap(
                                    spacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      ...kanaGrid[0].asMap().entries.map((
                                        cellEntry,
                                      ) {
                                        final columnIndex = cellEntry.key;
                                        final cell = cellEntry.value;
                                        // 空セルや「ん、っ、ー」の列にはチェックボックスを配置しない
                                        const disabledKanas = ['ん', 'っ', '−'];
                                        if (cell.type == 'empty' ||
                                            disabledKanas.contains(cell.kana)) {
                                          return const SizedBox(
                                            width: 48,
                                            height: 48,
                                          );
                                        }
                                        return SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: Checkbox(
                                            value:
                                                _isColumnSelectedForMainSection(
                                                  columnIndex,
                                                ),
                                            onChanged: (value) {
                                              toggleColumnForMainSection(
                                                columnIndex,
                                              );
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                // 清音・濁音・半濁音 (あ〜お段)
                                ...kanaGrid.take(5).toList().asMap().entries.map(
                                  (entry) {
                                    final row = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Wrap(
                                        spacing: 4,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          ...row.asMap().entries.map((
                                            cellEntry,
                                          ) {
                                            final columnIndex = cellEntry.key;
                                            final cell = cellEntry.value;
                                            if (cell.type == 'empty') {
                                              return const SizedBox(
                                                width: 48,
                                                height: 48,
                                              );
                                            }
                                            final isActive =
                                                kanaToggles[cell.kana] ?? false;
                                            return SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: FilledButton(
                                                onPressed: cell.kana.isNotEmpty
                                                    ? () =>
                                                          toggleKana(cell.kana)
                                                    : null,
                                                style: FilledButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  backgroundColor:
                                                      _getThemeButtonColor(
                                                        columnIndex,
                                                        isActive,
                                                      ),
                                                  foregroundColor:
                                                      _getThemeTextColor(
                                                        columnIndex,
                                                        isActive,
                                                      ),
                                                  elevation: isActive ? 2 : 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                child: KanaText(
                                                  kana: cell.kana,
                                                  fontSize: 22.5,
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                // 拗音セクション
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Column(
                                    children: [
                                      // 列選択チェックボックス（拗音の最初の行の上）
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Wrap(
                                          spacing: 4,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            ...kanaGrid[5].asMap().entries.map((
                                              cellEntry,
                                            ) {
                                              final columnIndex = cellEntry.key;
                                              final cell = cellEntry.value;
                                              // 空セルや「ん、っ、ー」の列にはチェックボックスを配置しない
                                              const disabledKanas = [
                                                'ん',
                                                'っ',
                                                '−',
                                              ];
                                              if (cell.type == 'empty' ||
                                                  disabledKanas.contains(
                                                    cell.kana,
                                                  )) {
                                                return const SizedBox(
                                                  width: 48,
                                                  height: 48,
                                                );
                                              }
                                              return SizedBox(
                                                width: 48,
                                                height: 48,
                                                child: Checkbox(
                                                  value:
                                                      _isColumnSelectedForYoonSection(
                                                        columnIndex,
                                                      ),
                                                  onChanged: (value) {
                                                    toggleColumnForYoonSection(
                                                      columnIndex,
                                                    );
                                                  },
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                      // 拗音の行
                                      ...kanaGrid.skip(5).toList().asMap().entries.map((
                                        entry,
                                      ) {
                                        final row = entry.value;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Wrap(
                                            spacing: 4,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              ...row.asMap().entries.map((
                                                cellEntry,
                                              ) {
                                                final columnIndex =
                                                    cellEntry.key;
                                                final cell = cellEntry.value;
                                                if (cell.type == 'empty') {
                                                  return const SizedBox(
                                                    width: 48,
                                                    height: 48,
                                                  );
                                                }
                                                final isActive =
                                                    kanaToggles[cell.kana] ??
                                                    false;
                                                return SizedBox(
                                                  width: 48,
                                                  height: 48,
                                                  child: FilledButton(
                                                    onPressed:
                                                        cell.kana.isNotEmpty
                                                        ? () => toggleKana(
                                                            cell.kana,
                                                          )
                                                        : null,
                                                    style: FilledButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      backgroundColor:
                                                          _getThemeButtonColor(
                                                            columnIndex,
                                                            isActive,
                                                          ),
                                                      foregroundColor:
                                                          _getThemeTextColor(
                                                            columnIndex,
                                                            isActive,
                                                          ),
                                                      elevation: isActive
                                                          ? 2
                                                          : 0,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                    ),
                                                    child: KanaText(
                                                      kana: cell.kana,
                                                      fontSize: 22.5,
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // 行選択チェックボックス（右端に配置）
                            ...kanaGrid.take(5).toList().asMap().entries.map((
                              entry,
                            ) {
                              final rowIndex = entry.key;
                              // 各チェックボックスのy座標を計算
                              // 列選択チェックボックス行: 高さ48 + padding 8 = 56
                              // 各段のボタンのtop位置を計算
                              final top =
                                  56.0 + // 列選択チェックボックス行
                                  (rowIndex * 56.0); // 各行の高さ48 + padding 8
                              return Positioned(
                                right: 0,
                                top: top + 4, // ボタンの中央に合わせる調整（ボタン48、チェックボックス40）
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Checkbox(
                                    value: _isRowSelected(rowIndex),
                                    onChanged: (value) {
                                      toggleRow(rowIndex);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            // 拗音の行選択チェックボックス（右端に配置）
                            ...kanaGrid.skip(5).toList().asMap().entries.map((
                              entry,
                            ) {
                              final rowIndex = entry.key + 5; // 実際の行インデックス
                              // 各チェックボックスのy座標を計算
                              // 列選択チェックボックス行: 高さ48 + padding 8 = 56
                              // あ段からお段: 5行 × 56 = 280
                              // 拗音セクションとの間隔: 16
                              // 拗音の列選択チェックボックス行: 56
                              final top =
                                  56.0 + // 列選択チェックボックス行
                                  280.0 + // あ段からお段
                                  16.0 + // 拗音セクションとの間隔
                                  56.0 + // 拗音の列選択チェックボックス行
                                  (entry.key * 56.0); // 拗音の各行
                              return Positioned(
                                right: 0,
                                top: top + 4, // ボタンの中央に合わせる調整（ボタン48、チェックボックス40）
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Checkbox(
                                    value: _isRowSelected(rowIndex),
                                    onChanged: (value) {
                                      toggleRow(rowIndex);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    // ベースのContainerと下側のContainerの間に隙間を開ける
                    const SizedBox(height: 16),
                    // ベースのContainerの下に配置するContainer
                    Container(
                      width: layoutInfo.containerWidth,
                      height:
                          layoutInfo.topContainerHeight *
                          LayoutCalculator.bottomContainerHeightRatio,
                      decoration: const BoxDecoration(color: Color(0xFFFFE4CC)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const Text(
                                        '表示対象',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      for (final target in displayTargets.keys)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Checkbox(
                                                value: displayTargets[target],
                                                onChanged: (value) {
                                                  setState(() {
                                                    displayTargets[target] =
                                                        value ?? false;
                                                  });
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              target,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        '表示形式',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      for (final format in ['リスト', '１つずつ'])
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Radio<String>(
                                                value: format,
                                                groupValue: displayFormat,
                                                onChanged: (value) {
                                                  setState(() {
                                                    displayFormat =
                                                        value ?? 'リスト';
                                                  });
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              format,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 28,
                                    runSpacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      _OptionSwitch(
                                        label: '選択音カラー',
                                        value: enableKanaColor,
                                        onChanged: (value) {
                                          setState(() {
                                            enableKanaColor = value;
                                          });
                                        },
                                      ),
                                      _OptionSwitch(
                                        label: '青い枠',
                                        value: enableBlueFrame,
                                        onChanged: (value) {
                                          setState(() {
                                            enableBlueFrame = value;
                                          });
                                        },
                                      ),
                                      _OptionSwitch(
                                        label: '赤い二重丸',
                                        value: enableRedDoubleCircle,
                                        onChanged: (value) {
                                          setState(() {
                                            enableRedDoubleCircle = value;
                                          });
                                        },
                                      ),
                                      _OptionSwitch(
                                        label: 'ランダムに並べる',
                                        value: enableRandomOrder,
                                        onChanged: (value) {
                                          setState(() {
                                            enableRandomOrder = value;
                                          });
                                        },
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '除外する音',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: 160,
                                                child: TextField(
                                                  key: const Key(
                                                    'exclude-sounds-field',
                                                  ),
                                                  controller:
                                                      _excludeController,
                                                  focusNode: _excludeFocus,
                                                  readOnly: _excludeConfirmed,
                                                  onTap: _onExcludeFieldTap,
                                                  style: TextStyle(
                                                    fontWeight:
                                                        _excludeConfirmed
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                        hintText: '例: きくけ　きゃ',
                                                        isDense: true,
                                                        border:
                                                            OutlineInputBorder(),
                                                        contentPadding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 8,
                                                            ),
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              SizedBox(
                                                height: 36,
                                                child: FilledButton(
                                                  key: const Key(
                                                    'exclude-sounds-confirm',
                                                  ),
                                                  onPressed:
                                                      _confirmExcludedSounds,
                                                  style: FilledButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                        ),
                                                  ),
                                                  child: const Text('決定'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 120,
                              height: 100,
                              child: FilledButton(
                                onPressed: _openWordDisplay,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  '表示',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );

              final Widget bodyContent = isLandscape
                  ? SizedBox(
                      width: viewport.maxWidth,
                      height: viewport.maxHeight,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        child: table,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Transform.scale(
                        scale: layoutInfo.scale,
                        alignment: Alignment.center,
                        child: table,
                      ),
                    );

              return Stack(
                children: [
                  Align(alignment: Alignment.center, child: bodyContent),
                  // 画面の左上にlogo.pngを配置
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/gojuon_logo.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // テーマに応じたボタンカラーの取得ヘルパー
  Color _getThemeButtonColor(int columnIndex, bool isActive) {
    return _getKanaButtonColor(columnIndex, isActive, context);
  }

  // テーマに応じたテキストカラーの取得ヘルパー
  Color _getThemeTextColor(int columnIndex, bool isActive) {
    return _getKanaTextColor(columnIndex, isActive, context);
  }

  void _confirmExcludedSounds() {
    setState(() {
      _excludeController.text = ExcludedSounds.displayText(
        _excludeController.text,
      );
      _excludeConfirmed = true;
    });
    _excludeFocus.unfocus();
  }

  void _onExcludeFieldTap() {
    if (!_excludeConfirmed) return;
    setState(() {
      _excludeController.clear();
      _excludeConfirmed = false;
    });
  }

  void _openWordDisplay() {
    final selectedKanas = kanaToggles.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    final selectedLevels = <String>[];
    if (displayTargets['レベル１'] == true) {
      selectedLevels.add('レベル1');
    }
    if (displayTargets['レベル２'] == true) {
      selectedLevels.add('レベル2');
    }
    if (displayTargets['レベル３'] == true) {
      selectedLevels.add('レベル3');
    }

    final includeShortText = displayTargets['短文'] == true;

    if (selectedKanas.isEmpty ||
        (selectedLevels.isEmpty && !includeShortText)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('音または表示対象を選択してください')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordDisplayPage(
          wordDataList: wordDataList,
          selectedKanas: selectedKanas,
          selectedLevels: selectedLevels,
          includeShortText: includeShortText,
          displayFormat: displayFormat,
          enableKanaColor: enableKanaColor,
          enableBlueFrame: enableBlueFrame,
          enableRedDoubleCircle: enableRedDoubleCircle,
          enableRandomOrder: enableRandomOrder,
          excludedSounds: ExcludedSounds.parse(_excludeController.text),
        ),
      ),
    );
  }
}

class _OptionSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _OptionSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 0.85,
              child: Switch(value: value, onChanged: onChanged),
            ),
            Text(value ? 'ON' : 'OFF', style: const TextStyle(fontSize: 13)),
          ],
        ),
      ],
    );
  }
}
