# coding: utf-8
require 'sinatra'
require 'json'

set :protection, :except => :json_csrf

Dir.glob('./app/*').each do |r|
  require r
end

