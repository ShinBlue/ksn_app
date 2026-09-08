import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/display_item.dart';
import 'word_print_pdf.dart';

const _logoAsset = 'assets/images/ksn_logo.png';
const _fontAsset = 'assets/fonts/NotoSansJP-Regular.ttf';

Future<pw.Font> loadPrintFont() async {
  final data = await rootBundle.load(_fontAsset);
  return pw.Font.ttf(data);
}

/// 選んだことばをPDFとして生成し、印刷ダイアログを開く。
Future<void> printSelectedWords(
  List<DisplayItem> items, {
  bool enableKanaColor = false,
  List<String> selectedKanas = const [],
}) async {
  final logoData = await rootBundle.load(_logoAsset);
  final logoBytes = logoData.buffer.asUint8List();
  final font = await loadPrintFont();

  await Printing.layoutPdf(
    // ブラウザ印刷ヘッダに出る名前を空にする
    name: '',
    onLayout: (PdfPageFormat format) {
      return buildWordPrintPdf(
        items: items,
        logoBytes: logoBytes,
        font: font,
        pageFormat: format,
        enableKanaColor: enableKanaColor,
        selectedKanas: selectedKanas,
      );
    },
  );
}
