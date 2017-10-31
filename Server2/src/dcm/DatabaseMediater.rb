# Database接続用クラス　by Kuroki
# ver 1.0

require "mysql"

class DatabaseMediater
	attr_accessor :userID, :kvmID, :hostName, :cpu, :memory, :disk, :scaleUp, :minCPU, :minMemory, :minDisk, :maxCPU, :maxMemory, :maxDisk, :scaleOutID, :status, :publicKey

	HOSTNAME = "127.0.0.1"
	USERNAME = "root"
	PASSWORD = "group1"
	DBNAME = "IkuraCloud"

	def initialize 
		@userID = 1
		@kvmID = 1
		@hostName = "test"
		@cpu = 1
		@memory = 512
		@disk = 25
		@scaleUp = 0
		@minCPU = 1
		@minMemory = 512
		@minDisk = 25
		@maxCPU = 1
		@maxMemory = 512
		@maxDisk = 25
		@scaleOutID = 0
		@status = "creating"
		@publicKey = "testkey"
	end


	def secureIP
		vacantID = nil
		vacantIPaddr = nil
		client = Mysql.connect(HOSTNAME, USERNAME, PASSWORD, DBNAME)
		client.query("SELECT id, IPaddr FROM VirtualMachine WHERE UserID = 0 LIMIT 1").each do |col1, col2| 
			vacantID = col1
			vacantIPaddr = col2
		end

		stmt = client.prepare("UPDATE VirtualMachine SET UserID = ?,
													KVMID = ?, HostName = ?, CPU = ?, Memory = ?,
													Disk = ?, ScaleUp = ?, MinCPU = ?, MinMemory = ?, MinDisk = ?,
													MaxCPU = ?, MaxMemory = ?, MaxDisk = ?, ScaleOutID = ?, 
													Status = ?, PublicKey = ? WHERE id = ?")
		stmt.execute "#{@userID}", "#{@kvmID}", "#{@hostName}", "#{@cpu}", "#{@memory}", "#{@disk}", "#{@scaleUp}", "#{@minCPU}", "#{@minMemory}", "#{@minDisk}", "#{@maxCPU}", "#{@maxMemory}", "#{@maxDisk}", "#{@scaleOutID}", "#{@status}", "#{@publicKey}", "#{vacantID}"
		return vacantIPaddr
	end
end
