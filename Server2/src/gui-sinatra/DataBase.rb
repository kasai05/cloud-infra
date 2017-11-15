require 'mysql'

class DataBase
  
  def initialize(ip)
    @hostname = ip 
    @username = 'root'
    @password = 'group1'
    @dbname = 'IkuraCloud'
  end

  def getVM
    res = ""
    client = Mysql.connect(@hostname, @username, @password, @dbname)
    client.query("SELECT IPaddr FROM virtual_machines").each do |ans|
      res += ans.to_s
    end
    return res
  end
end
