# メール通知設定ガイド

## 概要
フォームから事前登録があった際に、Supabase Authenticationに登録されている管理者全員にメール通知を送信する機能を設定します。

## 設定手順

### 1. Resendアカウント作成（5分）

1. https://resend.com にアクセス
2. 「Sign up」でアカウント作成
3. メールアドレスを認証
4. ダッシュボードから「API Keys」をクリック
5. 「Create API Key」で新しいAPIキーを作成
6. APIキーをコピー（後で使用）

### 2. Supabase Edge Function設定（10分）

#### A. Supabase CLIインストール
```bash
# macOSの場合
brew install supabase/tap/supabase

# npmの場合
npm install -g supabase
```

#### B. プロジェクトをリンク
```bash
cd /Users/seiyaminei/Desktop/mamorukun
supabase login
supabase link --project-ref koiaoygefbphwhbwdawk
```

#### C. 環境変数設定
Supabaseダッシュボードで：
1. 「Project Settings」→「Edge Functions」
2. 「Add secret」をクリック
3. 以下を追加：
   - `RESEND_API_KEY`: Resendで取得したAPIキー
   - `SITE_URL`: https://lsminei.github.io/mamoru-kun

#### D. Edge Functionをデプロイ
```bash
supabase functions deploy send-contact-notification
```

### 3. データベーストリガー設定（5分）

Supabaseダッシュボードの「SQL Editor」で以下を実行：

```sql
-- 既存のトリガーを削除（もしあれば）
DROP TRIGGER IF EXISTS on_contact_created ON public.contacts;
DROP FUNCTION IF EXISTS notify_new_contact();

-- 新しい連絡先が追加されたときに実行される関数
CREATE OR REPLACE FUNCTION notify_new_contact()
RETURNS trigger AS $$
BEGIN
  -- Edge Functionを呼び出す
  PERFORM
    net.http_post(
      url := 'https://koiaoygefbphwhbwdawk.supabase.co/functions/v1/send-contact-notification',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')
      ),
      body := jsonb_build_object('record', NEW)
    );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- トリガーを作成
CREATE TRIGGER on_contact_created
  AFTER INSERT ON public.contacts
  FOR EACH ROW
  EXECUTE FUNCTION notify_new_contact();

-- HTTPエクステンションを有効化
CREATE EXTENSION IF NOT EXISTS http;

-- pg_net extensionを有効化（Supabaseの新しい推奨方法）
CREATE EXTENSION IF NOT EXISTS pg_net;

-- 成功メッセージ
SELECT 'メール通知トリガーを設定しました！' as message;
```

### 4. 簡易版設定（Supabase CLIを使わない場合）

Supabase CLIのインストールが難しい場合は、Webhookを使用した簡易版も可能です：

#### A. Supabaseダッシュボードで設定
1. 「Database」→「Webhooks」
2. 「Create a new webhook」
3. 以下を設定：
   - Name: `contact-notification`
   - Table: `contacts`
   - Events: `Insert`
   - Webhook URL: 後で設定するZapier/Make/n8nのURL

#### B. Zapierで自動化（無料プランで可能）
1. Zapierアカウント作成
2. 新しいZapを作成
3. Trigger: Webhooks by Zapier → Catch Hook
4. Action: Gmail → Send Email
5. 管理者のメールアドレスを設定

## テスト方法

1. https://lsminei.github.io/mamoru-kun/ でフォーム送信
2. 管理者メールアドレスに通知が届くか確認
3. Supabaseダッシュボードの「Edge Functions」→「Logs」で実行ログを確認

## トラブルシューティング

### メールが届かない場合
1. Resend APIキーが正しく設定されているか確認
2. Supabaseの環境変数を確認
3. Edge Function のログを確認
4. Resendダッシュボードでメール送信ログを確認

### より簡単な代替方法
もしEdge Functionの設定が難しい場合は、以下の代替方法があります：

1. **Googleフォーム通知**（最も簡単）
   - Googleフォームで同じフォームを作成
   - 回答通知をメールで受け取る設定

2. **Supabase Realtime + フロントエンド**
   - 管理画面でリアルタイム更新を実装
   - ブラウザ通知APIを使用

3. **外部サービス連携**
   - Make (Integromat)
   - n8n
   - IFTTT

お好みの方法を選択してください。技術的なサポートが必要な場合はお知らせください。