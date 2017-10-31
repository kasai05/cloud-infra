# キューにメッセージを送るだけのクラス By Kuroki
# Ver 1.0

require "bunny"

class QueueSender
	attr_accessor :hostname, :queueName, :msg

	def initialize()
		@hostname
		@queueName
		@msg
	end

	def send()
		conn = Bunny.new(:hostname => @hostname, :username => "mquser", :password => "mquser")
		conn.start
		ch = conn.create_channel
		q = ch.queue(@queueName)

		ch.default_exchange.publish(@msg, :routing_key => q.name)
		puts "QueueName : " + @queueName
		puts "[x]Sent " + @msg
		conn.close
	end
end
