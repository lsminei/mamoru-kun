-- 既存のcontactsテーブルにemployees列を追加するSQL
-- Supabase SQL Editorで実行

-- employees列を追加（既存のテーブルがある場合）
ALTER TABLE public.contacts 
ADD COLUMN IF NOT EXISTS employees TEXT;

-- 成功メッセージ
SELECT 'employees列を追加しました！' as message;