// Google Apps Script - フォームデータをスプレッドシートに保存
// 
// セットアップ手順:
// 1. Google Driveで新しいスプレッドシートを作成
// 2. 拡張機能 → Apps Script を開く
// 3. このコードを貼り付ける
// 4. デプロイ → 新しいデプロイ → ウェブアプリとして公開
// 5. アクセス権限を「全員」に設定
// 6. デプロイ後のURLをindex.htmlのGAS_URLに設定

function doPost(e) {
  try {
    // スプレッドシートのIDを設定（URLから取得）
    // 例: https://docs.google.com/spreadsheets/d/SPREADSHEET_ID/edit
    const SPREADSHEET_ID = 'YOUR_SPREADSHEET_ID';
    
    // スプレッドシートを開く
    const sheet = SpreadsheetApp.openById(SPREADSHEET_ID).getActiveSheet();
    
    // 初回実行時にヘッダーを設定
    if (sheet.getLastRow() === 0) {
      sheet.appendRow([
        'タイムスタンプ',
        '会社名',
        'お名前',
        'メールアドレス',
        '電話番号',
        'ご質問・ご要望'
      ]);
    }
    
    // POSTデータを解析
    const data = JSON.parse(e.postData.contents);
    
    // データを追加
    sheet.appendRow([
      data.timestamp || new Date().toLocaleString('ja-JP'),
      data.company || '',
      data.name || '',
      data.email || '',
      data.phone || '',
      data.message || ''
    ]);
    
    // メール通知を送信（オプション）
    sendNotificationEmail(data);
    
    // 成功レスポンスを返す
    return ContentService
      .createTextOutput(JSON.stringify({
        'result': 'success',
        'message': 'データを保存しました'
      }))
      .setMimeType(ContentService.MimeType.JSON);
      
  } catch (error) {
    // エラーレスポンスを返す
    return ContentService
      .createTextOutput(JSON.stringify({
        'result': 'error',
        'message': error.toString()
      }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

// GET リクエスト用（テスト用）
function doGet(e) {
  return ContentService
    .createTextOutput(JSON.stringify({
      'result': 'success',
      'message': 'GAS is working!'
    }))
    .setMimeType(ContentService.MimeType.JSON);
}

// メール通知機能（オプション）
function sendNotificationEmail(data) {
  // 通知先のメールアドレスを設定
  const NOTIFICATION_EMAIL = 'your-email@example.com';
  
  const subject = '【守くん】新規お問い合わせがありました';
  const body = `
新規お問い合わせを受信しました。

━━━━━━━━━━━━━━━━━━━━
■ お問い合わせ内容
━━━━━━━━━━━━━━━━━━━━

会社名: ${data.company}
お名前: ${data.name}
メールアドレス: ${data.email}
電話番号: ${data.phone || 'なし'}

ご質問・ご要望:
${data.message || 'なし'}

受信日時: ${data.timestamp}

━━━━━━━━━━━━━━━━━━━━

スプレッドシートで詳細を確認:
https://docs.google.com/spreadsheets/d/YOUR_SPREADSHEET_ID
`;
  
  // メールを送信
  // GmailApp.sendEmail(NOTIFICATION_EMAIL, subject, body);
}

// CORSヘッダーを設定（重要）
function doOptions(e) {
  return ContentService
    .createTextOutput('')
    .setMimeType(ContentService.MimeType.TEXT);
}