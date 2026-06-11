import 'dart:math';

import 'package:flutter/material.dart';

import '../analytics_service.dart';
import 'karuta_grid_layout.dart';
import 'karuta_models.dart';
import 'karuta_repository.dart';
import 'karuta_scatter_layout.dart';

class KarutaGameScreen extends StatefulWidget {
  final List<String> selectedCharacters;
  final KarutaLayoutMode layoutMode;

  const KarutaGameScreen({
    super.key,
    required this.selectedCharacters,
    this.layoutMode = KarutaLayoutMode.scatter,
  });

  @override
  State<KarutaGameScreen> createState() => _KarutaGameScreenState();
}

class _KarutaGameScreenState extends State<KarutaGameScreen> {
  late final List<KarutaCard> _cards;
  final _shuffleRandom = Random();

  @override
  void initState() {
    super.initState();
    _cards = List<KarutaCard>.from(
      KarutaRepository.instance.cardsFor(widget.selectedCharacters),
    )..shuffle(_shuffleRandom);
    AnalyticsService.instance.logScreen('/karuta/game');
    AnalyticsService.instance.logEvent(
      'karuta_game_view',
      params: {
        'card_count': '${_cards.length}',
        'layout_mode': widget.layoutMode.name,
      },
    );
  }

  void _showCardDetail(KarutaCard card) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  card.character,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    card.imagePath,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
                if (card.sentence != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'よみふだ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card.sentence!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Text(
                    'よみふだはまだありません',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFE),
      appBar: AppBar(
        title: Text('カルタ（${_cards.length}まい）'),
        backgroundColor: const Color(0xFFFFF3E0),
      ),
      body: _cards.isEmpty
          ? const Center(child: Text('カルタがえらばれていません'))
          : LayoutBuilder(
              builder: (context, constraints) {
                final area =
                    Size(constraints.maxWidth, constraints.maxHeight);
                final placements = switch (widget.layoutMode) {
                  KarutaLayoutMode.aligned => computeKarutaGridLayout(
                      cards: _cards,
                      area: area,
                    ),
                  KarutaLayoutMode.scatter => computeKarutaScatterLayout(
                      cards: _cards,
                      area: area,
                      random: Random(
                        _cards.length * 1000 +
                            constraints.maxWidth.floor() * 17 +
                            constraints.maxHeight.floor(),
                      ),
                    ),
                };

                return SizedBox.expand(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (final placed in placements)
                        Positioned(
                          left: placed.x,
                          top: placed.y,
                          width: placed.width,
                          height: placed.height,
                          child: _KarutaCardTile(
                            card: placed.card,
                            onTap: () => _showCardDetail(placed.card),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _KarutaCardTile extends StatelessWidget {
  final KarutaCard card;
  final VoidCallback onTap;

  const _KarutaCardTile({
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      shadowColor: Colors.black26,
      clipBehavior: Clip.none,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ColoredBox(
            color: Colors.white,
            child: Image.asset(
              card.imagePath,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              errorBuilder: (_, _, _) => Center(
                child: Text(
                  card.character,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
