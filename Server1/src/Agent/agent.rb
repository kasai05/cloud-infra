#################################################################
#
# RabbitMQからのキューを受け取るプログラム by Kuroki
# 対象はVMの作成、起動、停止、削除のみ
# Ver 1.0
#
#################################################################

require 'json' 
require 'bunny'
require './VmController.rb' #実際のVM操作を行うクラス

hostname = "localhost" #適宜変更する
queueName = "kvm1"     #適宜変更する

conn = Bunny.new(:hostname => hostname, :username => "mquser", :password => "mquser")
conn.start

ch = conn.create_channel
q = ch.queue(queueName)


begin
	vmcon = VmController.new()
	puts "[*] Waiting for messages. To exit press CTRL+C"
	#受信データは、"type","name","uuid","vcpu","memory","disk"
	q.subscribe(:block => true) do |delivery_info, properties, body|
		puts "*****データを受信*****"
		hash = JSON.parse(body)
		#データタイプにより処理振り分け
		case hash["type"]
		when "create"
			vmcon.vmCreate(hash)
		when "start"
			vmcon.vmStart(hash)
		when "stop"
			vmcon.vmStop(hash)
		when "destroy"
			vmcon.vmDestroy(hash)
		when "delete"
			vmcon.vmDestroy(hash)
			vmcon.vmDelete(hash)
		else
			puts "ERROR: Not yet implemented (" + hash["type"] + ")"
		end
		puts "[*] Waiting for messages. To exit press CTRL+C"
	end
rescue Interrupt => _
	conn.close
	exit(0)
end
