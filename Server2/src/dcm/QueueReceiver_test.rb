# ファイル名：QueueReceiver_test.rb
# 概要：Queueメッセージ確認用スクリプト
# 役割：Queueメッセージに何を格納しているか確認するためのテストスクリプト
# 実行方法：ruby ./QueueReceiver_test.rb "MQサーバのIPアドレス" ("待ち受けするキューの名称")
# バージョン：1.0
# 作成者：黒木


require 'json'										# json形式とhash形式を相互に変換するライブラリ
require 'bunny'										# RabbitMQサーバとの通信で使用するライブラリ


# 引数が足りない場合はエラー終了をする
if ARGV[1].nil? then
	puts " !*!*!*!*!*!*! ARGUMENT ERROR !*!*!*!*!*!*!"
	puts " usage: ruby ./#{__FILE__} MQServerAddress QueueName"
		puts " QueueName is optional. (default is 'WebAPI_to_DCM')"
	return -1
end

# 定数を設定
MQADDRESS = ARGV[0] # RabbitMQサーバのIPアドレス
ARGV[1].nil? ? QUEUENAME = "WebAPI_to_DCM" : QUEUENAME = ARGV[1] # 待ち受けするキュー名。デフォルトは「WebAPI_to_DCM」


# RabbitMQサーバと接続
conn = Bunny.new(:hostname => MQADDRESS, :username => "mquser", :password => "mquser")
conn.start
ch = conn.create_channel
q = ch.queue(QUEUENAME)


begin
	puts "[*] Waiting for messages. To exit press CTRL+C"

	# キューメッセージの待ち受け開始
	q.subscribe(:block => true) do |delivery_info, properties, body|
		puts "***** Received a Message *****"
		puts "[x]Received " + body
		hash = JSON.parse(body)  # 受信したJSON形式のメッセージをhash形式に変換

		hash.each do |key, value|
                  puts "#{key}\t#{value}"
                end

		puts "[*] Waiting for messages. To exit press CTRL+C"
	end
rescue Interrupt => _
	conn.close
	exit(0)
end

