-- contactsテーブルの権限を修正
-- Supabase SQL Editorで実行してください

-- 既存のポリシーを削除（あれば）
DROP POLICY IF EXISTS "Enable read for authenticated users" ON public.contacts;
DROP POLICY IF EXISTS "Enable insert for all users" ON public.contacts;

-- 認証されたユーザー（管理者）が読み取りできるポリシーを作成
CREATE POLICY "Enable read for authenticated users" ON public.contacts
    FOR SELECT
    TO authenticated
    USING (true);

-- 匿名ユーザー（フォーム送信）が挿入できるポリシーを維持
CREATE POLICY "Enable insert for all users" ON public.contacts
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- 権限を再設定
GRANT SELECT ON public.contacts TO authenticated;
GRANT INSERT ON public.contacts TO anon;

-- 成功メッセージ
SELECT 'contactsテーブルの権限を修正しました！管理画面からデータが見えるはずです。' as message;