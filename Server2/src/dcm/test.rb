#テスト用のキュー送信プログラム

require "./QueueSender.rb"

puts "ruby test.rb MQADDRESS MODE uuid"

return -1 if ARGV[2].nil?

qs = QueueSender.new()

qs.mqAddress = ARGV[0]
#qs.mqAddress = "192.168.57.10"
target = ARGV[2]

qs.queueName = "WebAPI_to_DCM"

publickey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCHAX7CtgNWnYWFvuxJ4CqV2rE56Il6d1r4v+77SInaeAEfYgfDA2UfRn2V/JadBG/k+oDXf5CEWb+MGuKoNUzHXEWQ/VRcLJSrbVe4UmFmQmIDn4bBpprBzB6pRZFqdTBKLZWfVEONOu7DSOmsgkpQwgO0JWwPmsoguWeAXRbSwJxwbZhvTOJJ4CO2nHHoG9hZl6+rzqemFwIvn9/Ibqd6levhq+2obGZL2AqKcJktxb+/bfebcJIoWBdyEEM08yUFsOwCtP3rnMmGRDbBBnpm6CPP8YR3ATm+4nuRUesOvNh0zDVHje/PDQcMLZV/PvDXjfpp+XlKLREuq7sGEt/ a1710dk"

case ARGV[1]
when "create"
	qs.msg = %Q[{"queueName":"WEBAPI_to_DCM", "user":"00000004", "type":"create", "disk":"15", "cpu":"1", "memory":"512", "publickey":"#{publickey}"}]
when "start"
	qs.msg = %Q[{"queueName":"WEBAPI_to_DCM", "type":"start", "uuid":"#{target}"}]
when "stop"
	qs.msg = %Q[{"queueName":"WEBAPI_to_DCM", "type":"stop",  "uuid":"#{target}"}]
when "destroy"
	qs.msg = %Q[{"queueName":"WEBAPI_to_DCM", "type":"destroy", "uuid":"#{target}"}]
when "delete"
	qs.msg = %Q[{"queueName":"WEBAPI_to_DCM", "type":"delete",  "uuid":"#{target}"}]
end
qs.send()


