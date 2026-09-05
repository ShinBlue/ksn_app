/// ことば表示アプリの単語・短文リストの取得元。
///
/// スプレッドシートの作り方:
/// 1. 新規シートを作り、1行目を `種類,音,番号,レベル1,レベル2,レベル3` にする
/// 2. [assets/data/gojuon_words.csv] をインポートする
/// 3. 共有を「リンクを知っている全員が閲覧可」にする
/// 4. URL の `/d/` と `/edit` のあいだを [spreadsheetId] に入れる
/// 5. シートタブの `gid=` を [gid] に入れる（最初のシートはたいてい 0）
///
/// ブラウザからの取得では、リダイレクトのある export URL より
/// gviz の CSV 出力の方が CORS を通しやすい。
abstract final class WordListSource {
  /// 未設定なら同梱CSVだけを使う。
  static const spreadsheetId = '';

  static const gid = '0';

  static const bundledAsset = 'assets/data/gojuon_words.csv';

  static const timeout = Duration(seconds: 5);

  static Uri? get csvUri {
    if (spreadsheetId.isEmpty) return null;
    return Uri.https(
      'docs.google.com',
      '/spreadsheets/d/$spreadsheetId/gviz/tq',
      {'tqx': 'out:csv', 'gid': gid},
    );
  }
}
