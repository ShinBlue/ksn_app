# 作業ログ（ksn_app）

2026年6月頃の開発セッションで行った作業内容のまとめ。休眠再開時の参照用。

---

## 目次

1. [すごろくゲーム](#1-すごろくゲーム)
2. [カルタゲーム（新規実装）](#2-カルタゲーム新規実装)
3. [デプロイ](#3-デプロイ)
4. [既知の注意点・修正履歴](#4-既知の注意点修正履歴)
5. [次にやるとよいこと](#5-次にやるとよいこと)

---

## 1. すごろくゲーム

### 概要

メインメニューから「すごろく」を選び、盤面・進み方・コマを設定して2人で遊べる。

### ファイル構成

| パス | 役割 |
|------|------|
| `lib/sugoroku/sugoroku_models.dart` | 盤面サイズ、進み方、コマ、マス定義 |
| `lib/sugoroku/sugoroku_boards.dart` | デフォルトの特殊マス配置 |
| `lib/sugoroku/sugoroku_board_layout.dart` | 散らしたマス座標・矢印描画 |
| `lib/sugoroku/sugoroku_board_view.dart` | 進行用盤面UI（枠付き） |
| `lib/sugoroku/sugoroku_movement.dart` | 移動・マス効果・ゴール判定 |
| `lib/sugoroku/sugoroku_piece_catalog.dart` | コマ候補 |
| `lib/sugoroku/sugoroku_animals.dart` | 動物盤データ（20マス/10マス） |
| `lib/sugoroku/sugoroku_animal_board_view.dart` | 動物選択盤UI |
| `lib/sugoroku/sugoroku_heart_number.dart` | 数字当て用ハート数字 |
| `lib/sugoroku/sugoroku_screens.dart` | セットアップ〜ゲーム画面 |
| `assets/images/盤面/` | 動物盤面画像など |

### ゲームフロー

1. **盤面の長さ** … 10マス / 20マス
2. **セットアップ画面（1画面）** … 左:コマ / 中央:盤面+スタート / 右:進み方
3. **スタート** … 画面遷移なしで同画面のままプレイ開始
4. **プレイ中** … 左:コマ状態 / 中央:盤面 / 右:進み方操作

### 進み方（4種類）

| モード | 内容 |
|--------|------|
| サイコロ | 目の数だけ進む |
| じゃんけん | グー→2、パー→3、チョキ→2 |
| 動物を選ぶ | 動物名の文字数だけ進む |
| 数字当て | 数字をタップして動物を当て、文字数だけ進む |

### 関連コミット

- `804da4b` … すごろくゲーム追加・GitHub Pages デプロイ更新（`main`）

---

## 2. カルタゲーム（新規実装）

### 概要

メインメニュー「カルタ」から、50音表で文字を選び、選んだカードを1画面に表示するゲーム。

- **選択画面** … プリセット・50音表・並べ方・ゲーム開始
- **ゲーム画面** … 選択カードを全件1画面表示（整列 or ランダム配置）

### ファイル構成

| パス | 役割 |
|------|------|
| `lib/karuta/karuta_models.dart` | `KarutaCard`, `KarutaRow`, `KarutaLayoutMode`, `KarutaDisplayLine` |
| `lib/karuta/karuta_catalog.dart` | 文字リスト、行定義、50音表表示行、画像パス |
| `lib/karuta/karuta_repository.dart` | CSV読み込み・カード生成 |
| `lib/karuta/karuta_selection_screen.dart` | 50音選択UI（プリセット・右パネル） |
| `lib/karuta/karuta_game_screen.dart` | ゲーム画面（シャッフル・タップで詳細） |
| `lib/karuta/karuta_grid_layout.dart` | 整列グリッド配置 |
| `lib/karuta/karuta_scatter_layout.dart` | ランダム散らし配置 |
| `lib/main_menu_screen.dart` | メニューからカルタ選択画面へ遷移 |
| `assets/data/karuta_sentences.csv` | 読み札テキスト（63行） |
| `assets/images/カルタデータ/{文字}.png` | カルタ画像（71枚） |

### データ設計

#### 文字の分類

| 区分 | 件数 | 内容 |
|------|------|------|
| 清音 | 46 | `karutaSeionCharacters` |
| 濁音のみ | 18 | `karutaDakutenCharacters`（半濁音・ぢづ除く） |
| 濁音＋半濁音 | 23 | `karutaVoicedCharacters` |
| 全部（ゲーム対象） | 69 | 清音46 + 濁半濁23（**ぢ・づは除外**） |
| CSV読み札あり | 63 | `karutaCsvCharacterOrder` |
| 画像のみ（読み札なし） | 8 | かきくけ・ざじずぜ |

#### 画像パス

```
assets/images/カルタデータ/{文字}.png
```

#### CSV

- `assets/data/karuta_sentences.csv`
- `pubspec.yaml` にアセット登録済み
- 読み札がない文字は `sentence: null` でカード表示（詳細シートでは読み札欄非表示）

### 選択画面 UI

#### 全体レイアウト

```
┌─────────────────────────────┬──────────┐
│ プリセット（1行・横スクロール可）      │          │
│ （18px 余白）                          │  右パネル │
│ 50音表（11行・スクロールなし）         │  ○こえらび│
│  か行｜が行 のように清濁ペア            │  ならべかた│
│  ぱ行はば行の真下（右列揃え）           │  整列/ランダム│
│                                         │  ゲーム開始│
└─────────────────────────────┴──────────┘
```

- **左**: プリセット + 50音表（`karutaDisplayLines`）
- **右**: 操作パネルのみ参考デザインに合わせてコンパクト化（プレビュー文字一覧なし）

#### プリセット（トグル式）

| ボタン | 内容 |
|--------|------|
| あいうえお | 5文字 |
| 清音だけ | 46文字 |
| 濁音だけ | 18文字 |
| 濁音・半濁音 | 23文字 |
| 全部 | 69文字 |
| 全部解除 | 常時クリア（トグルではない） |

- フォント 12px、パディング 横12/縦8
- プリセットとあ行の間は **18px**（当初6pxの3倍）

#### 50音表の表示ルール

- 清音と濁音は **同一行にペア表示**（例: か行｜が行）
- 濁音行は清音行の右に配置（`pairGap` で間隔）
- **ぱ行** は **ば行の真下**、右列（濁音列）に揃え（`alignToSecondaryColumn: true`）
- **だ行** は `characterSlots: [0, 3, 4]` で **だ・で・どのみ** 表示（ぢ・づは非表示）
- 各行左端揃え、画面高に合わせてスケール（`KarutaSelectionMetrics.fit`）

#### 右パネル

1. `○こ えらび`（選択数）
2. `ならべかた`
3. **整列** / **ランダム**（縦並びトグル）
4. **ゲーム開始**（ランダムの直下）

### ゲーム画面

| 項目 | 内容 |
|------|------|
| カード順 | 開始時にシャッフル |
| 整列モード | `karuta_grid_layout.dart` … グリッドで1画面に収める |
| ランダムモード | `karuta_scatter_layout.dart` … ランダム座標で散らし |
| カード表示 | `BoxFit.contain`（上端切れ対策済み） |
| タップ | ボトムシートで文字・画像・読み札表示 |
| Analytics | `karuta_game_view`（card_count, layout_mode） |

### 画面遷移

```
メインメニュー
  └─ カルタ（KarutaSelectionScreen）
       └─ ゲーム開始 → KarutaGameScreen
```

- Route: `/karuta/select`, `/karuta/game`
- Analytics: `logMainMenuSelect('karuta')`

### 修正した問題（カルタ）

| 問題 | 対応 |
|------|------|
| カード上端が切れる | `BoxFit.cover` → `BoxFit.contain` |
| 50音表の横オーバーフロー（約10px） | メトリクス計算のギャップと描画ギャップを統一（5px） |
| プリセット過大 | フォント11px・1行Row（狭い画面は横スクロール） |
| 全体レイアウトを誤って変更 | 50音表は左カラムのまま、**右カラムのみ**参考デザインに合わせて復元 |
| プリセットとあ行が近い | 間隔 6px → 18px、ボタンをやや拡大（12px/パディング増） |

---

## 3. デプロイ

詳細は `docs/DEPLOY.md` を参照。

| 環境 | 用途 | URL | 方法 |
|------|------|-----|------|
| **テスト** | クライアント確認 | https://shinblue.github.io/ksn_app/ | `main` push → **自動** |
| **本番** | 公開 | https://ksn-apps.web.app | Actions **手動** |

### ワークフロー

- `.github/workflows/deploy.yml` … GitHub Pages（Staging）
- `.github/workflows/firebase-production.yml` … Firebase Hosting（Production）

### 日常フロー

```
1. コード修正
2. main へ push
3. テスト URL で確認
4. OK なら本番デプロイ（手動）
```

### GitHub Pages 初回設定

リポジトリ **Settings → Pages → Source** を **GitHub Actions** に設定すること。

---

## 4. 既知の注意点・修正履歴

### すごろく

| 問題 | 対応 |
|------|------|
| コマ移動で盤面がずれる | 左右パネル高さ固定・タップ案内の常時スペース・上揃えレイアウト |
| 20マス盤の RenderFlex overflow | マス座標インセット・clip・aspectRatio 0.72・cellFraction 0.11 |
| 2コマ同マスで overflow | FittedBox・2コマ時は小さめ表示 |
| スタート後に画面遷移 | `SugorokuGameSetupScreen` 1画面で `_isPlaying` 切替 |

### カルタ

| 問題 | 対応 |
|------|------|
| カード上端切れ | `BoxFit.contain` |
| 50音表 overflow | ギャップ値の統一・ペア行に `FittedBox` + 幅固定 |
| 右パネルが大きすぎる | プレビュー削除・コンパクトColumn |

---

## 5. 次にやるとよいこと

### カルタ（優先）

- [ ] 読み音声アセットの追加・再生（`assets/sounds/karuta/{文字}.wav` 等）
- [ ] カルタ本体の遊び方（取り合い・読み上げ連動など）の実装
- [ ] 実機・タブレットでの50音表レイアウト確認
- [ ] 読み札なし8文字（かきくけ・ざじずぜ）のCSV追加検討

### すごろく

- [ ] 実機・タブレットでのレイアウト確認
- [ ] マスの効果も編集できるようにする（任意）
- [ ] 3人以上対応（任意）

### デプロイ

- [ ] テスト環境（GitHub Pages）でカルタ動作確認
- [ ] 問題なければ本番 Firebase 手動デプロイ

---

## 6. 関連コミット（時系列）

| コミット | 内容 |
|---------|------|
| `804da4b` | すごろくゲーム追加・GitHub Pages デプロイ更新 |
| （次コミット） | カルタゲーム実装（50音選択・ゲーム画面・CSV・メニュー連携） |

---

*最終更新: 2026-06-11（カルタ実装・デプロイ前）*
