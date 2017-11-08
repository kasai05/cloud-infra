# ファイル名：DatabaseMediater.rb
# 概要：Databaseアクセスクラス
# 役割：Databaseとの通信を行い、IPアドレスの確保、情報の書き込み、参照を行う
# 実行方法：メインプログラムからインスタンス化してインスタンスメソッドを呼び出す
# バージョン：2.1
# 作成者：黒木

require "mysql"   # ruby-mysqlを読み込む。(別途gem installしておく必要がある)

class DatabaseMediater
	attr_accessor :userID, :kvmID, :hostName, :cpu, :memory, :disk, :scaleUp, :minCPU, :minMemory, :minDisk, :maxCPU, :maxMemory, :maxDisk, :scaleOutID, :status, :publicKey

	USERNAME = "root"
	PASSWORD = "group1"
	DBNAME = "IkuraCloud"
	BASEUUID = "a8feb5a7-a4db-4983-b413-"
	@@instanceCount


	# インスタンス化した時の初期化
	def initialize(ipAddress)
		@mqAddress = ipAddress

		# UUIDの元ネタとなるレコード数を確認する
		client = Mysql.connect(@mqAddress, USERNAME, PASSWORD, DBNAME)
		client.query("SELECT id FROM VirtualMachine ORDER BY id DESC LIMIT 1").each do |col|
			@@instanceCount = col[0].to_i + 1
		end
	end

	# hash形式の情報を変数に格納する
	def setParams(hash)
		hash["user"].nil? ? @userID = "noUserID" : @userID = hash["user"]
		hash["kvmID"].nil? ? @kvmID = "0" : @kvmID = hash["kvmID"]
		hash["cpu"].nil? ? @cpu = 1 : @cpu = hash["cpu"]
		hash["memory"].nil? ? @memory = 512 : @memory = hash["memory"]
		hash["disk"].nil? ? @disk = 20 : @disk = hash["disk"]
		hash["publickey"].nil? ? @publickey + "abcdefg" : @publicKey = hash["publickey"]
		hash["hostName"].nil? ? @hostName = "noName" : @hostName = hash["hostName"]
		hash["scaleUp"].nil? ? @scaleUp = 0 : @scaleUp = hash["scaleUp"]
		hash["minCPU"].nil? ? @minCPU = @cpu : @minCPU = hash["minCPU"]
		hash["minMemory"].nil? ? @minMemory = @memory : @minMemory = hash["minMemory"]
		hash["minDisk"].nil? ? @minDisk = @disk : @minDisk = hash["minDisk"]
		hash["maxCPU"].nil? ? @maxCPU = @cpu : @maxCPU = hash["maxCPU"]
		hash["maxMemory"].nil? ? @maxMemory = @memory : @maxMemory = hash["maxMemory"]
		hash["maxDisk"].nil? ? @maxDisk = @disk : @maxDisk = hash["maxDisk"]
		hash["scaleOutID"].nil? ? @scaleOutID = 0 : @scaleOutID = hash["scaleOutID"]
		hash["status"].nil? ? @status  = "" : @status = hash["status"]
		hash["uuid"].nil? ? @uuid = "" : @uuid = hash["uuid"]
	end


	# データベースから空IPアドレスを取得する (条件：userID = 0)
	# この際重複が発生しないように、取得したIPアドレスのレコードにそのままデータを書き込む
	# 取得できるIPアドレスがない場合はレコードを追加する。(IPアドレスカラムは空白)
	def secureIP
		vacantID = nil
		vacantIPaddr = nil

		client = Mysql.connect(@mqAddress, USERNAME, PASSWORD, DBNAME)
		client.query("SELECT id, IPaddr FROM VirtualMachine WHERE UserID = 0 AND IPaddr != '' LIMIT 1").each do |col1, col2| 
			vacantID = col1
			vacantIPaddr = col2
		end

		if vacantID.nil?  # 空きIPアドレスがない場合は割当KVMを0(=無し)にし、statusをエラーメッセージとしレコードを追加する
			@kvmID = 0
			@status = "Error:NoVacantIPAddress"

			# インスタンスid(UUID)を決める
			@uuid = BASEUUID + sprintf("%012d",@@instanceCount).to_s
			@@instanceCount += 1

			stmt = client.prepare("INSERT INTO VirtualMachine (UserID, KVMID, InstanceUUID, HostName, CPU, Memory, Disk, ScaleUp, MinCPU, MinMemory, MinDisk, MaxCPU, MaxMemory, MaxDisk, ScaleOutID, Status, PublicKey) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
			stmt.execute("#{@userID}", "#{@kvmID}", "#{@uuid}", "#{@hostName}", "#{@cpu}", "#{@memory}", "#{@disk}", "#{@scaleUp}", "#{@minCPU}", "#{@minMemory}", "#{@minDisk}", "#{@maxCPU}", "#{@maxMemory}", "#{@maxDisk}", "#{@scaleOutID}", "#{@status}", "#{@publicKey}")

		else  # 空きIPアドレスがある場合は、そのIPアドレスのレコードを更新する

			# インスタンスid(UUID)を決める
			@uuid = BASEUUID + vacantIPaddr.to_s

			stmt = client.prepare("UPDATE VirtualMachine SET UserID = ?,
														KVMID = ?, InstanceUUID = ?, HostName = ?, CPU = ?, Memory = ?,
														Disk = ?, ScaleUp = ?, MinCPU = ?, MinMemory = ?, MinDisk = ?,
														MaxCPU = ?, MaxMemory = ?, MaxDisk = ?, ScaleOutID = ?, 
														Status = ?, PublicKey = ? WHERE id = ?")
			stmt.execute("#{@userID}", "#{@kvmID}", "#{@uuid}", "#{@hostName}", "#{@cpu}", "#{@memory}", "#{@disk}", "#{@scaleUp}", "#{@minCPU}", "#{@minMemory}", "#{@minDisk}", "#{@maxCPU}", "#{@maxMemory}", "#{@maxDisk}", "#{@scaleOutID}", "#{@status}", "#{@publicKey}", "#{vacantID}")
		end

		# 呼び出し元に、空きIPアドレスとそのレコードIDを返す
		ans = {:vacantIPaddr => vacantIPaddr, :vacantID => vacantID, :uuid => @uuid}
		return ans
	end


	# 指定されたuuidのインスタンスをデータベースから削除する。(userIDを0にする)
	def delete(uuid)
		client = Mysql.connect(@mqAddress, USERNAME, PASSWORD, DBNAME)
		stmt = client.prepare("UPDATE VirtualMachine SET UserID = ? WHERE InstanceUUID = ?")
		stmt.execute(0,uuid)
	end

	# 指定されたuuidのインスタンスが格納されているkvmのサーバ番号を返す
	def getKVMID(uuid)
		client = Mysql.connect(@mqAddress, USERNAME, PASSWORD, DBNAME)
		kvmid = nil
		client.query("SELECT KVMID FROM VirtualMachine WHERE InstanceUUID = #{uuid} LIMIT 1").each do |col1|
			kvmid = col1[0].to_i  # 0パディングを削除するためにいったんintに変換する
		end
		return kvmid.to_s
	end

	# インスタンス変数に格納した値でレコードを追加する
	def addRecode
		# インスタンスid(UUID)を決める
		@uuid = BASEUUID + sprintf("%012d",@@instanceCount).to_s
		puts "uuid :" + @uuid
		@@instanceCount += 1

		client = Mysql.connect(@mqAddress, USERNAME, PASSWORD, DBNAME)
		stmt = client.prepare("INSERT INTO VirtualMachine (UserID, KVMID, InstanceUUID, HostName, CPU, Memory, Disk, ScaleUp, MinCPU, MinMemory, MinDisk, MaxCPU, MaxMemory, MaxDisk, ScaleOutID, Status, PublicKey) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
		stmt.execute("#{@userID}", "#{@kvmID}", "#{@uuid}", "#{@hostName}", "#{@cpu}", "#{@memory}", "#{@disk}", "#{@scaleUp}", "#{@minCPU}", "#{@minMemory}", "#{@minDisk}", "#{@maxCPU}", "#{@maxMemory}", "#{@maxDisk}", "#{@scaleOutID}", "#{@status}", "#{@publicKey}")
	end
end
