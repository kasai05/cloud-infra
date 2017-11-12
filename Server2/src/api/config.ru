require 'sinatra'
require 'grape'

require_relative 'MessageAPI.rb'

use Rack::Session::Cookie
run Rack::Cascade.new [MessageAPI]
