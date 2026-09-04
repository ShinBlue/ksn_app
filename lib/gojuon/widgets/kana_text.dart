import 'package:flutter/material.dart';

// 拗音の小文字を下げて表示するウィジェット
class KanaText extends StatelessWidget {
  final String kana;
  final double fontSize;

  const KanaText({super.key, required this.kana, required this.fontSize});

  // 小さいかな（拗音の前半部分）かどうかを判定
  bool _isSmallKana(String char) {
    const smallKana = [
      'ゃ',
      'ゅ',
      'ょ',
      'ぁ',
      'ぃ',
      'ぅ',
      'ぇ',
      'ぉ',
      'っ',
      'ゎ',
      'ャ',
      'ュ',
      'ョ',
      'ァ',
      'ィ',
      'ゥ',
      'ェ',
      'ォ',
      'ッ',
      'ヮ',
    ];
    return smallKana.contains(char);
  }

  @override
  Widget build(BuildContext context) {
    // 2文字で、2文字目が小さいかなの場合は拗音として処理
    if (kana.length == 2 && _isSmallKana(kana[1])) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kana[0],
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
          ),
          Padding(
            padding: EdgeInsets.only(top: fontSize * 0.25),
            child: Text(
              kana[1],
              style: TextStyle(
                fontSize: fontSize * 0.85,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    // 通常の文字はそのまま表示
    return Text(
      kana,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
    );
  }
}
