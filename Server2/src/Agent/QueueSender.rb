# ファイル名：QueueSender.rb
# 概要：キュー送信用クラス
# 役割：RabbitMQのキューにメッセージを送信する
# 実行方法：メインプログラムからnewでインスタンス化する
# バージョン：2.0
# 作成者：黒木

require "bunny" # RabbitMQとの通信用ライブラリ

class QueueSender
	@mqAddress  # RabbitMQサーバのIPアドレス
  @queueName  # 送信するキュー(チャンネル)の名称
  @msg        # 実際に送信するメッセージ
	attr_accessor :mqAddress, :queueName, :msg  # インスタンス変数は全て外部から変更/参照可能

	# メッセージ送信メソッド
	def send()
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
	end

	# to_sメソッド
	def to_s
		puts ("rabbitMQ => #{@mqAddress} | queueName => #{@queueName} |  message => #{@msg}")
	end
end
