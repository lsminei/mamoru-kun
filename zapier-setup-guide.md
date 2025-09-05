# Zapierを使った簡単なメール通知設定

Edge Functionの設定が難しい場合、Zapierを使って5分で設定できます。

## 設定手順

### 1. Zapierアカウント作成（無料）
1. https://zapier.com にアクセス
2. 無料アカウントを作成

### 2. Supabaseでwebhook設定
1. Supabaseダッシュボードの「Database」→「Database Webhooks」
2. 「Create a new hook」をクリック
3. 以下を設定：
   - Name: `contact-notification`
   - Table: `contacts`
   - Events: ☑ Insert
   - HTTP Headers: そのまま
   - HTTP Method: POST
   - Webhook URL: 次のステップで取得

### 3. Zapier設定
1. Zapierで「Create Zap」
2. **Trigger設定**：
   - App: `Webhooks by Zapier`
   - Event: `Catch Hook`
   - 表示されるWebhook URLをコピー
   - このURLをSupabaseのWebhook URLに貼り付け

3. **Action設定**：
   - App: `Email by Zapier` または `Gmail`
   - Event: `Send Email`
   - To: 管理者のメールアドレス
   - Subject: `【守くん】新規事前登録のお知らせ`
   - Body: 以下のテンプレート

```
新規事前登録がありました！

会社名: {{company}}
お名前: {{name}}
メール: {{email}}
電話番号: {{phone}}
従業員数: {{employees}}
メッセージ: {{message}}
登録日時: {{created_at}}

管理画面で確認:
https://lsminei.github.io/mamoru-kun/admin-dashboard.html
```

4. **Zapをオン**にする

## テスト方法
1. https://lsminei.github.io/mamoru-kun でフォーム送信
2. 設定したメールアドレスに通知が届くことを確認

## メリット
- コード不要
- 5分で設定完了
- 無料プランで月100件まで
- 安定性が高い

これなら技術的な知識なしでも簡単に設定できます！