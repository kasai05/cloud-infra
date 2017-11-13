#######################
# ファイル名：MessageAPI.rb
# 概要：メッセージ送信API
# 役割：クライアント（cuiまたはgui）から情報取得し、メッセージキューにデータ送信する
# 実行方法：guiでの画面、curlコマンド
# 例: curl -X POST -i http://localhost:9292/api/send -H 'Content-Type:application/json'
# -d '{"queueName":"test_name", "type":"create", "user":"user01", "hostname":"test_host",
# "cpu":"8", "memory":"8", "disk":"256", "publickey":"abcdefghj"}'
# バージョン：1.5
# 作成者：yosuke.kasai

require 'json'
require 'grape'

# require_relative '../dcm/QueueSender.rb'
require_relative '../QueueSender.rb'
require_relative 'Type.rb'

module API
  class MessageQueue < Grape::API

    DEFAULT_QUEUE_NAME = "WebAPI_to_DCM"
    MQ_ADDRESS = "localhost"

    # MQの例外処理
    rescue_from Bunny::Exception do |e|
      error!(e.message, 400)
    end

    # apiの共通処理
    helpers do
      # queue送信インスタンスを作成しメッセージを送信する
      def send_message(address, name, msg)
        sender = QueueSender.new
        sender.mqAddress = address
        sender.queueName = name
        sender.msg = msg

        puts "メッセージ送信処理実行 >> #{sender.msg}"
        sender.send()
      end

      def api_execute(request, apipath, type)
        # httpBody情報をjson形式に変換する
        json = JSON.parse(request)

        msg = ''
        # 各項目の値セット
        if apipath.eql?('/api/create')
          queueName = json['queueName'].empty? ? DEFAULT_QUEUE_NAME : json['queueName']
          user = json['user']
          hostname = json['hostname']
          cpu = json['cpu']
          memory = json['memory']
          disk = json['disk']
          publickey = json['publickey']

          msg = %Q[{"queueName":"#{queueName}","type":"#{type}", "user":"#{user}", "hostname":"#{hostname}",
             "cpu":"#{cpu}","memory":"#{memory}", "disk":"#{disk}", "publickey":"#{publickey}"}]
        else
          queueName = json['queueName'].empty? ? DEFAULT_QUEUE_NAME : json['queueName']
          target = json['uuid']

          msg = %Q[{"queueName":"#{queueName}","type":"#{type}", "uuid":"#{target}"}]
        end

        # queue送信インスタンス作成し、項目値を格納する
        send_message(MQ_ADDRESS, DEFAULT_QUEUE_NAME, msg)

        response = {
          'declared_params': declared(params),
           result: "success."
          }

      end
    end

    # VM作成API
    # 入力項目のバリデーション
    params do
      requires :queueName, type: String
      requires :user, type: String, allow_blank: false
      requires :hostname, type: String, allow_blank: false
      requires :cpu, type: String, allow_blank: false
      requires :memory, type: String, allow_blank: false
      requires :disk, type: String, allow_blank: false
      requires :publickey, type: String, allow_blank: false
    end
    post :create do
      api_execute(request.body.read, request.fullpath, Type::CREATE)
    end

    # インスタンス起動API
    # qs.msg = %Q[{"queueName":"WEBAPI_to_DCM", "type":"start", "uuid":"#{target}"}]
    segment :start do
      params do
        requires :uuid, type: String, allow_blank: false
        requires :queueName, type: String
    end
      put do
        api_execute(request.body.read, request.fullpath, Type::START)
      end
    end

    # インスタンス停止API
    # 想定メッセージ :%Q[{"queueName":"WEBAPI_to_DCM", "type":"stop", "uuid":"#{target}"}]
    params do
      requires :uuid, type: String, allow_blank: false
      requires :queueName, type: String
    end
    put :stop do
      api_execute(request.body.read, request.fullpath, Type::STOP)
    end

    # インスタンス強制削除API
    # 想定メッセージ :%Q[{"queueName":"WEBAPI_to_DCM", "type":"destroy", "uuid":"#{target}"}]
    params do
      requires :uuid, type: String, allow_blank: false
      requires :queueName, type: String
    end
    put :destroy do
      api_execute(request.body.read, request.fullpath, Type::DESTROY)
    end

    # インスタンス削除API
    # 想定メッセージ :%Q[{"queueName":"WEBAPI_to_DCM", "type":"delete", "uuid":"#{target}"}]
    params do
      requires :uuid, type: String, allow_blank: false
      requires :queueName, type: String
    end
    put :delete do
      api_execute(request.body.read, request.fullpath, Type::DElETE)
    end
  end
end
