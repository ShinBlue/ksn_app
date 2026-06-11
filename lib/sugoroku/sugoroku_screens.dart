import 'dart:math';

import 'package:flutter/material.dart';

import '../analytics_service.dart';
import '../sound_service.dart';
import 'sugoroku_animal_board_view.dart';
import 'sugoroku_board_view.dart';
import 'sugoroku_boards.dart';
import 'sugoroku_heart_number.dart';
import 'sugoroku_models.dart';
import 'sugoroku_movement.dart';
import 'sugoroku_piece_catalog.dart';

class SugorokuSetupScreen extends StatelessWidget {
  const SugorokuSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFE),
      appBar: AppBar(
        title: const Text('すごろく'),
        backgroundColor: const Color(0xFFE8F5E9),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                '盤面の長さを選んでください',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'マスはバラバラに配置され、矢印でつながります',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              for (final size in SugorokuBoardSize.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SetupCard(
                    title: size.label,
                    subtitle: size == SugorokuBoardSize.short10
                        ? '10マス · コンパクト'
                        : '20マス · 動物いっぱい',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SugorokuGameSetupScreen(size: size),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 盤面プレビュー＋左コマ・右進み方・下スタート
class SugorokuGameSetupScreen extends StatefulWidget {
  final SugorokuBoardSize size;

  const SugorokuGameSetupScreen({super.key, required this.size});

  @override
  State<SugorokuGameSetupScreen> createState() =>
      _SugorokuGameSetupScreenState();
}

class _SugorokuGameSetupScreenState extends State<SugorokuGameSetupScreen> {
  final _random = Random();
  final _sound = SoundService();
  late List<SugorokuCellDef> _cells;

  @override
  void initState() {
    super.initState();
    _cells = List<SugorokuCellDef>.from(
      SugorokuBoardDefaults.cellsFor(widget.size),
    );
  }

  // セットアップ
  bool _isPlaying = false;
  int _assigningPlayer = 0;
  String? _player0CandidateId;
  String? _player1CandidateId;
  SugorokuPlayMode? _selectedMode;

  // ゲーム進行
  List<SugorokuPiece> _pieces = [];
  HiddenNumberBoardState? _hiddenState;
  final _skipNextTurn = <int>{};
  int _activePlayerIndex = 0;
  int? _diceValue;
  int _remainingSteps = 0;
  bool _rolling = false;
  String? _message;
  bool _awaitingAnimalPick = false;
  int? _winnerId;

  int get _cellCount => widget.size.cellCount;
  bool get _isGameOver => _winnerId != null;
  SugorokuPlayMode get _mode => _selectedMode!;
  SugorokuPiece get _activePiece => _pieces[_activePlayerIndex];

  String? get _currentSelection =>
      _assigningPlayer == 0 ? _player0CandidateId : _player1CandidateId;

  Set<String> get _usedIds => {
        if (_player0CandidateId != null) _player0CandidateId!,
        if (_player1CandidateId != null) _player1CandidateId!,
      };

  bool get _canStartSetup =>
      _selectedMode != null &&
      _player0CandidateId != null &&
      _player1CandidateId != null;

  bool get _canPrepareMove =>
      _isPlaying &&
      !_isGameOver &&
      !_rolling &&
      _remainingSteps == 0 &&
      !_awaitingAnimalPick;

  bool get _canTapToAdvance =>
      _isPlaying && !_isGameOver && _remainingSteps > 0 && !_rolling;

  void _selectCandidate(PieceCandidate candidate) {
    if (_isPlaying) return;
    final takenByOther =
        _usedIds.contains(candidate.id) && candidate.id != _currentSelection;
    if (takenByOther) return;

    setState(() {
      if (_assigningPlayer == 0) {
        _player0CandidateId = candidate.id;
      } else {
        _player1CandidateId = candidate.id;
      }
    });
  }

  List<SugorokuPiece> get _displayPieces {
    if (_isPlaying) return _pieces;
    final pieces = <SugorokuPiece>[];
    if (_player0CandidateId != null) {
      pieces.add(
        SugorokuPieceCatalog.candidates
            .firstWhere((c) => c.id == _player0CandidateId)
            .toPiece(0),
      );
    }
    if (_player1CandidateId != null) {
      pieces.add(
        SugorokuPieceCatalog.candidates
            .firstWhere((c) => c.id == _player1CandidateId)
            .toPiece(1),
      );
    }
    return pieces;
  }

  int? get _displaySelectedPieceId =>
      _isPlaying ? _activePlayerIndex : _assigningPlayer;

  void _reshuffleHiddenNumbers() {
    if (_selectedMode != SugorokuPlayMode.hiddenNumber) return;
    _hiddenState = SugorokuHeartNumbers.create(_cellCount, _random);
  }

  Future<void> _editCellLabel(int index) async {
    if (_isPlaying) return;

    final cell = _cells[index];
    final controller = TextEditingController(text: cell.label);
    final defaultCell =
        SugorokuBoardDefaults.defaultCellAt(widget.size, index);

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('マス${index + 1}の文字'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 2,
          maxLength: 12,
          decoration: const InputDecoration(
            hintText: '例：一回休み',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.text = defaultCell.label;
            },
            child: const Text('デフォルト'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (saved == true && mounted) {
      setState(() {
        _cells[index] = cell.copyWith(label: controller.text.trim());
      });
    }
    controller.dispose();
  }

  void _startGame() {
    if (!_canStartSetup || _isPlaying) return;
    final c0 = SugorokuPieceCatalog.candidates
        .firstWhere((c) => c.id == _player0CandidateId);
    final c1 = SugorokuPieceCatalog.candidates
        .firstWhere((c) => c.id == _player1CandidateId);

    setState(() {
      _isPlaying = true;
      _pieces = [c0.toPiece(0), c1.toPiece(1)];
      _activePlayerIndex = 0;
      _diceValue = null;
      _remainingSteps = 0;
      _rolling = false;
      _awaitingAnimalPick = false;
      _winnerId = null;
      _skipNextTurn.clear();
      _reshuffleHiddenNumbers();
      _message = '${_activePiece.name}の番です';
    });
  }

  Future<void> _rollDice() async {
    if (!_canPrepareMove || _mode != SugorokuPlayMode.dice) return;
    if (_consumeSkipTurn()) return;

    setState(() {
      _rolling = true;
      _message = null;
    });

    for (var i = 0; i < 8; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 70));
      if (!mounted) return;
      setState(() => _diceValue = _random.nextInt(6) + 1);
    }

    setState(() {
      _rolling = false;
      _remainingSteps = _diceValue ?? 1;
      _message = '$_remainingStepsが出ました。画面をタップして進めてください';
    });
  }

  void _pickJanken(String hand) {
    if (!_canPrepareMove || _mode != SugorokuPlayMode.janken) return;
    if (_consumeSkipTurn()) return;

    final steps = switch (hand) {
      'グー' => 2,
      'パー' => 3,
      'チョキ' => 2,
      _ => 1,
    };
    final word = switch (hand) {
      'グー' => 'ぐみ',
      'パー' => 'パイン',
      'チョキ' => 'ハサミ',
      _ => hand,
    };

    setState(() {
      _remainingSteps = steps;
      _diceValue = null;
      _message = '$hand → $word（$stepsマス）。画面をタップ';
    });
  }

  void _prepareAnimalPick() {
    if (!_canPrepareMove) return;
    if (_consumeSkipTurn()) return;

    setState(() {
      _awaitingAnimalPick = true;
      _message = _mode == SugorokuPlayMode.hiddenNumber
          ? '数字をタップして動物を当ててください'
          : '動物を選んでください';
    });
  }

  void _onAnimalSelected(AnimalSpot animal) {
    if (!_awaitingAnimalPick || _rolling) return;

    if (_mode == SugorokuPlayMode.hiddenNumber && _hiddenState != null) {
      if (_hiddenState!.isRevealed(animal.index)) return;
      setState(() {
        _hiddenState = _hiddenState!.reveal(animal.index);
      });
    }

    setState(() {
      _awaitingAnimalPick = false;
      _remainingSteps = animal.stepCount;
      _message =
          '${animal.name}（${animal.stepCount}マス）。画面をタップして進めてください';
    });
  }

  bool _consumeSkipTurn() {
    if (_skipNextTurn.remove(_activePiece.id)) {
      setState(() => _message = '${_activePiece.name}は休みです');
      _endTurn();
      return true;
    }
    return false;
  }

  void _tapToAdvance() {
    if (!_canTapToAdvance) return;

    final result = SugorokuMovement.advanceOneStep(
      piece: _activePiece,
      cells: _cells,
      cellCount: _cellCount,
      remainingBefore: _remainingSteps,
      markSkipNextTurn: (id) => _skipNextTurn.add(id),
    );

    setState(() {
      _remainingSteps = result.remaining;
      _message = result.message;
    });

    if (_remainingSteps == 0) {
      if (_activePiece.position >= _cellCount - 1) {
        _declareWinner(_activePiece);
      } else {
        _endTurn();
      }
    }
  }

  void _declareWinner(SugorokuPiece winner) {
    if (_isGameOver) return;

    setState(() {
      _winnerId = winner.id;
      _message = '${winner.name}のかち！';
      _awaitingAnimalPick = false;
      _remainingSteps = 0;
      _diceValue = null;
    });

    _sound.playWin();
    AnalyticsService.instance.logSugorokuComplete(
      boardSize: widget.size.name,
      playMode: _mode.name,
      winnerName: winner.name,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showWinDialog(winner);
    });
  }

  Future<void> _showWinDialog(SugorokuPiece winner) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('ゴール！'),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CandidateIcon(
              candidate: PieceCandidate(
                id: '${winner.id}',
                name: winner.name,
                color: winner.color,
                shape: winner.shape,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${winner.name}のかち！',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('もう一度'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    if (!_isPlaying) return;
    AnalyticsService.instance.logSugorokuReset(
      boardSize: widget.size.name,
      playMode: _mode.name,
    );
    setState(() {
      _winnerId = null;
      _activePlayerIndex = 0;
      _diceValue = null;
      _remainingSteps = 0;
      _rolling = false;
      _awaitingAnimalPick = false;
      _skipNextTurn.clear();
      for (final piece in _pieces) {
        piece.position = 0;
      }
      _reshuffleHiddenNumbers();
      _message = '${_activePiece.name}の番です';
    });
  }

  void _endTurn() {
    if (_isGameOver) return;
    if (_mode == SugorokuPlayMode.hiddenNumber) {
      _reshuffleHiddenNumbers();
    }
    setState(() {
      _awaitingAnimalPick = false;
      _remainingSteps = 0;
      _diceValue = null;
      _activePlayerIndex = _activePlayerIndex == 0 ? 1 : 0;
      if (_message == null || _message!.isEmpty) {
        _message = '${_activePiece.name}の番です';
      }
    });
  }

  Widget _buildBoardCenter() {
    if (!_isPlaying) {
      return _SetupBoardCenter(
        size: widget.size,
        cells: _cells,
        pieces: _displayPieces,
        selectedPieceId: _displaySelectedPieceId,
        canStart: _canStartSetup,
        onStart: _startGame,
        onCellTap: _editCellLabel,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _canTapToAdvance ? _tapToAdvance : null,
      child: _BoardArea(
        size: widget.size,
        cells: _cells,
        pieces: _pieces,
        activePlayerIndex: _activePlayerIndex,
        mode: _mode,
        hiddenState: _hiddenState,
        awaitingAnimalPick: _awaitingAnimalPick,
        canTapAdvance: _canTapToAdvance,
        onAnimalSelected: _onAnimalSelected,
      ),
    );
  }

  Widget _buildLeftPanel() {
    if (!_isPlaying) {
      return _PieceSelectPanel(
        assigningPlayer: _assigningPlayer,
        currentSelection: _currentSelection,
        usedIds: _usedIds,
        player0Selected: _player0CandidateId != null,
        onSelect: _selectCandidate,
        onBackToPlayer1: () => setState(() => _assigningPlayer = 0),
        onGoToPlayer2: () => setState(() => _assigningPlayer = 1),
      );
    }

    return _GamePieceStatusPanel(
      pieces: _pieces,
      activePlayerIndex: _activePlayerIndex,
    );
  }

  Widget _buildRightPanel() {
    if (!_isPlaying) {
      return _ModeSelectPanel(
        selectedMode: _selectedMode,
        onSelect: (mode) => setState(() => _selectedMode = mode),
      );
    }

    return _GameControlPanel(
      mode: _mode,
      message: _message,
      winnerId: _winnerId,
      rolling: _rolling,
      canPrepareMove: _canPrepareMove,
      remainingSteps: _remainingSteps,
      diceValue: _diceValue,
      awaitingAnimalPick: _awaitingAnimalPick,
      onRollDice: _rollDice,
      onJanken: _pickJanken,
      onPrepareAnimalPick: _prepareAnimalPick,
      onReset: _resetGame,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle = _isPlaying
        ? '${widget.size.label} · ${_mode.label}'
        : widget.size.label;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFE),
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: const Color(0xFFE8F5E9),
        actions: [
          if (_isPlaying && _isGameOver)
            TextButton(
              onPressed: _resetGame,
              child: const Text('もう一度'),
            ),
          if (_isPlaying)
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
          final leftPanel = _buildLeftPanel();
          final boardCenter = _buildBoardCenter();
          final rightPanel = _buildRightPanel();

          if (constraints.maxWidth >= 640) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 188, child: leftPanel),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: boardCenter,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(width: 188, child: rightPanel),
                    ],
                  ),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: Column(
                  children: [
                    boardCenter,
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: leftPanel),
                        const SizedBox(width: 8),
                        Expanded(child: rightPanel),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModeSelectPanel extends StatelessWidget {
  final SugorokuPlayMode? selectedMode;
  final ValueChanged<SugorokuPlayMode> onSelect;

  const _ModeSelectPanel({
    required this.selectedMode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '進み方',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '選んでください',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          for (final mode in SugorokuPlayMode.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SideOptionButton(
                title: mode.label,
                subtitle: mode.description,
                selected: selectedMode == mode,
                onTap: () => onSelect(mode),
              ),
            ),
        ],
      ),
    );
  }
}

class _PieceSelectPanel extends StatelessWidget {
  final int assigningPlayer;
  final String? currentSelection;
  final Set<String> usedIds;
  final bool player0Selected;
  final ValueChanged<PieceCandidate> onSelect;
  final VoidCallback onBackToPlayer1;
  final VoidCallback onGoToPlayer2;

  const _PieceSelectPanel({
    required this.assigningPlayer,
    required this.currentSelection,
    required this.usedIds,
    required this.player0Selected,
    required this.onSelect,
    required this.onBackToPlayer1,
    required this.onGoToPlayer2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'コマ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'プレイヤー${assigningPlayer + 1}を選んで',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          for (final candidate in SugorokuPieceCatalog.candidates)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PieceOptionButton(
                candidate: candidate,
                selected: candidate.id == currentSelection,
                disabled: usedIds.contains(candidate.id) &&
                    candidate.id != currentSelection,
                onTap: () => onSelect(candidate),
              ),
            ),
          const SizedBox(height: 8),
          if (assigningPlayer == 1)
            TextButton(
              onPressed: onBackToPlayer1,
              child: const Text('プレイヤー1へ'),
            ),
          if (assigningPlayer == 0 && player0Selected)
            FilledButton(
              onPressed: onGoToPlayer2,
              child: const Text('プレイヤー2へ'),
            ),
        ],
      ),
    );
  }
}

