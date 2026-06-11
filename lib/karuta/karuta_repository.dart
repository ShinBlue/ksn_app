import 'package:flutter/services.dart';

import 'karuta_catalog.dart';
import 'karuta_models.dart';

class KarutaRepository {
  KarutaRepository._();

  static final instance = KarutaRepository._();

  List<KarutaCard>? _allCards;

  Future<void> load() async {
    if (_allCards != null) return;

    final raw = await rootBundle.loadString('assets/data/karuta_sentences.csv');
    final lines = raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final sentences = <String, String>{};
    final dataLines = lines.length > 1 && lines.first == 'かるた文'
        ? lines.sublist(1)
        : lines;

    for (var i = 0;
        i < dataLines.length && i < karutaCsvCharacterOrder.length;
        i++) {
      sentences[karutaCsvCharacterOrder[i]] = dataLines[i];
    }

    _allCards = karutaAllCharacters
        .map(
          (character) => KarutaCard(
            character: character,
            imagePath: karutaImagePath(character),
            sentence: sentences[character],
          ),
        )
        .toList();
  }

  List<KarutaCard> get allCards {
    assert(_allCards != null, 'Call load() first');
    return _allCards!;
  }

  List<KarutaCard> cardsFor(Iterable<String> characters) {
    final selected = characters.toSet();
    return allCards.where((card) => selected.contains(card.character)).toList();
  }
}
