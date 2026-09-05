import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ksn_app/gojuon/excluded_sounds.dart';
import 'package:ksn_app/gojuon/models/word_data.dart';
import 'package:ksn_app/gojuon/word_list_loader.dart';
import 'package:ksn_app/gojuon/word_list_source.dart';

const _sampleCsv = '''
種類,音,番号,レベル1,レベル2,レベル3
単語,あ,1,あか,ドア,コアラ
短文,あ,1,ドアを あける,,
''';

const _quotedCsv = '''
"種類","音","番号","レベル1","レベル2","レベル3","","",""
"単語","あ","1","あか","ドア","コアラ","","",""
"短文","あ","1","ドアを あける","","","","",""
''';

const _bundledCsv = '''
種類,音,番号,レベル1,レベル2,レベル3
単語,い,1,いぬ,トイレ,ライオン
''';

void main() {
  test('excluded sounds parse concatenated kana and youon', () {
    expect(ExcludedSounds.parse('きくけ'), ['き', 'く', 'け']);
    expect(ExcludedSounds.parse('きゃ しゅ'), ['きゃ', 'しゅ']);
    expect(ExcludedSounds.parse('キ、く'), ['き', 'く']);
    expect(ExcludedSounds.containsAny('あか', ['か']), isTrue);
    expect(ExcludedSounds.containsAny('あめ', ['か']), isFalse);
    expect(ExcludedSounds.containsAny('ドアを あける', ['け']), isTrue);
    expect(ExcludedSounds.parse('きabcく、！きゃ 123'), ['き', 'く', 'きゃ']);
    expect(ExcludedSounds.displayText('きabcく、！きゃ'), 'き く きゃ');
  });

  test('parseCsv reads words and short sentences', () {
    final loaded = WordData.parseCsv(_sampleCsv);
    expect(loaded, [
      WordData(
        type: '単語',
        kana: 'あ',
        number: 1,
        level1: 'あか',
        level2: 'ドア',
        level3: 'コアラ',
      ),
      WordData(type: '短文', kana: 'あ', number: 1, level1: 'ドアを あける'),
    ]);
  });

  test('parseCsv accepts quoted gviz rows and skips blanks', () {
    final loaded = WordData.parseCsv('$_quotedCsv\n\n');
    expect(loaded.length, 2);
    expect(loaded.first.level1, 'あか');
    expect(loaded.last.type, '短文');
  });

  test('word list source has no remote URI until a sheet id is set', () {
    expect(WordListSource.spreadsheetId, isEmpty);
    expect(WordListSource.csvUri, isNull);
  });

  test('word list source builds a gviz csv URI', () {
    final uri = Uri.https(
      'docs.google.com',
      '/spreadsheets/d/sheet-id/gviz/tq',
      {'tqx': 'out:csv', 'gid': '0'},
    );
    expect(uri.queryParameters['tqx'], 'out:csv');
    expect(uri.path, contains('/gviz/tq'));
  });

  test('loader uses remote csv when the request succeeds', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'example.test');
      return http.Response(
        _sampleCsv,
        200,
        headers: const {'content-type': 'text/csv; charset=utf-8'},
      );
    });
    final loader = WordListLoader(
      client: client,
      remoteUri: Uri.parse('https://example.test/words.csv'),
      loadBundled: () async => _bundledCsv,
    );

    final loaded = await loader.load();
    expect(loaded.first.level1, 'あか');
    expect(loaded.any((word) => word.kana == 'い'), isFalse);
  });

  test(
    'public gviz csv is reachable and allows the production origin',
    () async {
      final client = http.Client();
      addTearDown(client.close);
      final uri = Uri.https(
        'docs.google.com',
        '/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/gviz/tq',
        {'tqx': 'out:csv', 'gid': '0'},
      );
      final response = await client.get(
        uri,
        headers: const {'Origin': 'https://ksn-apps.web.app'},
      );
      expect(response.statusCode, 200);
      expect(response.body, contains('Student Name'));
      expect(response.headers['access-control-allow-origin'], isNotNull);
    },
  );

  test('loader falls back to bundled csv when remote fails', () async {
    final client = MockClient((request) async {
      return http.Response('unavailable', 500);
    });
    final loader = WordListLoader(
      client: client,
      remoteUri: Uri.parse('https://example.test/words.csv'),
      loadBundled: () async => _bundledCsv,
    );

    final loaded = await loader.load();
    expect(loaded, [
      WordData(
        type: '単語',
        kana: 'い',
        number: 1,
        level1: 'いぬ',
        level2: 'トイレ',
        level3: 'ライオン',
      ),
    ]);
  });

  test('loader falls back to bundled csv when remote times out', () async {
    final client = MockClient((request) async {
      throw Exception('timeout');
    });
    final loader = WordListLoader(
      client: client,
      remoteUri: Uri.parse('https://example.test/words.csv'),
      loadBundled: () async => _bundledCsv,
    );

    final loaded = await loader.load();
    expect(loaded.single.kana, 'い');
  });
}
