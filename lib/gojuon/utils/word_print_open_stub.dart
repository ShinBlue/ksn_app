import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

/// 非 Web: システムの印刷ダイアログを開く。
Future<void> openPdfForPrint(Uint8List bytes) {
  return Printing.layoutPdf(
    name: 'kotoba',
    onLayout: (PdfPageFormat format) async => bytes,
  );
}
