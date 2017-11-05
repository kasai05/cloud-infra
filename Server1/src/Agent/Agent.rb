# ファイル名：agent.rb
# 概要：KVMで動作するAgent
# 役割：キューを使いメッセージを受信し、VirtualMachineの操作を行う
# 実行方法：ruby ./agent.rb "MQサーバのIPアドレス" "待ち受けするキューの名称"
# バージョン：2.0
# 作成者：黒木

require 'json' # hashとjson形式を相互変換できるライブラリ
require 'bunny' # RabbitMQサーバと通信するライブラリ
require './VmController.rb' # VirtualMachineをコントロールするモジュール
require './QueueSender.rb' # キュー送信用クラス

# 引数が足りない場合はエラー終了をする
if ARGV[1].nil? then
	puts " !*!*!*!*!*!*! ARGUMENT ERROR !*!*!*!*!*!*!"
	puts " usage: ruby ./#{__FILE__} MQServerAddress QueueName"
	return -1
end

# 定数を設定
MQADDRESS = ARGV[0] # RabbitMQサーバのIPアドレス
QUEUENAME = ARGV[1] # 待ち受けするキュー名(チャンネル名)

# MQサーバとの接続開始
conn = Bunny.new(:hostname => MQADDRESS, :username => "mquser", :password => "mquser")
conn.start
ch = conn.create_channel
q = ch.queue(QUEUENAME)

begin
	# Queue送信用クラスを用意しておく
	queueSender = QueueSender.new()

	# RabbitMQサーバを監視し、メッセージがキューに入って来たら対応する(繰り返し)
	puts "[*] Waiting for messages. To exit press CTRL+C"
	q.subscribe(:block => true) do |delivery_info, properties, body|
		puts "*****データを受信*****"
		puts "[x]Received " + body

		# JSON形式のキューメッセージをhashに変換する
		hash = JSON.parse(body)

		# メッセージタイプにより以降の処理を振り分ける
		case hash["type"]
		when "create" 
			result = VmController.vmCreate(hash)
		when "start"
			result = VmController.vmStart(hash)
		when "stop"
			result = VmController.vmStop(hash)
		when "destroy"
			result = VmController.vmDestroy(hash)
		when "delete"
			VmController.vmDestroy(hash)
			result = VmController.vmDelete(hash)
		else
			puts "ERROR: Not yet implemented (" + hash["type"] + ")" # 予定にないメッセージタイプの場合はエラーメッセージをresultにする
			result = "NotYetImplemented"
		end

		queueSender.mqAddress = MQADDRESS
		queueSender.queueName = 'response'
		
		hash.store("queueName", "response")
		hash.store("status", "#{result}")
		message = hash.to_json
		queueSender.msg = message
		queueSender.send()
		

		puts "[*] Waiting for messages. To exit press CTRL+C"
	end

# ctrl + c が押された時の処理	
rescue Interrupt => _
	conn.close
	exit(0)
end

