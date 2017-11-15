require 'grape'
require 'active_record'
require 'mysql2'

require_relative 'app/base.rb'

# use Rack::Session::Cookie
run Rack::Cascade.new [API::Base]
