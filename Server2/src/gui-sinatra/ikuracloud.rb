require 'sinatra'
require 'mysql'
require './QueueSender.rb'
require './DataBase.rb'
require './helper.rb'
require 'net/http'
require 'json'
require 'sinatra/formkeeper'

USERNAME = "root"
PASSWORD = "group1"
DBNAME = "IkuraCloud"
MQADDRESS = '127.0.0.1'

set :environment, :production

# ホーム画面。
get '/' do
  protect!
  @users = Array.new()
  client =  Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
  client.query("SELECT DISTINCT usersName, usersID FROM users").each do |userName, userID|
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
  form do
    filters :strip
    field :username, :present => true
    field :tel, :present => true
    field :email, :present => true ,:email => true
  end
  if form.failed?
   	"resister failed"
  else
    	"sucess"
  @username = params[:username]
  @tel = params[:tel]
  @email = params[:email]
  @userID
  userCount = 1

  # usersIDを決めるため、レコード数を確認する
  client = Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
  client.query("SELECT usersID FROM users").each do |userid|
    userCount += 1
  end

  # usersIDの書式を調整
  @userID = sprintf("%08d",userCount).to_s

  client = Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
  stmt = client.prepare("INSERT INTO users (usersID, usersName, Tel, Email) VALUES (?,?,?,?)")
  stmt.execute("#{@userID}", "#{@username}", "#{@tel}", "#{@email}")

  @refresh = "true"
  erb :createuser
  end
end


# ユーザの所有するインスタンス一覧を表示
get '/:userID' do |userid|
  @vms = Array.new()
  @userid = userid
  client = Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
  client.query("SELECT HostName, InstanceUUID, ExternalPort, CPU, Memory, Disk, Status FROM virtual_machines WHERE usersID = #{@userid}").each do |hostname, uuid, externalPort, cpu, memory, disk, status|
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
  form do
    filters :strip
    field :hostname, :present => true
    field :publickey, :present => true
  end
  if form.failed?
   	"resister failed"
  else
    	"sucess"
  @userid = userid
  @hostname = params[:hostname]
  @cpu = params[:cpu]
  @memory = params[:memory]
  @disk = params[:disk]
  @publickey = params[:publickey]

  @data_json = JSON.generate(:queueName => "WebAPI_to_DCM", :type => "create", :user => @userid, :hostname => @hostname, :cpu => @cpu, :memory => @memory, :disk => @disk, :publickey => @publickey)
  PUSH_WEBAPI!('/api/create')

  @refresh = "true"
  erb :createinstance
  end
end


# インスタンスの起動
post '/start/:uuid' do |uuid|
  @uuid = uuid
  @data_json = JSON.generate(:queueName => "WebAPI_to_DCM", :type => "start", :uuid => @uuid)
  PUSH_WEBAPI!('/api/start')

  GET_LIST!

  @refresh = "インスタンスを起動しました"
  erb :list
end

# インスタンスの停止
post '/stop/:uuid' do |uuid|
  @uuid = uuid
  @data_json = JSON.generate(:queueName => "WebAPI_to_DCM", :type => "stop", :uuid => @uuid)
  PUSH_WEBAPI!('/api/stop')

  GET_LIST!

  @refresh = "インスタンスを停止しました"
  erb :list
end

# インスタンスの強制停止
post '/destroy/:uuid' do |uuid|
  @uuid = uuid
  @data_json = JSON.generate(:queueName => "WebAPI_to_DCM", :type => "destroy", :uuid => @uuid)
  PUSH_WEBAPI!('/api/destroy')

  GET_LIST!

  @refresh = "インスタンスを強制停止しました"
  erb :list
end

# インスタンスの削除
post '/delete/:uuid' do |uuid|
  @uuid = uuid
  @data_json = JSON.generate(:queueName => "WebAPI_to_DCM", :type => "delete", :uuid => @uuid)
  PUSH_WEBAPI!('/api/delete')

  GET_LIST!

  @refresh = "インスタンスを削除しました"
  erb :list
end