class _SetupBoardCenter extends StatelessWidget {
  final SugorokuBoardSize size;
  final List<SugorokuCellDef> cells;
  final List<SugorokuPiece> pieces;
  final int? selectedPieceId;
  final bool canStart;
  final VoidCallback onStart;
  final ValueChanged<int> onCellTap;

  const _SetupBoardCenter({
    required this.size,
    required this.cells,
    required this.pieces,
    required this.selectedPieceId,
    required this.canStart,
    required this.onStart,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final boardMaxWidth =
        size == SugorokuBoardSize.long20 ? 480.0 : 400.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(0.0, boardMaxWidth)
            : boardMaxWidth;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'マスをタップして文字を入力できます',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              '矢印の順に進みます',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: boardWidth,
              child: SugorokuProgressBoardView(
                size: size,
                cells: cells,
                pieces: pieces,
                selectedPieceId: selectedPieceId,
                compact: true,
                editable: true,
                onCellTap: onCellTap,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: boardWidth * 0.7,
              child: FilledButton.icon(
                onPressed: canStart ? onStart : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'スタート',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF43A047),
                ),
              ),
            ),
            if (!canStart) ...[
              const SizedBox(height: 6),
              Text(
                'コマ・進み方を選ぶとスタートできます',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SideOptionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SideOptionButton({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE8F5E9) : const Color(0xFFF1F8E9),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? const Color(0xFF43A047)
                  : const Color(0xFF66BB6A),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check, size: 16, color: Color(0xFF43A047)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PieceOptionButton extends StatelessWidget {
  final PieceCandidate candidate;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const _PieceOptionButton({
    required this.candidate,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.35 : 1,
      child: Material(
        color: selected ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: disabled ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? const Color(0xFF43A047)
                    : Colors.grey.shade300,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                _CandidateIcon(candidate: candidate),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    candidate.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(Icons.check, size: 16, color: Color(0xFF43A047)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CandidateIcon extends StatelessWidget {
  final PieceCandidate candidate;

  const _CandidateIcon({required this.candidate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _MiniPiecePainter(
          color: candidate.color,
          shape: candidate.shape,
        ),
      ),
    );
  }
}

class _MiniPiecePainter extends CustomPainter {
  final Color color;
  final SugorokuPieceShape shape;

  _MiniPiecePainter({required this.color, required this.shape});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.4;
    final fill = Paint()..color = color;
    final border = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    if (shape == SugorokuPieceShape.circle) {
      canvas.drawCircle(center, r, fill);
      canvas.drawCircle(center, r, border);
    } else {
      final path = Path()
        ..moveTo(center.dx, center.dy - r)
        ..lineTo(center.dx - r, center.dy + r * 0.85)
        ..lineTo(center.dx + r, center.dy + r * 0.85)
        ..close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, border);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniPiecePainter oldDelegate) => false;
}

class _SetupCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SetupCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.casino, color: Color(0xFF66BB6A)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF66BB6A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GamePieceStatusPanel extends StatelessWidget {
  final List<SugorokuPiece> pieces;
  final int activePlayerIndex;

  const _GamePieceStatusPanel({
    required this.pieces,
    required this.activePlayerIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'コマ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          for (final piece in pieces)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  _CandidateIcon(
                    candidate: PieceCandidate(
                      id: '${piece.id}',
                      name: piece.name,
                      color: piece.color,
                      shape: piece.shape,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      piece.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: piece.id == activePlayerIndex
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: piece.id == activePlayerIndex
                            ? Colors.black
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  if (piece.id == activePlayerIndex)
                    const Icon(Icons.play_arrow, size: 16, color: Colors.orange),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GameControlPanel extends StatelessWidget {
  final SugorokuPlayMode mode;
  final String? message;
  final int? winnerId;
  final bool rolling;
  final bool canPrepareMove;
  final int remainingSteps;
  final int? diceValue;
  final bool awaitingAnimalPick;
  final VoidCallback onRollDice;
  final ValueChanged<String> onJanken;
  final VoidCallback onPrepareAnimalPick;
  final VoidCallback onReset;

  const _GameControlPanel({
    required this.mode,
    required this.message,
    required this.winnerId,
    required this.rolling,
    required this.canPrepareMove,
    required this.remainingSteps,
    required this.diceValue,
    required this.awaitingAnimalPick,
    required this.onRollDice,
    required this.onJanken,
    required this.onPrepareAnimalPick,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mode.label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (winnerId != null)
            FilledButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('もう一度'),
            )
          else
            _ModeControls(
              mode: mode,
              rolling: rolling,
              canPrepareMove: canPrepareMove,
              diceValue: diceValue,
              awaitingAnimalPick: awaitingAnimalPick,
              onRollDice: onRollDice,
              onJanken: onJanken,
              onPrepareAnimalPick: onPrepareAnimalPick,
              compact: true,
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 22,
            child: Text(
              remainingSteps > 0 ? 'のこり $remainingSteps マス' : '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFB8C00),
              ),
            ),
          ),
          SizedBox(
            height: 54,
            child: winnerId == null
                ? Text(
                    message ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, height: 1.3),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _BoardArea extends StatelessWidget {
  final SugorokuBoardSize size;
  final List<SugorokuCellDef> cells;
  final List<SugorokuPiece> pieces;
  final int activePlayerIndex;
  final SugorokuPlayMode mode;
  final HiddenNumberBoardState? hiddenState;
  final bool awaitingAnimalPick;
  final bool canTapAdvance;
  final ValueChanged<AnimalSpot> onAnimalSelected;

  const _BoardArea({
    required this.size,
    required this.cells,
    required this.pieces,
    required this.activePlayerIndex,
    required this.mode,
    required this.hiddenState,
    required this.awaitingAnimalPick,
    required this.canTapAdvance,
    required this.onAnimalSelected,
  });

  @override
  Widget build(BuildContext context) {
    final maxBoardWidth =
        size == SugorokuBoardSize.long20 ? 480.0 : 400.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(0.0, maxBoardWidth)
            : maxBoardWidth;

        return SizedBox(
          width: boardWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 38,
                child: AnimatedOpacity(
                  opacity: canTapAdvance ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF176),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF455A64)),
                    ),
                    child: const Text(
                      '画面をタップして1マス進む',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ),
              SugorokuProgressBoardView(
                size: size,
                cells: cells,
                pieces: pieces,
                selectedPieceId: activePlayerIndex,
              ),
              if (mode.usesAnimalBoard) ...[
                const SizedBox(height: 12),
                SugorokuAnimalBoardView(
                  size: size,
                  mode: mode,
                  hiddenState: hiddenState,
                  enabled: awaitingAnimalPick,
                  onAnimalSelected: onAnimalSelected,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ModeControls extends StatelessWidget {
  final SugorokuPlayMode mode;
  final bool rolling;
  final bool canPrepareMove;
  final int? diceValue;
  final bool awaitingAnimalPick;
  final VoidCallback onRollDice;
  final ValueChanged<String> onJanken;
  final VoidCallback onPrepareAnimalPick;
  final bool compact;

  const _ModeControls({
    required this.mode,
    required this.rolling,
    required this.canPrepareMove,
    required this.diceValue,
    required this.awaitingAnimalPick,
    required this.onRollDice,
    required this.onJanken,
    required this.onPrepareAnimalPick,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final diceSize = compact ? 48.0 : 72.0;

    return switch (mode) {
      SugorokuPlayMode.dice => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: diceSize + 8,
              child: diceValue != null
                  ? Center(
                      child: SugorokuDiceFace(value: diceValue!, size: diceSize),
                    )
                  : const SizedBox.shrink(),
            ),
            FilledButton.icon(
              onPressed: canPrepareMove && !rolling ? onRollDice : null,
              icon: Icon(Icons.casino, size: compact ? 18 : 24),
              label: Text(
                rolling ? '振っています…' : 'サイコロ',
                style: TextStyle(fontSize: compact ? 13 : 14),
              ),
            ),
          ],
        ),
      SugorokuPlayMode.janken => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final hand in ['グー', 'チョキ', 'パー'])
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: FilledButton(
                  onPressed: canPrepareMove && !rolling
                      ? () => onJanken(hand)
                      : null,
                  child: Text(hand, style: TextStyle(fontSize: compact ? 13 : 14)),
                ),
              ),
          ],
        ),
      SugorokuPlayMode.animalPick || SugorokuPlayMode.hiddenNumber =>
        FilledButton.icon(
          onPressed:
              canPrepareMove && !rolling && !awaitingAnimalPick
                  ? onPrepareAnimalPick
                  : null,
          icon: Icon(
            mode == SugorokuPlayMode.hiddenNumber
                ? Icons.filter_1
                : Icons.pets,
            size: compact ? 18 : 24,
          ),
          label: Text(
            awaitingAnimalPick
                ? '動物を選んで'
                : mode == SugorokuPlayMode.hiddenNumber
                    ? '数字当て'
                    : '動物を選ぶ',
            style: TextStyle(fontSize: compact ? 13 : 14),
          ),
        ),
    };
  }
}

typedef SugorokuBoardSelectScreen = SugorokuSetupScreen;
