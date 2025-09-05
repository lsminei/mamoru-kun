-- アーカイブ機能を追加するSQL
-- Supabase SQL Editorで実行してください

-- 1. アーカイブ状態を管理するカラムを追加
ALTER TABLE public.contacts 
ADD COLUMN IF NOT EXISTS archived boolean DEFAULT false;

-- 2. アーカイブ日時を記録するカラムを追加
ALTER TABLE public.contacts 
ADD COLUMN IF NOT EXISTS archived_at timestamp with time zone;

-- 3. アーカイブされていないデータを取得するビューを作成（オプション）
CREATE OR REPLACE VIEW active_contacts AS
SELECT * FROM public.contacts
WHERE archived = false OR archived IS NULL;

-- 4. アーカイブ済みデータを取得するビューを作成（オプション）  
CREATE OR REPLACE VIEW archived_contacts AS
SELECT * FROM public.contacts
WHERE archived = true;

-- 5. RLS（Row Level Security）ポリシーを更新
-- 認証されたユーザーがアーカイブ操作できるようにする
CREATE POLICY "Enable update for authenticated users" ON public.contacts
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- 6. 権限を付与
GRANT UPDATE ON public.contacts TO authenticated;

-- 成功メッセージ
SELECT 'アーカイブ機能を追加しました！' as message;