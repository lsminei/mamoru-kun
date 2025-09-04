-- Supabase SQL Editor で実行するSQL
-- 1. Supabaseダッシュボードの「SQL Editor」タブをクリック
-- 2. 「New query」をクリック
-- 3. 以下のSQLをコピー＆ペースト
-- 4. 「Run」をクリック

-- contactsテーブルを作成
CREATE TABLE IF NOT EXISTS public.contacts (
    id BIGSERIAL PRIMARY KEY,
    company TEXT NOT NULL,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    employees TEXT NOT NULL,
    phone TEXT,
    message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- RLS (Row Level Security) を有効化
ALTER TABLE public.contacts ENABLE ROW LEVEL SECURITY;

-- 全員がデータを挿入できるポリシーを作成
CREATE POLICY "Enable insert for all users" ON public.contacts
    FOR INSERT
    WITH CHECK (true);

-- テーブルの権限を設定
GRANT INSERT ON public.contacts TO anon;
GRANT SELECT ON public.contacts TO anon;

-- 成功メッセージ
SELECT 'テーブル作成完了！' as message;