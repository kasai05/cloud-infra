###dbupdateするプログラム
#By haneda
#
require "mysql"
require './result_qreceive.rb'
require 'json'

def dbupdate(hash)

    #attr_accessor :userID, :kvmID, :hostName, :cpu, :memory, :disk, :scaleUp, :minCPU, :minMemory, :minDisk, :maxCPU, :maxMemory, :maxDisk, :scaleOutID, :status, :publicKey

    hostname = "127.0.0.1"
    username = "root"
    password = "group1"
    dbname = "IkuraCloud"


    @uuid = hash["uuid"]
    @status = hash["status"]
    client = Mysql.connect(hostname, username, password, dbname)

    if @status == "deleted"

      stmt = client.prepare("UPDATE VirtualMachine SET UserID = ?, Status = ? WHERE InstanceUUID = ?")
      stmt.execute  0, "#{@status}", "#{@uuid}"
    
    else

      stmt = client.prepare("UPDATE VirtualMachine SET Status = ? WHERE InstanceUUID = ?")
      stmt.execute  "#{@status}", "#{@uuid}"

    end 

end



