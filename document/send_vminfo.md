FORMAT: 1A
 
# メッセージ送信API
仮想マシンを操作する情報を送信するAPI。
 
## VM情報 [/api/create]
VMの操作に関わる情報を対象に送信する
### VM登録情報送信 [POST]
VM作成に必要な情報をメッセージキュー（Rabbit MQ）に渡します。
 
+ Request
    + Attribute
       + queueName: `WebAPI_to_DCM` (string) - キュー名
       + type: `create` (string, required) - 操作区分
       + user: `ikura-user` (string, required) - ユーザー
       + hostname: `test_host` (string, required) - ホスト名
       + cpu: `1` (string, required) - CPU数
       + memory: `1024` (string, required) - メモリサイズ
       + disk: `256` (string, required) - ディスク容量
       + publickey: `abcdefghj` (string, required) - 公開鍵
     
+ Response 200 (application/json)
    + Attribute
        + declared_params:
                + queueName: `WebAPI_to_DCM`
                + type: `create`
                + user: `ikura-user`
                + hostname: `test_host`
                + cpu: `1`
                + memory: `1024`
                + disk: `256`
                + publickey: `abcdefghj`
        + result: `success` (string) - 送信処理結果
 
+ Response 400
バリデーションエラー
    + Attribute
        + error: `Could not establish TCP connection to any of the configured hosts` (string, required) - エラーメッセージ

+ Response 400
メッセージキューへの接続に失敗した場合
    + Attribute
        + error: `publickey is missing, publickey is empty` (string, required) - エラーメッセージ

+ Response 405
不適切なHTTPメソッドを使用した場合に発生
    + Attribute
        + error: `405 Not Allowed` (string, required) - エラーメッセージ

+ Response 500
上記以外のエラー

## - [/api/start]
### VM起動情報送信 [POST]
VMの起動に必要な情報をメッセージキューに渡します。

+ Request
    + Attribute
       + queueName: `WebAPI_to_DCM` (string) - キュー名
       + type: `create` (string, required) - 操作区分（作成）
       + uuid: `a8feb5a7-a4db-4983-b413-000000000000` (string, required) - VMインスタンスID

## - [/api/stop]
### VM起動情報送信 [POST]
VMの停止に必要な情報をメッセージキューに渡します。

+ Request
    + Attribute
       + queueName: `WebAPI_to_DCM` (string) - キュー名
       + type: `stop` (string, required) - 操作区分（停止）
       + uuid: `a8feb5a7-a4db-4983-b413-000000000000` (string, required) - VMインスタンスID

## - [/api/destory]
### VM強制停止情報送信 [POST]
VMの強制停止に必要な情報をメッセージキューに渡します。

+ Request
    + Attribute
       + queueName: `WebAPI_to_DCM` (string) - キュー名
       + type: `destory` (string, required) - 操作区分（強制停止）
       + uuid: `a8feb5a7-a4db-4983-b413-000000000000` (string, required) - VMインスタンスID


## - [/api/delete]
### VM削除情報送信 [POST]
VMの削除に必要な情報をメッセージキューに渡します。

+ Request
    + Attribute
       + queueName: `WebAPI_to_DCM` (string) - キュー名
       + type: `delete` (string, required) - 操作区分（削除）
       + uuid: `a8feb5a7-a4db-4983-b413-000000000000` (string, required) - VMインスタンスID
