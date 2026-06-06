# デプロイ手順

このアプリは **ステージング（クライアント確認用）** と **本番（Firebase Hosting）** の 2 環境で運用します。

| 環境 | 用途 | URL | デプロイ方法 |
|------|------|-----|-------------|
| ステージング | クライアント確認 | https://shinblue.github.io/ksn_app/ | `main` へ push で **自動** |
| 本番 | 公開 | https://ksn-apps.web.app | GitHub Actions **手動実行** |

---

## 日常の開発フロー

```
1. コードを修正
2. main ブランチへ push
3. ステージング URL でクライアントに確認してもらう
4. OK が出たら本番デプロイ（手動）
5. 本番 URL で最終確認
```

---

## ステージング（GitHub Pages）

### トリガー

- `main` ブランチへの push

### ワークフロー

- ファイル: `.github/workflows/deploy.yml`
- ビルド: `flutter build web --base-href /ksn_app/`

### 確認 URL

https://shinblue.github.io/ksn_app/

### 進捗確認

1. GitHub リポジトリ → **Actions** タブ
2. **Deploy to GitHub Pages (Staging)** の実行結果を確認
3. 緑色（✓）になれば反映完了（通常 2〜3 分）

---

## 本番（Firebase Hosting）

### 前提条件（初回のみ）

#### 1. Firebase プロジェクト

| 項目 | 値 |
|------|-----|
| プロジェクト ID | `ksn-apps` |
| 本番 URL | https://ksn-apps.web.app |

#### 2. GitHub Secrets

リポジトリ → **Settings** → **Secrets and variables** → **Actions** → **Repository secrets**

| Secret 名 | 値 |
|-----------|-----|
| `FIREBASE_PROJECT_ID` | `ksn-apps` |
| `FIREBASE_SERVICE_ACCOUNT` | サービスアカウント JSON の**全文** |

**サービスアカウント JSON の取得方法**

1. [Firebase Console](https://console.firebase.google.com/) → プロジェクト **ksn-apps**
2. ⚙️ **プロジェクトの設定** → **サービス アカウント**
3. **新しい秘密鍵の生成** → JSON をダウンロード
4. JSON ファイルの中身をすべて `FIREBASE_SERVICE_ACCOUNT` に貼り付け

> JSON ファイルは Git に commit しないこと。

#### 3. （任意）本番デプロイの承認

**Settings** → **Environments** → **production** を作成し、**Required reviewers** を設定すると、デプロイ前に GitHub 上で承認が必要になります。

---

### 本番デプロイ手順

1. ステージングでクライアント確認が完了していることを確認
2. GitHub リポジトリ → **Actions** タブ
3. 左メニュー **Deploy to Firebase (Production)** を選択
4. 右側 **Run workflow** → ブランチ **main** → **Run workflow**
5. （承認設定がある場合）**Review deployments** → **Approve and deploy**
6. ワークフローが成功（✓）したら本番反映完了

### ワークフロー

- ファイル: `.github/workflows/firebase-production.yml`
- トリガー: **手動のみ**（`workflow_dispatch`）
- ビルド: `flutter build web --base-href /`

### 確認 URL

https://ksn-apps.web.app

---

## ローカルから本番デプロイ（任意）

GitHub Actions を使わずローカルからデプロイする場合:

```bash
# 初回のみ
npm install -g firebase-tools
firebase login --reauth
cp .firebaserc.example .firebaserc   # プロジェクト ID が ksn-apps であることを確認

# デプロイ
flutter build web --base-href /
firebase deploy --only hosting
```

---

## Firebase Analytics の確認

本番・ステージングともに Firebase Analytics で利用状況を計測しています。

| 項目 | 内容 |
|------|------|
| Console | Firebase Console → **ksn-apps** → **Analytics** |
| リアルタイム確認 | **Analytics** → **Realtime** |
| イベント一覧 | **Analytics** → **Events** |
| 環境の区別 | イベントパラメータ `environment`（`staging` / `production`） |

> Analytics データの反映には最大 24〜48 時間かかることがあります。すぐ確認する場合は **Realtime** を使用してください。

---

## トラブルシューティング

### GitHub Pages に反映されない

- Actions の **Deploy to GitHub Pages (Staging)** が失敗していないか確認
- ブラウザのキャッシュをクリア、またはシークレットウィンドウで再読み込み

### Firebase デプロイが失敗する

| エラー | 対処 |
|--------|------|
| 認証エラー | `FIREBASE_SERVICE_ACCOUNT` の JSON を全文で再登録 |
| Project not found | `FIREBASE_PROJECT_ID` が `ksn-apps` か確認 |
| Hosting 未設定 | Firebase Console → **Hosting** → **始める** |

### イラスト画像が 404 になる

- ファイル名は **NFC 形式**（例: `ゴリラ.jpg`）であること
- `lib/illustration_defaults.dart` のパスと実ファイル名が一致しているか確認

---

## 関連ファイル

| ファイル | 役割 |
|---------|------|
| `.github/workflows/deploy.yml` | ステージング自動デプロイ |
| `.github/workflows/firebase-production.yml` | 本番手動デプロイ |
| `firebase.json` | Firebase Hosting 設定 |
| `.firebaserc.example` | ローカル用 Firebase プロジェクト ID テンプレート |
| `lib/firebase_options.dart` | Firebase SDK 設定（FlutterFire CLI で生成） |
