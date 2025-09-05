-- シンプルなWebhook設定（SQL Editorで実行）
-- 1行ずつ実行してください

-- 1. 既存を削除
DROP TRIGGER IF EXISTS on_contact_created ON public.contacts;
DROP FUNCTION IF EXISTS notify_new_contact() CASCADE;

-- 2. pg_net有効化
CREATE EXTENSION IF NOT EXISTS pg_net;

-- 3. シンプルな関数（1行で記述）
CREATE OR REPLACE FUNCTION notify_new_contact() RETURNS trigger LANGUAGE plpgsql AS 'BEGIN PERFORM net.http_post(''https://koiaoygefbphwhbwdawk.supabase.co/functions/v1/send-contact-notification'', jsonb_build_object(''Content-Type'', ''application/json'', ''Authorization'', ''Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtvaWFveWdlZmJwaHdoYndkYXdrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY5NzQzMTIsImV4cCI6MjA3MjU1MDMxMn0.u5ysWwErzFVUokjwKzcor1iKrr1zY2C2IVuSbfakWO8''), jsonb_build_object(''record'', row_to_json(NEW))); RETURN NEW; END;';

-- 4. トリガー作成
CREATE TRIGGER on_contact_created AFTER INSERT ON public.contacts FOR EACH ROW EXECUTE FUNCTION notify_new_contact();

-- 5. 確認
SELECT 'Webhook設定完了' as status;