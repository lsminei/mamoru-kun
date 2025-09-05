-- メール通知用のトリガー設定
-- Supabase SQL Editorで実行してください

-- 既存のトリガーとFunctionを削除（もしあれば）
DROP TRIGGER IF EXISTS on_contact_created ON public.contacts;
DROP FUNCTION IF EXISTS notify_new_contact() CASCADE;

-- pg_net extensionを有効化（HTTPリクエスト用）
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Edge Functionを呼び出す関数を作成
CREATE OR REPLACE FUNCTION notify_new_contact()
RETURNS trigger AS $$
DECLARE
  request_id bigint;
BEGIN
  -- Edge Functionを非同期で呼び出す
  SELECT net.http_post(
    url := 'https://koiaoygefbphwhbwdawk.supabase.co/functions/v1/send-contact-notification',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtvaWFveWdlZmJwaHdoYndkYXdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY5NzQzMTIsImV4cCI6MjA3MjU1MDMxMn0.u5ysWwErzFVUokjwKzcor1iKrr1zY2C2IVuSbfakWO8'
    )::jsonb,
    body := jsonb_build_object(
      'record', row_to_json(NEW)
    )::jsonb
  ) INTO request_id;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- エラーが発生してもレコードの挿入は続行
    RAISE WARNING 'メール通知送信エラー: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- トリガーを作成
CREATE TRIGGER on_contact_created
  AFTER INSERT ON public.contacts
  FOR EACH ROW
  EXECUTE FUNCTION notify_new_contact();

-- 関数とトリガーが正しく作成されたか確認
SELECT 
  'セットアップ完了！' as status,
  EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'notify_new_contact') as function_exists,
  EXISTS(SELECT 1 FROM pg_trigger WHERE tgname = 'on_contact_created') as trigger_exists;