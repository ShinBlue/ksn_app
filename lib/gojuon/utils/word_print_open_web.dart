// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:typed_data';

/// Web: PDF を Blob で開き、ブラウザの PDF ビューアから印刷できるようにする。
///
/// `Printing.layoutPdf` は pdf.js の CDN 読み込みに依存し、本番デプロイ後に
/// 無反応になることがあるため、ネイティブ PDF 表示を使う。
Future<void> openPdfForPrint(Uint8List bytes) async {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
}
