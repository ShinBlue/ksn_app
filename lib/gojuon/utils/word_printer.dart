import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/display_item.dart';
import 'word_print_open_stub.dart'
    if (dart.library.html) 'word_print_open_web.dart' as pdf_open;
import 'word_print_pdf.dart';

const _logoAsset = 'assets/images/ksn_logo.png';
const _fontAsset = 'assets/fonts/NotoSansJP-Regular.ttf';

Future<pw.Font> loadPrintFont() async {
  final data = await rootBundle.load(_fontAsset);
  return pw.Font.ttf(data);
}

/// 選んだことばをPDFとして生成し、印刷ダイアログ（またはPDF表示）を開く。
Future<void> printSelectedWords(
  List<DisplayItem> items, {
  bool enableKanaColor = false,
  List<String> selectedKanas = const [],
}) async {
  final logoData = await rootBundle.load(_logoAsset);
  final logoBytes = logoData.buffer.asUint8List();
  final font = await loadPrintFont();
  final bytes = await buildWordPrintPdf(
    items: items,
    logoBytes: logoBytes,
    font: font,
    enableKanaColor: enableKanaColor,
    selectedKanas: selectedKanas,
  );

  if (kIsWeb) {
    await pdf_open.openPdfForPrint(bytes);
    return;
  }

  await Printing.layoutPdf(
    name: 'kotoba',
    onLayout: (PdfPageFormat format) async => bytes,
  );
}
