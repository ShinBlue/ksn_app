import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'models/word_data.dart';
import 'word_list_source.dart';

/// 公開CSVを取り、失敗したら同梱CSVへ落とす。
class WordListLoader {
  WordListLoader({
    http.Client? client,
    Uri? remoteUri,
    this.loadBundled,
    this.timeout = WordListSource.timeout,
  }) : client = client ?? http.Client(),
       remoteUri = remoteUri ?? WordListSource.csvUri,
       _ownsClient = client == null;

  final http.Client client;
  final Uri? remoteUri;
  final Future<String> Function()? loadBundled;
  final Duration timeout;
  final bool _ownsClient;

  Future<List<WordData>> load() async {
    final uri = remoteUri;
    if (uri != null) {
      try {
        final response = await client.get(uri).timeout(timeout);
        if (response.statusCode == 200) {
          final parsed = WordData.parseCsv(utf8.decode(response.bodyBytes));
          if (parsed.isNotEmpty) {
            return parsed;
          }
        }
      } catch (_) {
        // ネット不通・CORS・タイムアウトは同梱CSVへ。
      }
    }

    final csv = loadBundled != null
        ? await loadBundled!()
        : await rootBundle.loadString(WordListSource.bundledAsset);
    return WordData.parseCsv(csv);
  }

  void dispose() {
    if (_ownsClient) {
      client.close();
    }
  }
}
