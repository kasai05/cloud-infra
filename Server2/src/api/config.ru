require 'grape'
require 'active_record'
require 'mysql2'

require_relative 'app/Base.rb'

# ActiveRecordをgrapeで扱う
ActiveRecord::Base.clear_active_connections!

ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(:production)

# use Rack::Session::Cookie
run Rack::Cascade.new [API::Base]
