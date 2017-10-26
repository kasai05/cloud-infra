# WebAPIからのキューメッセージを受け取り、要求種別ごとに対応を行い、KVMへ要求を出すプログラム　By Kuroki
# 引数を指定するとRabbitMQサーバを変更できる。が、requireしているDatabaseMediaterは別途設定変更が必要() 
# Ver 1.0


require 'json'
require 'bunny'
require './DiskChecker.rb'
require './DatabaseMediater.rb'
require './QueueSender.rb'

QUEUENAME = "WebAPI_to_DCM"
BASEUUID = "a8feb5a7-a4db-4983-b413-"
ARGV[0].nil? ? HOSTNAME = "127.0.0.1" : HOSTNAME = ARGV[0]

conn = Bunny.new(:hostname => HOSTNAME, :username => "mquser", :password => "mquser")
conn.start

ch = conn.create_channel
q = ch.queue(QUEUENAME)


begin
	dm = DatabaseMediater.new()
	queueSender = QueueSender.new()

	puts "[*] Waiting for messages. To exit press CTRL+C"
	q.subscribe(:block => true) do |delivery_info, properties, body|
		puts "*****データを受信*****"
		hash = JSON.parse(body)
		#データタイプにより処理振り分け
		case hash["type"]
		when "create"
			#受信データは、<type><uuid><hostname><cpu><memory><disk><user><maxcpu><maxmemory><maxcount><publickey>
			targetKVM = diskcheck(hash["disk"]) #DiskCheckerにより最も容量の空いているKVM名を取得

			#Databaseより空きアドレスを確保 ("."は含まない、0パディングの12ケタ。ex. 192168000020)
			dm.userID = hash["user"]
			dm.kvmID = targetKVM[-1].to_i
			dm.hostName = hash["hostname"]
			dm.cpu = hash["cpu"]
			dm.memory = hash["memory"]
			dm.disk = hash["disk"]
			dm.minCPU = hash["mincpu"]
			dm.minMemory = hash["minmemory"]
			dm.minDisk = hash["mindisk"]
			dm.maxCPU = hash["maxcpu"]
			dm.maxMemory = hash["maxmemory"]
			dm.maxDisk = hash["maxdisk"]
			dm.publicKey = hash["publickey"]
			tempaddr = dm.secureIP() 

			#先ほど取得したアドレスからIPアドレスを求める
			ipaddr = tempaddr[0..2] + "." + tempaddr[3..5] + "." + tempaddr[6..8] + "." + tempaddr[9..11]

			#予め用意した文字列と先ほど取得したアドレスを組み合わせ、MACアドレスを求める
			macaddr = tempaddr[0..1] + ":" + tempaddr[2..3] + ":" + tempaddr[4..5] + ":" + tempaddr[6..7] + ":" + tempaddr[8..9] + ":" + tempaddr[10..11]

			#予め用意した文字列と先ほど取得したアドレスを組み合わせて、UUIDを求める
			uuid = BASEUUID + tempaddr

			# 受領した要求をKVMに転送する
			queueSender.hostname = HOSTNAME #RabbitMQのIPアドレス
			queueSender.queueName = targetKVM #キューの名前はVMを作成するKVM名
			queueSender.msg = %Q[{"queueName":"#{targetKVM}", "type":#{hash["type"]}, "uuid":#{uuid}, "ipaddr":#{ipaddr}, "macaddr":#{macaddr}, "cpu":#{hash["cpu"]}, "memory":#{hash["memory"]}, "publickey":#{hash["publickey"]}}]
			queueSender.send()



		when "start", "stop", "destroy", "delete"
			#受信データは、<type><uuid> (他にも受信するかもしれないが使わない。)
			targetKVM = dm.getKVM(hash[uuid])

			queueSender.hostname = HOSTNAME #RabbitMQのIPアドレス
			queueSender.queueName = targetKVM
			queueSender.msg = %Q[{"queueName":#{targetKVM}, "type":#{hash["type"]}, "uuid":#{hash["uuid"]}}]
			queueSender.send()
		else
			puts "ERROR: Not yet implemented (" + hash["type"] + ")"
		end
		puts "[*] Waiting for messages. To exit press CTRL+C"
	end
rescue Interrupt => _
	conn.close
	exit(0)
end

