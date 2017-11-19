# ファイル名：Monitor.rb
# 概要：VMステータス監視スクリプト
# 役割：VMのステータスを監視し、シャットオフしたものがあればDBを更新するキューメッセージを送信する
# 実行方法：ruby ./Monitor.rb "MQサーバのIPアドレス" 
# バージョン：1.0
# 作成者：黒木


require 'json'
require './QueueSender.rb'


def getCurrent()
	cmd = "virsh list --all"
	current =  %x[#{cmd}]
	return current
end


def pushHash(text)
	hash = Hash.new()
	linenum = 0
	data = ""
	text.lines {|line|
		linenum += 1
		# 最初の2行は不要のため飛ばす
		if linenum <= 2
			next
		end
		# パラメータ情報を持っていない行は飛ばす
		if line[7..-1].nil?
			next
		else
			data = line[7..-1]
		end

		# uuidとそのステータスをハッシュに格納する
		ary = data.chomp!.split(" ")
		hash[ary[0]] = ary[1]
	}	
	return hash
end


def checkStatus(beforeHash, currentHash)
	beforeHash.each_pair {|key, value|
		beforeValue = value
		currentValue = currentHash[key]
		if beforeValue == "実行中" && currentValue == "シャットオフ"
			dbUpdate(key)
		end
	}
end

def dbUpdate(uuid)
	puts uuid + " is now shutdown"
	queueSender = QueueSender.new()
	queueSender.mqAddress = ARGV[0]
	queueSender.queueName = "response"
	hash = Hash.new()
	hash.store("queueName", "response")
	hash.store("uuid", uuid)
	hash.store("status", "stopped")
	message = hash.to_json
	queueSender.msg = message
	queueSender.send()
end


# ============ Main =================

if ARGV[0].nil? then
	puts " !*!*!*!*!*!*! ARGUMENT ERROR !*!*!*!*!*!*!"
	puts " usage: ruby ./#{__FILE__} MQServerAddress"
		return -1
end

beforeData = ""

begin
	while true do
		puts "[*] Monitring... To exit press CTRL+C"

		currentData = getCurrent()
		currentHash = pushHash(currentData)

		if beforeData == ""
			beforeHash = currentHash
		else
			beforeHash = pushHash(beforeData)
		end

		checkStatus(beforeHash, currentHash)
		beforeData = currentData
		sleep 5
	end	
rescue Interrupt => error
	puts error
	exit(0)
end
