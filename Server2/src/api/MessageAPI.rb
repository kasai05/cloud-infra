# ######################
# ファイル名：MessageAPI.rb
# 概要：メッセージ送信API
# 役割：クライアント（cuiまたはgui）から情報取得し、メッセージキューにデータ送信する
# 実行方法：guiでの画面、curlコマンド
# 例: curl -X POST -i http://localhost:9292/api/send -H 'Content-Type:application/json' -d '{"queueName":"test_name", "type":"create", "user":"user01", "hostname":"test_host", "cpu":"8", "memory":"8", "disk":"256", "publickey":"abcdefghj"}'
# バージョン：1.0
# 作成者：yosuke.kasai

require 'active_record'
require 'json'
require 'grape'

require_relative '../dcm/QueueSender.rb'

class MessageAPI < Grape::API
  format :json
  prefix :api

  # TODO dbアクセスしてvm作成情報を取得する
  get :status do
    response = {
      request_id: 1,
      uuid:'uuid',
      status: "test"
    }
  end

  # メッセージ送信API
  # 入力項目のバリデーション
  params do
    puts "validation start"
    requires :queueName, type: String
    requires :type, type: String
    requires :user, type: String
    requires :hostname, type: String
    requires :cpu, type: String
    requires :memory, type: String
    requires :disk, type: String
    requires :publickey, type: String
  end
  post :send do

    # httpBody情報をjson形式に変換する
    json = JSON.parse(request.body.read)

    # queueNameがなければWebAPI_to_DCMを挿入
    queueName = json['queueName'].empty? ? 'WebAPI_to_DCM' : json['queueName']
    type = json['type']
    user = json['user']
    hostname = json['hostname']
    cpu = json['cpu']
    memory = json['memory']
    disk = json['disk']
    publickey = json['publickey']

    begin
      # queue送信インスタンス作成し、項目値を格納する
      sender = QueueSender.new
      sender.mqAddress = 'localhost'
      sender.queueName = 'WebAPI_to_DCM'
      # sender.msg = %Q[{"type":"#{type}", "user":"#{user}"}]
      sender.msg = %Q[{"queueName":#{queueName}, "type":#{type}, "user":"#{user}", "hostname":"#{hostname}", "cpu":"#{cpu}", "memory":"#{memory}", "disk":"#{disk}", "publickey":"#{publickey}"}]

      puts "メッセージ送信処理実行 >> #{sender.msg}"
      sender.send()
    rescue StandardError
      response = {
        'declared_params': declared(params),
        status: "failed."
      }
    end
    response = {
      'declared_params': declared(params),
      status: "success."
    }
  end

end
