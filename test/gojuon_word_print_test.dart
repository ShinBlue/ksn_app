import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ksn_app/gojuon/models/display_item.dart';
import 'package:ksn_app/gojuon/utils/kana_highlight.dart';
import 'package:ksn_app/gojuon/utils/word_print_layout.dart';
import 'package:ksn_app/gojuon/utils/word_print_pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// 1x1 PNG
final Uint8List _tinyPng = Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('buildWordPrintRows', () {
    test('packs words into rows of three', () {
      final rows = buildWordPrintRows([
        for (var i = 0; i < 5; i++)
          DisplayItem(text: '語$i', isShortSentence: false),
      ]);

      expect(rows, hasLength(2));
      expect(rows[0].isShortSentence, isFalse);
      expect(rows[0].cells, ['語0', '語1', '語2']);
      expect(rows[1].cells, ['語3', '語4']);
    });

    test('puts each short sentence on its own full-width row', () {
      final rows = buildWordPrintRows([
        const DisplayItem(text: 'ドアを あける', isShortSentence: true),
        const DisplayItem(text: '窓を しめる', isShortSentence: true),
      ]);

      expect(rows, hasLength(2));
      expect(rows.every((row) => row.isShortSentence), isTrue);
      expect(rows[0].cells, ['ドアを あける']);
      expect(rows[1].cells, ['窓を しめる']);
    });

    test('flushes pending words before a short sentence', () {
      final rows = buildWordPrintRows([
        const DisplayItem(text: 'あか', isShortSentence: false),
        const DisplayItem(text: 'あお', isShortSentence: false),
        const DisplayItem(text: 'ドアを あける', isShortSentence: true),
        const DisplayItem(text: 'あき', isShortSentence: false),
      ]);

      expect(rows, hasLength(3));
      expect(rows[0].cells, ['あか', 'あお']);
      expect(rows[0].isShortSentence, isFalse);
      expect(rows[1].cells, ['ドアを あける']);
      expect(rows[1].isShortSentence, isTrue);
      expect(rows[2].cells, ['あき']);
    });
  });

  group('splitHighlightedSegments', () {
    test('marks selected target sounds including katakana', () {
      final segments = splitHighlightedSegments('ドアを あける', const ['あ', 'け']);

      expect(segments.map((s) => (s.text, s.highlighted)).toList(), [
        ('ド', false),
        ('ア', true),
        ('を', false),
        (' ', false),
        ('あ', true),
        ('け', true),
        ('る', false),
      ]);
    });
  });

  group('fitFontSizeToWidth', () {
    test('keeps preferred size when text fits', () {
      expect(
        fitFontSizeToWidth(
          textWidthAtPreferred: 100,
          preferredFontSize: 18,
          maxWidth: 120,
        ),
        18,
      );
    });

    test('shrinks only when text would wrap', () {
      expect(
        fitFontSizeToWidth(
          textWidthAtPreferred: 200,
          preferredFontSize: 18,
          maxWidth: 100,
        ),
        9,
      );
    });

    test('does not shrink below the minimum', () {
      expect(
        fitFontSizeToWidth(
          textWidthAtPreferred: 400,
          preferredFontSize: 18,
          maxWidth: 50,
          minFontSize: 8,
        ),
        8,
      );
    });
  });

  group('buildWordPrintPdf', () {
    test('creates a pdf with japanese font embedded', () async {
      final fontData = await rootBundle.load(
        'assets/fonts/NotoSansJP-Regular.ttf',
      );
      final font = pw.Font.ttf(fontData);
      final bytes = await buildWordPrintPdf(
        items: const [
          DisplayItem(text: 'あか', isShortSentence: false),
          DisplayItem(text: 'あお', isShortSentence: false),
          DisplayItem(text: 'あき', isShortSentence: false),
          DisplayItem(text: 'あめ', isShortSentence: false),
          DisplayItem(text: 'ドアを あける', isShortSentence: true),
        ],
        logoBytes: _tinyPng,
        font: font,
        enableKanaColor: true,
        selectedKanas: const ['あ'],
      );

      expect(bytes.length, greaterThan(1000));
      expect(ascii.decode(bytes.take(4).toList()), '%PDF');
    });
  });
}
