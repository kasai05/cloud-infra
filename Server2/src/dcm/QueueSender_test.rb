# ファイル名：QueueSender.rb
# 概要：キュー送信用クラス
# 役割：RabbitMQのキューにメッセージを送信する
# 実行方法：メインプログラムからnewでインスタンス化する
# バージョン：2.0
# 作成者：黒木

require "bunny" # RabbitMQとの通信用ライブラリ

	@mqAddress = "127.0.0.1" # RabbitMQサーバのIPアドレス
  @queueName  = "test" # 送信するキュー(チャンネル)の名称
  @msg = %Q[{"queueName":"WebAPI_to_DCM", "type":"create", "user":"0001", "hostname":"test", "cpu":"2", "memory":"512", "disk":"25", "publickey":"abc"}]        # 実際に送信するメッセージ

	# メッセージ送信メソッド
		# RabbitMQサーバと接続
		conn = Bunny.new(:hostname => @mqAddress, :username => "mquser", :password => "mquser")
		conn.start
		ch = conn.create_channel
		q = ch.queue(@queueName)

		# RabbitMQサーバにメッセージを送信
		ch.default_exchange.publish(@msg, :routing_key => q.name)
		puts "QueueName : " + @queueName
		puts "[x]Sent " + @msg

		# RabbitMQサーバとの接続解除
		conn.close
