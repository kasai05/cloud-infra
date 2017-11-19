##############
#キューを取得して余計なキューを削除するプログラム
#テスト実行時などに使用
#By Haneda
#バージョン1.0
##############

require "bunny"

# RabbitMQに接続
conn = Bunny.new(:username => "mquser", :password => "mquser")
conn.start

# channelを作成
ch = conn.create_channel

 # queue1というキューを作成
q  = ch.queue("response")

 # メッセージを取得
 # 取得するとキューからメッセージは削除される
q.subscribe do |delivery_info, properties, msg|
   p "queue  = #{q.name}" #=> "queue  = queue1"
   p "message= #{msg}"    #=> "message= Hello, world!"
end

#close
conn.stop

