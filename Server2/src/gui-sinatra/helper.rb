helpers do
  def protect!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end
  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    #username = ENV['BASIC_AUTH_USERNAME']
    #password = ENV['BASIC_AUTH_PASSWORD']
    username = 'ikura'
    password = 'user'
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [username, password]
  end

  def PUSH_WEBAPI!(endpoint)
    Net::HTTP.start('localhost', 9292) {|http|
      request = Net::HTTP::Post.new(endpoint)
      request.set_content_type("application/json")
      request.body = @data_json
      response = http.request(request)
      puts response.body
    }
  end

  def GET_LIST!
    client = Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
    client.query("SELECT UserID FROM VirtualMachine WHERE InstanceUUID = \"#{@uuid}\"").each do |userid|
      @userid = userid[0]
    end

    @vms = Array.new()
    client = Mysql.connect(MQADDRESS, USERNAME, PASSWORD, DBNAME)
    client.query("SELECT HostName, InstanceUUID, ExternalPort, CPU, Memory, Disk, Status FROM VirtualMachine WHERE UserID = #{@userid}").each do |hostname, uuid, externalPort, cpu, memory, disk, status|
      @vm = {:HostName => hostname, :InstanceUUID => uuid, :ExternalPort => externalPort, :CPU => cpu, :Memory => memory, :Disk => disk, :Status => status}
      @vms.push(@vm)
    end
  end
end
