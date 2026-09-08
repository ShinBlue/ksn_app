import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/display_item.dart';
import 'kana_highlight.dart';
import 'word_print_layout.dart';

const ksnPrintOrgName = '一般社団法人 ことばサポートネット';

final _kanaColor = PdfColor.fromInt(0xE53935);

const _wordFontSize = 18.0;
const _shortFontSize = 16.0;
const _minFontSize = 8.0;

/// [preferredFontSize] での文字幅が [maxWidth] を超えるときだけ縮小する。
double fitFontSizeToWidth({
  required double textWidthAtPreferred,
  required double preferredFontSize,
  required double maxWidth,
  double minFontSize = _minFontSize,
}) {
  if (maxWidth <= 0) {
    return minFontSize;
  }
  if (textWidthAtPreferred <= maxWidth) {
    return preferredFontSize;
  }
  final scaled = preferredFontSize * maxWidth / textWidthAtPreferred;
  return scaled.clamp(minFontSize, preferredFontSize);
}

/// 選んだことばの印刷用PDFを生成する。
Future<Uint8List> buildWordPrintPdf({
  required List<DisplayItem> items,
  required Uint8List logoBytes,
  required pw.Font font,
  PdfPageFormat pageFormat = PdfPageFormat.a4,
  int wordColumns = 3,
  String orgName = ksnPrintOrgName,
  bool enableKanaColor = false,
  List<String> selectedKanas = const [],
}) async {
  final rows = buildWordPrintRows(items, wordColumns: wordColumns);
  final logo = pw.MemoryImage(logoBytes);
  final doc = pw.Document();

  pw.Widget buildText(
    String text, {
    required double fontSize,
    required bool isShort,
  }) {
    final align = isShort ? pw.TextAlign.left : pw.TextAlign.center;

    if (!enableKanaColor || selectedKanas.isEmpty) {
      return pw.Text(
        text,
        softWrap: false,
        maxLines: 1,
        textAlign: align,
        style: pw.TextStyle(font: font, fontSize: fontSize),
      );
    }

    return pw.RichText(
      softWrap: false,
      maxLines: 1,
      textAlign: align,
      text: pw.TextSpan(
        children: [
          for (final segment in splitHighlightedSegments(text, selectedKanas))
            pw.TextSpan(
              text: segment.text,
              style: pw.TextStyle(
                font: font,
                fontSize: fontSize,
                color: segment.highlighted ? _kanaColor : PdfColors.black,
              ),
            ),
        ],
      ),
    );
  }

  /// セル幅に収まるよう、必要なときだけその項目のフォントを小さくする。
  pw.Widget cellText(String text, {required bool isShort}) {
    final preferred = isShort ? _shortFontSize : _wordFontSize;

    return pw.LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints?.maxWidth ?? double.infinity;
        final pdfFont = font.getFont(context);
        final textWidth =
            (pdfFont.stringMetrics(text) * preferred).advanceWidth;
        final fontSize = fitFontSizeToWidth(
          textWidthAtPreferred: textWidth,
          preferredFontSize: preferred,
          maxWidth: maxWidth.isFinite ? maxWidth : textWidth,
        );

        return pw.SizedBox(
          width: double.infinity,
          child: buildText(text, fontSize: fontSize, isShort: isShort),
        );
      },
    );
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: pageFormat,
      margin: const pw.EdgeInsets.fromLTRB(36, 40, 36, 52),
      footer: (context) {
        return pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.only(top: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey400, width: 0.6),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Image(logo, height: 22),
              pw.SizedBox(width: 10),
              pw.Text(orgName, style: pw.TextStyle(font: font, fontSize: 11)),
            ],
          ),
        );
      },
      build: (context) {
        final widgets = <pw.Widget>[];

        for (final row in rows) {
          if (row.isShortSentence) {
            widgets.add(
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 6,
                ),
                child: cellText(row.cells.first, isShort: true),
              ),
            );
            continue;
          }

          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 6),
              child: pw.Table(
                columnWidths: {
                  for (var i = 0; i < wordColumns; i++)
                    i: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    verticalAlignment: pw.TableCellVerticalAlignment.middle,
                    children: [
                      for (var i = 0; i < wordColumns; i++)
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          child: i < row.cells.length
                              ? cellText(row.cells[i], isShort: false)
                              : pw.SizedBox(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return widgets;
      },
    ),
  );

  return doc.save();
}
