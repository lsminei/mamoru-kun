# Supabase セットアップガイド

## 1. アカウント作成（2 分）

1. https://supabase.com にアクセス
2. 「Start your project」をクリック
3. GitHub アカウントでサインイン

## 2. プロジェクト作成（2 分）

1. 「New project」をクリック
2. 以下を設定：
   - Organization: Personal（または選択）
   - Project name: `mamoru-kun`
   - Database Password: 強力なパスワードを設定（メモ:M34vsnmaq34iQ"$T）
   - Region: `Northeast Asia (Tokyo)`
3. 「Create new project」をクリック

## 3. テーブル作成（3 分）

1. 左メニューの「Table Editor」をクリック
2. 「Create a new table」をクリック
3. テーブル名: `contacts`
4. 以下の列を追加：
   - `company` (text) - Required
   - `name` (text) - Required
   - `email` (text) - Required
   - `phone` (text) - Optional
   - `message` (text) - Optional
   - `created_at` はデフォルトで自動生成される
5. 「Save」をクリック

## 4. RLS（Row Level Security）設定（1 分）

1. 作成した`contacts`テーブルをクリック
2. 上部の「RLS disabled」をクリック
3. 「Enable RLS」をクリック
4. 「New Policy」→「Get started quickly」
5. 「Enable insert for all users」を選択
6. 「Review」→「Save policy」

## 5. API キー取得（1 分）

1. 左メニューの「Settings」→「API」
2. 以下をコピー：
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public**: `eyJhbGciOiJIUzI1NiIs...`（長い文字列）

## 6. index.html に設定（1 分）

index.html の以下の部分を書き換え：

```javascript
// 変更前
const SUPABASE_URL = "YOUR_SUPABASE_PROJECT_URL";
const SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_KEY";

// 変更後（実際の値を入れる）
const SUPABASE_URL = "https://あなたのプロジェクト.supabase.co";
const SUPABASE_ANON_KEY = "eyJ...長い文字列...";
```

## 7. テスト方法

1. GitHub にプッシュ
2. https://lsminei.github.io/mamoru-kun/ にアクセス
3. フォームに入力して送信
4. Supabase ダッシュボードの「Table Editor」→「contacts」でデータ確認

## トラブルシューティング

- **送信エラーが出る場合**: RLS 設定を確認
- **データが見えない場合**: Table Editor をリフレッシュ
- **API キーエラー**: キーが正しくコピーされているか確認
