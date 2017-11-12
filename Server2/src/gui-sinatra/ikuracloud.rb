require 'sinatra'
require 'mysql'
require './QueueSender.rb'
require './DataBase.rb'

USERNAME = "root"
PASSWORD = "group1"
DBNAME = "IkuraCloud"
MQADDRESS = '127.0.0.1'

set :environment, :production


# ホーム画面。
get '/' do
  @users = Array.new()
  client =  Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
  client.query("SELECT DISTINCT UserName, UserID FROM User").each do |userName, userID|
    @user = {:userName => userName, :userID => userID}
    @users.push(@user)
  end
  p @users
  erb :index
end

# ユーザの新規作成画面
get '/createuser' do
  erb :createuser
end

post '/createuser' do
  @username = params[:username]
  @tel = params[:tel]
  @email = params[:email]
  @userID 
  userCount = 1

  # UserIDを決めるため、レコード数を確認する
  client = Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
  client.query("SELECT UserID FROM User").each do |userid|
    userCount += 1
  end

  # UserIDの書式を調整
  @userID = sprintf("%08d",userCount).to_s

  client = Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
  stmt = client.prepare("INSERT INTO User (UserID, UserName, Tel, Email) VALUES (?,?,?,?)")
  stmt.execute("#{@userID}", "#{@username}", "#{@tel}", "#{@email}")

  @refresh = "true"
  erb :createuser
end


# ユーザの所有するインスタンス一覧を表示
get '/:userID' do |userid|
  @vms = Array.new()
  @userid = userid
  client = Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
  client.query("SELECT HostName, InstanceUUID, ExternalPort, CPU, Memory, Disk, Status FROM VirtualMachine WHERE UserID = #{@userid}").each do |hostname, uuid, externalPort, cpu, memory, disk, status|
    @vm = {:HostName => hostname, :InstanceUUID => uuid, :ExternalPort => externalPort, :CPU => cpu, :Memory => memory, :Disk => disk, :Status => status}
    @vms.push(@vm)
  end
  erb :list
end

# インスタンスの新規作成画面
get '/createinstance/:userID' do |userid|
  @userid = userid
  erb :createinstance
end

# インスタンスの新規作成
post '/createinstance/:userID' do |userid|
  qs = QueueSender.new()
  qs.mqAddress = MQADDRESS
  qs.queueName = "WebAPI_to_DCM"
  @userid = userid
  @hostname = params[:hostname]
  @cpu = params[:cpu]
  @memory = params[:memory]
  @disk = params[:disk]
  @publickey = params[:publickey]
  qs.msg = %Q[{"queueName":"WebAPI_to_DCM", "type":"create", "user":"#{@userid}", "hostname":"#{@hostname}", "cpu":"#{@cpu}", "memory":"#{@memory}", "disk":"#{@disk}", "publickey":"#{@publickey}"}]
  qs.send()
  
  @refresh = "true"
  erb :createinstance
end


# インスタンスの起動
post '/start/:uuid' do |uuid|
  qs = QueueSender.new()
  qs.mqAddress = MQADDRESS
  qs.queueName = "WebAPI_to_DCM"
  qs.msg = %Q[{"queueName":"WebAPI_to_DCM", "type":"start", "uuid":"#{uuid}"}]
  qs.send()

  client = Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
  client.query("SELECT UserID FROM VirtualMachine WHERE InstanceUUID = \"#{uuid}\"").each do |userid|
    @userid = userid[0]
  end

  @vms = Array.new()
  client = Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
  client.query("SELECT HostName, InstanceUUID, ExternalPort, CPU, Memory, Disk, Status FROM VirtualMachine WHERE UserID = #{@userid}").each do |hostname, uuid, externalPort, cpu, memory, disk, status|
    @vm = {:HostName => hostname, :InstanceUUID => uuid, :ExternalPort => externalPort, :CPU => cpu, :Memory => memory, :Disk => disk, :Status => status}
    @vms.push(@vm)
  end

  @refresh = "インスタンスを起動しました"
  erb :list
end

# インスタンスの停止
post '/stop/:uuid' do |uuid|
  qs = QueueSender.new()
  qs.mqAddress = MQADDRESS
  qs.queueName = "WebAPI_to_DCM"
  qs.msg = %Q[{"queueName":"WebAPI_to_DCM", "type":"stop", "uuid":"#{uuid}"}]
  qs.send()

  client = Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
  client.query("SELECT UserID FROM VirtualMachine WHERE InstanceUUID = \"#{uuid}\"").each do |userid|
    @userid = userid[0]
  end

  @vms = Array.new()
  client = Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
  client.query("SELECT HostName, InstanceUUID, ExternalPort, CPU, Memory, Disk, Status FROM VirtualMachine WHERE UserID = #{@userid}").each do |hostname, uuid, externalPort, cpu, memory, disk, status|
    @vm = {:HostName => hostname, :InstanceUUID => uuid, :ExternalPort => externalPort, :CPU => cpu, :Memory => memory, :Disk => disk, :Status => status}
    @vms.push(@vm)
  end

  @refresh = "インスタンスを停止しました"
  erb :list
end

# インスタンスの強制停止
post '/destroy/:uuid' do |uuid|
  qs = QueueSender.new()
  qs.mqAddress = MQADDRESS
  qs.queueName = "WebAPI_to_DCM"
  qs.msg = %Q[{"queueName":"WebAPI_to_DCM", "type":"destroy", "uuid":"#{uuid}"}]
  qs.send()

  client = Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
  client.query("SELECT UserID FROM VirtualMachine WHERE InstanceUUID = \"#{uuid}\"").each do |userid|
    @userid = userid[0]
  end

  @vms = Array.new()
  client = Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
  client.query("SELECT HostName, InstanceUUID, ExternalPort, CPU, Memory, Disk, Status FROM VirtualMachine WHERE UserID = #{@userid}").each do |hostname, uuid, externalPort, cpu, memory, disk, status|
    @vm = {:HostName => hostname, :InstanceUUID => uuid, :ExternalPort => externalPort, :CPU => cpu, :Memory => memory, :Disk => disk, :Status => status}
    @vms.push(@vm)
  end

  @refresh = "インスタンスを強制停止しました"
  erb :list
end

# インスタンスの削除
post '/delete/:uuid' do |uuid|
  qs = QueueSender.new()
  qs.mqAddress = MQADDRESS
  qs.queueName = "WebAPI_to_DCM"
  qs.msg = %Q[{"queueName":"WebAPI_to_DCM", "type":"delete", "uuid":"#{uuid}"}]
  qs.send()

  client = Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
  client.query("SELECT UserID FROM VirtualMachine WHERE InstanceUUID = \"#{uuid}\"").each do |userid|
    @userid = userid[0]
  end

  @vms = Array.new()
  client = Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
  client.query("SELECT HostName, InstanceUUID, ExternalPort, CPU, Memory, Disk, Status FROM VirtualMachine WHERE UserID = #{@userid}").each do |hostname, uuid, externalPort, cpu, memory, disk, status|
    @vm = {:HostName => hostname, :InstanceUUID => uuid, :ExternalPort => externalPort, :CPU => cpu, :Memory => memory, :Disk => disk, :Status => status}
    @vms.push(@vm)
  end

  @refresh = "インスタンスを削除しました"
  erb :list
end
