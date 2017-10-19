################################################################
#
# メインプログラムから要求を受け取り、
# 値のチェックをした上で、Queueに送り込むプログラム　By Kuroki
# Ver 1.0
#
################################################################

require "bunny"


class MqSender
	attr_accessor :hostname, :queueName, :type, :name, :uuid, :vcpu, :memory, :disk

	def initialize()
		@hostname = "172.16.105.2"  #適宜書き換える (MQServerのIPアドレスを指定する)
		@queueName = nil
		@type = nil
#		@name = nil
		@uuid = nil
		@vcpu = nil
		@memory = nil
#		@disk = nil
	end

	public
	def send()
		result = checkVariable()
		if result == -1
			return -1
		end

		conn = Bunny.new(:hostname => @hostname, :username => "mquser", :password => "mquser")
		conn.start
		ch = conn.create_channel
		q = ch.queue(@queueName)

		@queueMessage = %Q[{"queueName":"#{@queueName}", "type":"#{@type}", \
											"uuid":"#{@uuid}", "vcpu":"#{@vcpu}", "memory":"#{@memory}"}]
		
		ch.default_exchange.publish(@queueMessage, :routing_key => q.name)
		puts "[x]Sent " + @queueMessage
		conn.close
	end

	private
	def checkVariable()
		variables = [@queueName, @type, @uuid, @vcpu, @memory]
		#typeの指定により、チェック項目を変更する
		if @type == "create"
			variables.each do |variable|
				if variable.nil?
					puts "ERROR : Incorrect Usage"
					return -1
				end
			end
		end
		if @type == "start" || @type == "stop" || @type == "destroy" || @type == "delete"
			if @queueName.nil? || @uuid.nil?
				puts "ERROR : Incorrect Usage"
				return -1
			end
		end
		puts "send #{@type} queue"
	end
end
