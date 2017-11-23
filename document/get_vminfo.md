FORMAT: 1A
 
# VM情報取得API
仮想マシンを操作する情報を送信するAPI。
 
## VM情報 [/api/status(:user_id)]
対象ユーザーのVMの操作に関わる情報を取得する
### VM情報取得 [GET]
VM作成に必要な情報をDBから取得して返却する。

+ Request
    + Attribute
       + user_id: `00000014` (string, required) - ユーザーID
     
+ Response 200 (application/json)
    + Attribute
        + UserId: `14` (string) - 送信処理結果
        + Status: `started` (string) - 送信処理結果
        + HostName: `hostname_kasai` (string) - 送信処理結果
        + ExternalPort: `52205` (string) - 送信処理結果
        + CPU: `2` (string) - 送信処理結果
        + Memory: `1024` (string) - 送信処理結果
        + Disk: `15` (string) - 送信処理結果

+ Response 405 (application/json)
不適切なHTTPメソッドを使用した場合に発生
    + Attribute
        + error: `405 Not Allowed` (string, required) - エラーメッセージ

+ Response 500 (application/json)
DB接続などそれ以外のエラー
    + Attribute
        + error: `Can't connect to local MySQL server through socket '/var/lib/mysql/mysql.sock` (string, required) - エラーメッセージ
        + backtrace: `/lib/ruby/gems/2.4.0/gems/mysql2-0.4.9/lib/mysql2/client.rb` (string, required) - スタックトレース
