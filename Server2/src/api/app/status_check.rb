#######################
# ファイル名：StatusCheck.rb
# 概要：VM情報取得API
# 役割：ユーザーIDに紐づくVM情報を取得する
# 実行方法：guiでの画面、curlコマンド
# バージョン：2.0
# 作成者：yosuke.kasai

require 'json'
require 'grape'
require 'mysql2'

module API
  class StatusCheck < Grape::API

    SOCKET = "/var/lib/mysql/mysql.sock"
    USERNAME = "root"
    PASSWORD = "group1"
    DBNAME = "IkuraCloud"
    ENCODING = "utf8"

    resource :status do
      # 入力項目のバリデーション
      params do
        requires :userid, type: String, allow_blank: false
      end

      get '/:userid' do
        client = Mysql2::Client.new(
          :socket => SOCKET,
          :username => USERNAME,
          :password => PASSWORD,
          :encoding => ENCODING,
          :database => DBNAME
        )

        statement = client.prepare(
          'select Status, HostName, ExternalPort, CPU, Memory, Disk
           from virtual_machines where userid = ?')
        results = statement.execute(:userid)
        results.to_json
      end
    end
  end
end
