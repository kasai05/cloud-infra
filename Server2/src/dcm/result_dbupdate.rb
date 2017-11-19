#############################
#キューからメッセージを受け取って、MariaDBを更新するプログラム。実際の処理はresult_qreceive.rbの中で処理される。
#By haneda
#バージョン2.0
#############################

require "mysql"
require './result_qreceive.rb'
require 'json'
require './QueueSender.rb'

def dbupdate(hash)

    #attr_accessor :userID, :kvmID, :hostName, :cpu, :memory, :disk, :scaleUp, :minCPU, :minMemory, :minDisk, :maxCPU, :maxMemory, :maxDisk, :scaleOutID, :status, :publicKey

    hostname = "127.0.0.1"
    username = "root"
    password = "group1"
    dbname = "IkuraCloud"


    @uuid = hash["uuid"]
    @status = hash["status"]
    client = Mysql.connect(hostname, username, password, dbname)

    if @status == "error_create" # KVMの容量不足の場合は他のKVMは空きがある場合があるため、キューに入れ直す。
      queueSender = QueueSender.new()  # キューメッセージの送信を担うインスタンス
      queueSender.mqAddress = hostname
      queueSender.queueName = "WebAPI_to_DCM"
      hash["queueName"] = "WebAPI_to_DCM"
      hash["status"] = ""
      queueSender.msg = hash.to_json
      queueSender.send()

    elsif @status == "deleted"

      stmt = client.prepare("UPDATE virtual_machines SET UserID = ?, Status = ? WHERE InstanceUUID = ?")
      stmt.execute  0, "#{@status}", "#{@uuid}"
    
    else

      stmt = client.prepare("UPDATE virtual_machines SET Status = ? WHERE InstanceUUID = ?")
      stmt.execute  "#{@status}", "#{@uuid}"

    end 

end



