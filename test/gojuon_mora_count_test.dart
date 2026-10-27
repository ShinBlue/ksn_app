import 'package:flutter_test/flutter_test.dart';
import 'package:ksn_app/gojuon/utils/mora_count.dart';

void main() {
  test('countMoras handles basic words and youon', () {
    expect(countMoras('あ'), 1);
    expect(countMoras('あか'), 2);
    expect(countMoras('きゃ'), 1);
    expect(countMoras('あした'), 3);
    expect(countMoras('アイス'), 3);
    expect(countMoras('ドアを あける'), 6);
  });
}
