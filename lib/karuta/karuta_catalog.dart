import 'karuta_models.dart';

/// CSV の行順に対応する文字（読み札あり・計63文字）
const karutaCsvCharacterOrder = [
  'あ', 'い', 'う', 'え', 'お',
  'こ',
  'さ', 'し', 'す', 'せ', 'そ',
  'た', 'ち', 'つ', 'て', 'と',
  'な', 'に', 'ぬ', 'ね', 'の',
  'は', 'ひ', 'ふ', 'へ', 'ほ',
  'ま', 'み', 'む', 'め', 'も',
  'や', 'ゆ', 'よ',
  'ら', 'り', 'る', 'れ', 'ろ',
  'わ', 'を', 'ん',
  'が', 'ぎ', 'ぐ', 'げ', 'ご', 'ぞ',
  'だ', 'ぢ', 'づ', 'で', 'ど',
  'ば', 'び', 'ぶ', 'べ', 'ぼ',
  'ぱ', 'ぴ', 'ぷ', 'ぺ', 'ぽ',
];

/// 画像はあるが読み札 CSV にない文字（計8文字）
const karutaCharactersWithoutSentence = [
  'か', 'き', 'く', 'け',
  'ざ', 'じ', 'ず', 'ぜ',
];

/// 清音のみ（46文字）
const karutaSeionCharacters = [
  'あ', 'い', 'う', 'え', 'お',
  'か', 'き', 'く', 'け', 'こ',
  'さ', 'し', 'す', 'せ', 'そ',
  'た', 'ち', 'つ', 'て', 'と',
  'な', 'に', 'ぬ', 'ね', 'の',
  'は', 'ひ', 'ふ', 'へ', 'ほ',
  'ま', 'み', 'む', 'め', 'も',
  'や', 'ゆ', 'よ',
  'ら', 'り', 'る', 'れ', 'ろ',
  'わ', 'を', 'ん',
];

const karutaAiueoCharacters = ['あ', 'い', 'う', 'え', 'お'];

/// 濁音のみ（18文字・半濁音・ぢづを除く）
const karutaDakutenCharacters = [
  'が', 'ぎ', 'ぐ', 'げ', 'ご',
  'ざ', 'じ', 'ず', 'ぜ', 'ぞ',
  'だ', 'で', 'ど',
  'ば', 'び', 'ぶ', 'べ', 'ぼ',
];

/// 濁音＋半濁音（23文字）
const karutaVoicedCharacters = [
  ...karutaDakutenCharacters,
  'ぱ', 'ぴ', 'ぷ', 'ぺ', 'ぽ',
];

const karutaAllCharacters = [
  ...karutaSeionCharacters,
  'が', 'ぎ', 'ぐ', 'げ', 'ご',
  'ざ', 'じ', 'ず', 'ぜ', 'ぞ',
  'だ', 'で', 'ど',
  'ば', 'び', 'ぶ', 'べ', 'ぼ',
  'ぱ', 'ぴ', 'ぷ', 'ぺ', 'ぽ',
];

const karutaRows = [
  KarutaRow(label: 'あ行', characters: ['あ', 'い', 'う', 'え', 'お']),
  KarutaRow(label: 'か行', characters: ['か', 'き', 'く', 'け', 'こ']),
  KarutaRow(label: 'が行', characters: ['が', 'ぎ', 'ぐ', 'げ', 'ご']),
  KarutaRow(label: 'さ行', characters: ['さ', 'し', 'す', 'せ', 'そ']),
  KarutaRow(label: 'ざ行', characters: ['ざ', 'じ', 'ず', 'ぜ', 'ぞ']),
  KarutaRow(label: 'た行', characters: ['た', 'ち', 'つ', 'て', 'と']),
  KarutaRow(
    label: 'だ行',
    characters: ['だ', 'で', 'ど'],
    characterSlots: [0, 3, 4],
  ),
  KarutaRow(label: 'な行', characters: ['な', 'に', 'ぬ', 'ね', 'の']),
  KarutaRow(label: 'は行', characters: ['は', 'ひ', 'ふ', 'へ', 'ほ']),
  KarutaRow(label: 'ば行', characters: ['ば', 'び', 'ぶ', 'べ', 'ぼ']),
  KarutaRow(label: 'ぱ行', characters: ['ぱ', 'ぴ', 'ぷ', 'ぺ', 'ぽ']),
  KarutaRow(label: 'ま行', characters: ['ま', 'み', 'む', 'め', 'も']),
  KarutaRow(label: 'や行', characters: ['や', 'ゆ', 'よ']),
  KarutaRow(label: 'ら行', characters: ['ら', 'り', 'る', 'れ', 'ろ']),
  KarutaRow(label: 'わ行', characters: ['わ', 'を', 'ん']),
];

/// 50音表の表示行（清音＋濁音を1行に。ぱ行はば行の下）
final karutaDisplayLines = <KarutaDisplayLine>[
  KarutaDisplayLine(rows: [karutaRows[0]]),
  KarutaDisplayLine(rows: [karutaRows[1], karutaRows[2]]),
  KarutaDisplayLine(rows: [karutaRows[3], karutaRows[4]]),
  KarutaDisplayLine(rows: [karutaRows[5], karutaRows[6]]),
  KarutaDisplayLine(rows: [karutaRows[7]]),
  KarutaDisplayLine(rows: [karutaRows[8], karutaRows[9]]),
  KarutaDisplayLine(
    rows: [karutaRows[10]],
    alignToSecondaryColumn: true,
  ),
  KarutaDisplayLine(rows: [karutaRows[11]]),
  KarutaDisplayLine(rows: [karutaRows[12]]),
  KarutaDisplayLine(rows: [karutaRows[13]]),
  KarutaDisplayLine(rows: [karutaRows[14]]),
];

String karutaImagePath(String character) =>
    'assets/images/カルタデータ/$character.png';
