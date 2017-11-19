################################
# "response"というキューが来たら
# MariaDBの更新をするメソッド
# 実際DBの更新メソッドはresult_dbupdate.rbを使う
# By Haneda
# バージョン2.0
################################

require "bunny"
require "json"
require "./result_dbupdate"

#まずはメッセージ受け取り

def qreceive
  conn = Bunny.new(:username => "mquser" , :password => "mquser")
  conn.start

  ch = conn.create_channel

  q = ch.queue("response")

  puts "[*] Waiting fo messages in #{q.name}. To exit press CTR+C"

  q.subscribe(:block => true) do |delivery_info, properties, body|

     puts "*****data receiving*****"
     puts " [x]Received #{body}"
     hash = JSON.parse(body)
     dbupdate(hash)
     puts "****DONE DB UPDATE****"
     puts "[*] Waiting fo messages. To exit press CTR+C"
     
  end

end


