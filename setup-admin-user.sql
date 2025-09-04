-- Supabase管理者ユーザー設定
-- 
-- 手順:
-- 1. Supabaseダッシュボードの「Authentication」→「Users」
-- 2. 「Invite user」をクリック
-- 3. 管理者のメールアドレスを入力して招待
-- 4. メールが届いたらパスワードを設定
--
-- または以下のSQLで直接ユーザーを作成（SQL Editorで実行）
-- ※ パスワードは後で変更してください

-- 管理者ユーザーの権限設定
-- （既にSupabase Authenticationでユーザー管理されているため、追加のテーブル作成は不要）

-- contactsテーブルへの読み取り権限を確認
GRANT SELECT ON public.contacts TO authenticated;

-- 成功メッセージ
SELECT '管理者権限設定完了！Authentication → Usersから管理者を追加してください' as message;