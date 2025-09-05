-- Supabase Webhook用のシンプルなトリガー設定
-- SQL Editorで実行してください

-- pg_net extensionを有効化（HTTPリクエスト用）
CREATE EXTENSION IF NOT EXISTS pg_net;

-- 新規連絡先追加時にWebhookを呼び出す関数
CREATE OR REPLACE FUNCTION webhook_new_contact()
RETURNS trigger AS $$
DECLARE
  webhook_url text;
  payload jsonb;
BEGIN
  -- WebhookのURL（後で実際のURLに置き換えてください）
  -- 例: Zapier, Make, n8nなどのWebhook URL
  webhook_url := 'YOUR_WEBHOOK_URL_HERE';
  
  -- 送信するデータを準備
  payload := jsonb_build_object(
    'event', 'new_contact',
    'data', jsonb_build_object(
      'id', NEW.id,
      'company', NEW.company,
      'name', NEW.name,
      'email', NEW.email,
      'phone', NEW.phone,
      'employees', NEW.employees,
      'message', NEW.message,
      'created_at', NEW.created_at
    ),
    'timestamp', NOW()
  );
  
  -- HTTPリクエストを送信（非同期）
  PERFORM net.http_post(
    url := webhook_url,
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := payload
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- トリガーを作成
DROP TRIGGER IF EXISTS trigger_webhook_contact ON public.contacts;
CREATE TRIGGER trigger_webhook_contact
  AFTER INSERT ON public.contacts
  FOR EACH ROW
  EXECUTE FUNCTION webhook_new_contact();

-- 成功メッセージ
SELECT 'Webhookトリガーを設定しました。webhook_new_contact関数内のURLを実際のWebhook URLに置き換えてください。' as message;