# デプロイ手順

| 環境 | 用途 | URL | デプロイ方法 |
|------|------|-----|-------------|
| テスト（ステージング） | クライアント確認 | https://shinblue.github.io/ksn_app/ | `main` へ push で **自動** |
| 本番 | 公開 | https://ksn-apps.web.app | GitHub Actions **手動実行** |

---

## 日常の開発フロー

```
1. コードを修正
2. main ブランチへ push
3. テスト URL で確認
4. OK が出たら本番デプロイ（手動）
5. 本番 URL で最終確認
```

---

## テスト環境（GitHub Pages）

### トリガー

- `main` ブランチへの push
- Actions から **Run workflow**（手動）

### ワークフロー

- ファイル: `.github/workflows/deploy.yml`
- ビルド: `flutter build web --base-href /ksn_app/`

### 確認 URL

https://shinblue.github.io/ksn_app/

### 初回セットアップ

GitHub リポジトリ → **Settings** → **Pages** → **Source** を **GitHub Actions** に設定

---

## 本番環境（Firebase Hosting）

### 前提条件（初回のみ）

| Secret 名 | 値 |
|-----------|-----|
| `FIREBASE_PROJECT_ID` | `ksn-apps` |
| `FIREBASE_SERVICE_ACCOUNT` | サービスアカウント JSON の**全文** |

### 本番デプロイ手順

1. テスト環境で確認が完了していること
2. GitHub → **Actions** → **Deploy to Firebase (Production)**
3. **Run workflow** → ブランチ **main** → **Run workflow**

### 確認 URL

https://ksn-apps.web.app

### ワークフロー

- ファイル: `.github/workflows/firebase-production.yml`
- ビルド: `flutter build web --base-href /`

---

## 関連ファイル

| ファイル | 役割 |
|---------|------|
| `.github/workflows/deploy.yml` | テスト（GitHub Pages） |
| `.github/workflows/firebase-production.yml` | 本番（Firebase Hosting） |
| `firebase.json` | Firebase Hosting 設定 |
