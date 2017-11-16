# ファイル名：dcm.rb
# 概要：DataCenterManagerの受付係
# 役割：主にWebAPIからのキューメッセージの待ち受けを行い、各種動作を実施する。
# 実行方法：ruby ./agent.rb "MQサーバのIPアドレス" ("待ち受けするキューの名称")
# バージョン：2.1
# 作成者：黒木


require 'json'										# json形式とhash形式を相互に変換するライブラリ
require 'bunny'										# RabbitMQサーバとの通信で使用するライブラリ
require './DiskChecker.rb'				# 各KVMサーバの残Diskサイズを調べるメソッド(羽田さん作)
require './DatabaseMediater.rb'		# MariaDBへ空きIPアドレスの問い合わせと確保を行うモジュール
require './QueueSender.rb'				# RabbitMQへメッセージキューを送るクラス


# 引数が足りない場合はエラー終了をする
if ARGV[1].nil? then
	puts " !*!*!*!*!*!*! ARGUMENT ERROR !*!*!*!*!*!*!"
	puts " usage: ruby ./#{__FILE__} MQServerAddress DBServerAddress QueueName"
		puts " QueueName is optional. (default is 'WebAPI_to_DCM')"
	return -1
end

# 定数を設定
MQADDRESS = ARGV[0] # RabbitMQサーバのIPアドレス
DBADDRESS = ARGV[1] # DatabaseサーバのIPアドレス
ARGV[2].nil? ? QUEUENAME = "WebAPI_to_DCM" : QUEUENAME = ARGV[1] # 待ち受けするキュー名。デフォルトは「WebAPI_to_DCM」
BASEUUID = "a8feb5a7-a4db-4983-b413-"  # UUIDはIPアドレスをベースにするが、桁が足りないのでベースを用意する


# RabbitMQサーバと接続
conn = Bunny.new(:hostname => MQADDRESS, :username => "mquser", :password => "mquser")
conn.start
ch = conn.create_channel
q = ch.queue(QUEUENAME)


# 関連クラスをインスタンス化
dm = DatabaseMediater.new(DBADDRESS)  # Database(MariaDB)とのやりとりを担うインスタンス
queueSender = QueueSender.new()  # キューメッセージの送信を担うインスタンス

begin
	puts "[*] Waiting for messages. To exit press CTRL+C"

	# キューメッセージの待ち受け開始
	q.subscribe(:block => true) do |delivery_info, properties, body|
		puts "***** Received a Message *****"
		puts "[x]Received " + body
		hash = JSON.parse(body)  # 受信したJSON形式のメッセージをhash形式に変換

		#データタイプにより処理振り分け
		case hash["type"]

		when "create"  # データタイプが作成要求の場合...

			# 最もDiskに空きがあるKVMのIDを求める。いずれも容量不足の場合はkvmIDに0にしてエラーをデータベースに記録する。また、以降の処理は行わない。
			dc = diskcheck(hash["disk"])  # './DiskChecker.rb のメソッド'
			targetKVM = dc[:hostname]
			if targetKVM == "ERROR"
				hash.store("kvmID", 0)
				dm.setParams(hash)
				dm.status = "Error:NoDiskSpaceLeft"
				dm.addRecode()
				puts "Error:NoDiskSpaceLeft"
				next
			else
				hash.store("kvmID", targetKVM[-1].to_i)
			end


			#Databaseより空きアドレスを確保 ("."は含まない、0パディングの12ケタ。ex. 192168000020)
			dm.setParams(hash)
			dm.status = "creating"
			id_ip = dm.secureIP() 

			if id_ip[:vacantIPaddr].nil? # 空きIPアドレスを確保できなかった場合は以降の処理は行わない。
				puts "Error:NoVacantIPAddress"
				next
			end

			id = id_ip[:vacantID].to_s  
			ipaddr0padding = id_ip[:vacantIPaddr].to_s

			puts "ID is " + id
			puts "IPaddr is " + ipaddr0padding


			#先ほど取得したアドレスからIPアドレスを決める
			ipaddr = ipaddr0padding[0..2] + "." + ipaddr0padding[3..5] + "." + ipaddr0padding[6..8] + "." + ipaddr0padding[9..11]

			#予め用意した文字列と先ほど取得したアドレスを組み合わせ、MACアドレスを決める
			macaddr = "00:" + ipaddr0padding[2..3] + ":" + ipaddr0padding[4..5] + ":" + ipaddr0padding[6..7] + ":" + ipaddr0padding[8..9] + ":" + ipaddr0padding[10..11]

			#予め用意した文字列と先ほど取得したアドレスを組み合わせて、UUIDを決める
			#uuid = BASEUUID + ipaddr0padding
			uuid = id_ip[:uuid].to_s

			# KVMのAgentに送る要求内容を整える
			hash["queueName"] = "#{targetKVM}"
			hash.store("uuid", "#{uuid}")
			hash.store("ipaddr", "#{ipaddr}")
			hash.store("macaddr", "#{macaddr}")
			hash.store("status", "creating")


			queueSender.mqAddress = MQADDRESS 

			# いずれのKVMも容量不足だった場合についてはキューの名前を変更し、Agentではなくresult.rbでエラーを受け取るよう変更する
			if targetKVM == "ERROR"
				queueSender.queueName = "response"
				hash["queueName"] = "response"
				hash.store("id", id)
				hash.store("status", "error_create(size)")
			else
				queueSender.queueName = targetKVM  # キューの名前はVMを作成するKVM名
			end

			# hash形式のメッセージをjson形式に変換する
			message = hash.to_json

			# メッセージキュー送信用クラスに送信するメッセージを登録
			queueSender.msg = message

			# メッセージキュー送信用クラスでメッセージを送信
			queueSender.send()


		when "start", "stop", "destroy", "delete"  # データタイプが作成、停止、強制停止、削除の場合...

			# UUIDから対象の仮想マシンが格納されているKVMIDを確認する
			targetKVM = "Server" + dm.getKVMID(hash["uuid"]).to_s

			# KVMIDが0の場合かつデータタイプが「delete」の場合はデータベースから削除する
			if targetKVM == "Server0" and hash["type"] == "delete"
				dm.delete(hash["uuid"])
				next
			elsif targetKVM == "Server0"
				# データタイプがそれ以外の場合は反応しない
				next
			else
				# KVMIDが0でなかった場合はKVMにメッセージを転送する
				queueSender.mqAddress = MQADDRESS #RabbitMQのIPアドレス
				queueSender.queueName = targetKVM
				queueSender.msg = %Q[{"queueName":"#{targetKVM}", "type":"#{hash["type"]}", "uuid":"#{hash["uuid"]}"}]
				queueSender.send()
			end
		else
			puts "ERROR: Not yet implemented (" + hash["type"] + ")"
		end
		puts "[*] Waiting for messages. To exit press CTRL+C"
	end
rescue Interrupt => _
	conn.close
	exit(0)
end
