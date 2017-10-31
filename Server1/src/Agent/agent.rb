require 'json'
require 'bunny'
require './VmController.rb'
require './QueueSender.rb'

ARGV[0].nil? ? HOSTNAME = "127.0.0.1" : HOSTNAME = ARGV[0]
QUEUENAME = "kvm1"

conn = Bunny.new(:hostname => HOSTNAME, :username => "mquser", :password => "mquser")
conn.start

ch = conn.create_channel
q = ch.queue(QUEUENAME)


begin
	vmcon = VmController.new()
	queueSender = QueueSender.new()
	puts "[*] Waiting for messages. To exit press CTRL+C"
	q.subscribe(:block => true) do |delivery_info, properties, body|
		puts "*****データを受信*****"
		puts "[x]Received " + body
		hash = JSON.parse(body)
		#データタイプにより処理振り分け
		case hash["type"]
		when "create"
			result = vmcon.vmCreate(hash)
		when "start"
			result = vmcon.vmStart(hash)
		when "stop"
			result = vmcon.vmStop(hash)
		when "destroy"
			result = vmcon.vmDestroy(hash)
		when "delete"
			vmcon.vmDestroy(hash)
			result = vmcon.vmDelete(hash)
		else
			puts "ERROR: Not yet implemented (" + hash["type"] + ")"
			result = "NotYetImplemented"
		end

		queueSender.hostname = '192.168.57.10'
		queueSender.queueName = 'response'
		
		hash.store("queueName", "response")
		hash.store("status", "#{result}")
		message = hash.to_json
		queueSender.msg = message
		queueSender.send()
		

		puts "[*] Waiting for messages. To exit press CTRL+C"
	end
rescue Interrupt => _
	conn.close
	exit(0)
end
