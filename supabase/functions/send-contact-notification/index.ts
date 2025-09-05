import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // CORS対応
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // リクエストボディから新規登録データを取得
    const { record } = await req.json()
    
    // 管理者メールアドレスを取得
    const { data: admins, error: adminError } = await supabaseClient
      .auth
      .admin
      .listUsers()
    
    if (adminError) throw adminError
    
    // メール送信用のHTMLを作成
    const emailHtml = `
      <!DOCTYPE html>
      <html lang="ja">
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: 'Helvetica Neue', Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #e5ce4b 0%, #f4e08c 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #fff; padding: 30px; border: 1px solid #ddd; border-radius: 0 0 10px 10px; }
          .data-table { width: 100%; margin: 20px 0; }
          .data-table td { padding: 10px; border-bottom: 1px solid #eee; }
          .data-table td:first-child { font-weight: bold; width: 30%; color: #666; }
          .footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; color: #999; font-size: 12px; }
          .button { display: inline-block; padding: 12px 30px; background: linear-gradient(135deg, #e5ce4b 0%, #f4e08c 100%); color: #333; text-decoration: none; border-radius: 5px; font-weight: bold; margin-top: 20px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1 style="margin: 0; color: #333;">🎉 新規事前登録がありました！</h1>
          </div>
          <div class="content">
            <p>守くんに新しい事前登録がありました。</p>
            
            <table class="data-table">
              <tr>
                <td>会社名</td>
                <td>${record.company || '未入力'}</td>
              </tr>
              <tr>
                <td>お名前</td>
                <td>${record.name || '未入力'}</td>
              </tr>
              <tr>
                <td>メールアドレス</td>
                <td>${record.email || '未入力'}</td>
              </tr>
              <tr>
                <td>電話番号</td>
                <td>${record.phone || '未入力'}</td>
              </tr>
              <tr>
                <td>従業員数</td>
                <td>${record.employees || '未入力'}</td>
              </tr>
              <tr>
                <td>メッセージ</td>
                <td>${record.message || '未入力'}</td>
              </tr>
              <tr>
                <td>登録日時</td>
                <td>${new Date(record.created_at).toLocaleString('ja-JP')}</td>
              </tr>
            </table>
            
            <div style="text-align: center;">
              <a href="${Deno.env.get('SITE_URL')}/admin-dashboard.html" class="button">
                管理画面で詳細を確認
              </a>
            </div>
          </div>
          <div class="footer">
            <p>このメールは守くん管理システムから自動送信されています。</p>
          </div>
        </div>
      </body>
      </html>
    `
    
    // 各管理者にメール送信
    const emailPromises = admins.users.map(async (admin) => {
      if (!admin.email) return
      
      const { error } = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${Deno.env.get('RESEND_API_KEY')}`,
        },
        body: JSON.stringify({
          from: '守くん <noreply@mamoru-kun.com>',
          to: [admin.email],
          subject: '【守くん】新規事前登録のお知らせ',
          html: emailHtml,
        }),
      }).then(res => res.json())
      
      if (error) {
        console.error(`Failed to send email to ${admin.email}:`, error)
      }
    })
    
    await Promise.all(emailPromises)
    
    return new Response(
      JSON.stringify({ success: true, message: 'Notifications sent' }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})