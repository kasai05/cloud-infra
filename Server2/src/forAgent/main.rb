######################################################
#
# KVMのAgentあてにキューを送るプログラム By Kuroki
# 実際の処理は[MqSender.rb]にて行う 
# Ver 1.0
#
######################################################

require './MqSender.rb'

###下記定数は適宜書き換える####
QUEUENAME = "kvm1"  #キューのチャンネル
QUEUETYPE = ARGV[0]
UUID = "b7ef4dd3-ae48-4a8f-9521-aaa192168203"
VCPU = "1"
MEMORY = "512"
###############################

if ARGV[0].nil?
	puts "choose QueueType..."
	puts "create, start, stop, destroy, delete."
	return -1
end


if QUEUETYPE == "create"
	queue = MqSender.new()
	queue.queueName = QUEUENAME
	queue.type = QUEUETYPE
	queue.uuid = UUID
	queue.vcpu = VCPU
	queue.memory = MEMORY
	queue.send()
else
	queue = MqSender.new()
	queue.queueName = QUEUENAME
	queue.type = QUEUETYPE
	queue.uuid = UUID
	queue.send()
end

