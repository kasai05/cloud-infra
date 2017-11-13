require 'sinatra'
require 'grape'

require_relative 'Base.rb'

use Rack::Session::Cookie
run Rack::Cascade.new [API::Base]
